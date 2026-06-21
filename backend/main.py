from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
import pyodbc
import os
from datetime import date
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="E-Mon API")

CONNECTION_STRING = os.getenv(
    "DB_CONNECTION_STRING",
    "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=e-mon;Trusted_Connection=yes;"
)

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


def get_connection():
    return pyodbc.connect(CONNECTION_STRING)


@app.on_event("startup")
def startup():
    conn = get_connection()
    conn.execute(CREATE_TABLE_SQL)
    conn.commit()
    conn.close()


class ReadingRequest(BaseModel):
    component_name: str = Field(..., max_length=100)
    accumulative_value: float


@app.get("/")
def health_check():
    return {"status": "ok", "message": "E-Mon API is running"}


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
    end_date: date = Query(..., description="End date (YYYY-MM-DD)")
):
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
