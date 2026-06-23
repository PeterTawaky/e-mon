from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
import pyodbc
import os
from datetime import date
from dotenv import load_dotenv
from simulation_stream_service import AccumulativeReadingStreamService

load_dotenv()

app = FastAPI(title="WattWise API")

CONNECTION_STRING = os.getenv(
    "DB_CONNECTION_STRING",
    "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=e-mon;Trusted_Connection=yes;"
)

SIMULATION_ENABLED = os.getenv("SIMULATION_ENABLED", "true").lower() == "true"
SIMULATION_INTERVAL_SECONDS = int(os.getenv("SIMULATION_INTERVAL_SECONDS", "60"))
DEFAULT_ADMIN_USER = os.getenv("DEFAULT_ADMIN_USER", "admin")
DEFAULT_ADMIN_PASSWORD = os.getenv("DEFAULT_ADMIN_PASSWORD", "admin123")

CREATE_TABLE_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AccumulativeReadings'
)
BEGIN
    CREATE TABLE AccumulativeReadings (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        component_name          NVARCHAR(100) NOT NULL,
        accumulative_value      DECIMAL(18,3) NOT NULL,
        past_accumulative_value DECIMAL(18,3) NOT NULL,
        relative_value          AS (accumulative_value - past_accumulative_value) PERSISTED,
        created_at              DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        record_date             AS CAST(created_at AS DATE) PERSISTED,
        record_time             AS CAST(created_at AS TIME(0)) PERSISTED,
        [day]                   AS DAY(created_at) PERSISTED,
        [month]                 AS MONTH(created_at) PERSISTED,
        [year]                  AS YEAR(created_at) PERSISTED
    )
END
"""

MIGRATE_USERS_TABLE_SQL = """
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SystemUsers'
    AND COLUMN_NAME IN ('email', 'password_hash')
)
BEGIN
    DROP TABLE SystemUsers
END
"""

CREATE_USERS_TABLE_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SystemUsers'
)
BEGIN
    CREATE TABLE SystemUsers (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        [user]      NVARCHAR(255) NOT NULL UNIQUE,
        [password]  NVARCHAR(255) NOT NULL,
        created_at  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
    )
END
"""


def get_connection():
    return pyodbc.connect(CONNECTION_STRING)


def ensure_default_admin():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(1) FROM SystemUsers")
        users_count = cursor.fetchone()[0]
        if users_count == 0:
            cursor.execute(
                "INSERT INTO SystemUsers ([user], [password]) VALUES (?, ?)",
                DEFAULT_ADMIN_USER,
                DEFAULT_ADMIN_PASSWORD,
            )
            conn.commit()
    finally:
        conn.close()


reading_stream_service = AccumulativeReadingStreamService(
    get_connection,
    interval_seconds=SIMULATION_INTERVAL_SECONDS,
)


@app.on_event("startup")
def startup():
    conn = get_connection()
    conn.execute(CREATE_TABLE_SQL)
    conn.execute(MIGRATE_USERS_TABLE_SQL)
    conn.execute(CREATE_USERS_TABLE_SQL)
    conn.commit()
    conn.close()
    ensure_default_admin()
    if SIMULATION_ENABLED:
        reading_stream_service.start()


@app.on_event("shutdown")
def shutdown():
    reading_stream_service.stop()


class ReadingRequest(BaseModel):
    component_name: str = Field(..., max_length=100)
    accumulative_value: float


class LoginRequest(BaseModel):
    user: str = Field(..., max_length=255)
    password: str = Field(..., min_length=1, max_length=128)


class CreateUserRequest(BaseModel):
    user: str = Field(..., max_length=255)
    password: str = Field(..., min_length=6, max_length=128)


@app.get("/")
def health_check():
    return {"status": "ok", "message": "WattWise API is running"}


@app.post("/auth/login")
def login(request: LoginRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, [user] FROM SystemUsers WHERE [user] = ? AND [password] = ?",
            request.user,
            request.password,
        )
        row = cursor.fetchone()

        if not row:
            raise HTTPException(status_code=401, detail="Invalid user or password")

        return {"id": row[0], "user": row[1]}

    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/users")
def get_users():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, [user], [password], created_at FROM SystemUsers ORDER BY id DESC"
        )
        rows = cursor.fetchall()

        return [
            {
                "id": row[0],
                "user": row[1],
                "password": row[2],
                "created_at": row[3].isoformat()
            }
            for row in rows
        ]

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.post("/users", status_code=201)
def create_user(request: CreateUserRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(1) FROM SystemUsers WHERE [user] = ?", request.user)
        if cursor.fetchone()[0] > 0:
            raise HTTPException(status_code=409, detail="User already exists")

        cursor.execute(
            """
            INSERT INTO SystemUsers ([user], [password])
            OUTPUT INSERTED.id, INSERTED.[user], INSERTED.[password], INSERTED.created_at
            VALUES (?, ?)
            """,
            request.user,
            request.password,
        )
        result = cursor.fetchone()
        conn.commit()

        return {
            "id": result[0],
            "user": result[1],
            "password": result[2],
            "created_at": result[3].isoformat()
        }

    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.delete("/users/{user_id}", status_code=200)
def delete_user(user_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM SystemUsers WHERE id = ?", user_id)
        deleted_count = cursor.rowcount
        conn.commit()

        if deleted_count == 0:
            raise HTTPException(status_code=404, detail="User not found")

        return {"message": "User deleted successfully", "deleted_id": user_id}

    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/readings")
def get_all_readings():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            """
            SELECT id, component_name, accumulative_value, past_accumulative_value,
                   relative_value, created_at
            FROM AccumulativeReadings
            ORDER BY id DESC
            """
        )
        rows = cursor.fetchall()

        return [
            {
                "id": row[0],
                "component_name": row[1],
                "accumulative_value": float(row[2]),
                "past_accumulative_value": float(row[3]),
                "relative_value": float(row[4]),
                "created_at": row[5].isoformat()
            }
            for row in rows
        ]

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/readings/range")
def get_specific_range(
    start_date: date = Query(..., description="Start date (YYYY-MM-DD)"),
    end_date: date = Query(None, description="End date (YYYY-MM-DD), defaults to today")
):
    if end_date is None:
        end_date = date.today()

    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute(
            """
            SELECT id, component_name, accumulative_value, past_accumulative_value,
                   relative_value, created_at
            FROM AccumulativeReadings
            WHERE record_date BETWEEN ? AND ?
            ORDER BY id DESC
            """,
            start_date,
            end_date
        )
        rows = cursor.fetchall()

        return [
            {
                "id": row[0],
                "component_name": row[1],
                "accumulative_value": float(row[2]),
                "past_accumulative_value": float(row[3]),
                "relative_value": float(row[4]),
                "created_at": row[5].isoformat()
            }
            for row in rows
        ]

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/readings/monthly")
def get_monthly_values():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        today = date.today()

        cursor.execute(
            """
            SELECT id, component_name, accumulative_value, past_accumulative_value,
                   relative_value, created_at
            FROM AccumulativeReadings
            WHERE [month] = ? AND [year] = ?
            ORDER BY id DESC
            """,
            today.month,
            today.year
        )
        rows = cursor.fetchall()

        return [
            {
                "id": row[0],
                "component_name": row[1],
                "accumulative_value": float(row[2]),
                "past_accumulative_value": float(row[3]),
                "relative_value": float(row[4]),
                "created_at": row[5].isoformat()
            }
            for row in rows
        ]

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.delete("/readings", status_code=200)
def delete_all_readings():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM AccumulativeReadings")
        deleted_count = cursor.rowcount
        conn.commit()

        return {"message": "All readings deleted", "deleted_count": deleted_count}

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.post("/readings", status_code=201)
def create_reading(reading: ReadingRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Fetch the last accumulative_value for this component (0 if first record)
        cursor.execute(
            "SELECT TOP 1 accumulative_value FROM AccumulativeReadings "
            "WHERE component_name = ? ORDER BY id DESC",
            reading.component_name
        )
        row = cursor.fetchone()
        past_accumulative_value = float(row[0]) if row else 0.0

        # Insert and return the new record via OUTPUT clause
        cursor.execute(
            """
            INSERT INTO AccumulativeReadings (component_name, accumulative_value, past_accumulative_value)
            OUTPUT
                INSERTED.id,
                INSERTED.component_name,
                INSERTED.accumulative_value,
                INSERTED.past_accumulative_value,
                INSERTED.relative_value,
                INSERTED.created_at
            VALUES (?, ?, ?)
            """,
            reading.component_name,
            reading.accumulative_value,
            past_accumulative_value
        )
        result = cursor.fetchone()
        conn.commit()

        return {
            "id": result[0],
            "component_name": result[1],
            "accumulative_value": float(result[2]),
            "past_accumulative_value": float(result[3]),
            "relative_value": float(result[4]),
            "created_at": result[5].isoformat()
        }

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()
