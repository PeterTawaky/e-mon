from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
import pyodbc
import os
from datetime import date
from typing import Optional
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
DEFAULT_ADMIN_USER = os.getenv("DEFAULT_ADMIN_USER", "tawaky")
DEFAULT_ADMIN_PASSWORD = os.getenv("DEFAULT_ADMIN_PASSWORD", "tawaky")

# ── DDL ──────────────────────────────────────────────────────────────────────

CREATE_ADMINS_TABLE_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Admins'
)
BEGIN
    CREATE TABLE Admins (
        id         INT IDENTITY(1,1) PRIMARY KEY,
        [user]     NVARCHAR(255) NOT NULL UNIQUE,
        [password] NVARCHAR(255) NOT NULL,
        created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
    )
END
"""

CREATE_TENANTS_TABLE_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tenants'
)
BEGIN
    CREATE TABLE Tenants (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        [user]      NVARCHAR(255) NOT NULL UNIQUE,
        [password]  NVARCHAR(255) NOT NULL,
        register_no NVARCHAR(100) NULL,
        gateway_ip  NVARCHAR(45)  NULL,
        email       NVARCHAR(255) NULL,
        phone_no    NVARCHAR(50)  NULL,
        created_at  DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
    )
END
"""

MIGRATE_TENANTS_OPTIONAL_COLS_SQL = """
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tenants' AND COLUMN_NAME = 'register_no')
    ALTER TABLE Tenants ADD register_no NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tenants' AND COLUMN_NAME = 'gateway_ip')
    ALTER TABLE Tenants ADD gateway_ip  NVARCHAR(45)  NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tenants' AND COLUMN_NAME = 'email')
    ALTER TABLE Tenants ADD email       NVARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tenants' AND COLUMN_NAME = 'phone_no')
    ALTER TABLE Tenants ADD phone_no    NVARCHAR(50)  NULL;
"""

CREATE_READINGS_TABLE_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AccumulativeReadings'
)
BEGIN
    CREATE TABLE AccumulativeReadings (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        tenant_id               INT NOT NULL
            CONSTRAINT FK_AccumulativeReadings_tenant REFERENCES Tenants(id),
        component_name          NVARCHAR(100) NOT NULL,
        accumulative_value      DECIMAL(18,3) NOT NULL,
        past_accumulative_value DECIMAL(18,3) NOT NULL,
        relative_value          AS (accumulative_value - past_accumulative_value) PERSISTED,
        created_at              DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        record_date             AS CAST(created_at AS DATE) PERSISTED,
        record_time             AS CAST(created_at AS TIME(0)) PERSISTED,
        [day]                   AS DAY(created_at)   PERSISTED,
        [month]                 AS MONTH(created_at) PERSISTED,
        [year]                  AS YEAR(created_at)  PERSISTED
    )
END
"""

MIGRATE_ADD_TENANT_ID_SQL = """
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AccumulativeReadings' AND COLUMN_NAME = 'tenant_id'
)
BEGIN
    ALTER TABLE AccumulativeReadings
        ADD tenant_id INT NULL
            CONSTRAINT FK_AccumulativeReadings_tenant REFERENCES Tenants(id)
END
"""

MIGRATE_TENANT_ID_NOT_NULL_SQL = """
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AccumulativeReadings'
      AND COLUMN_NAME = 'tenant_id'
      AND IS_NULLABLE = 'YES'
)
BEGIN
    DELETE FROM AccumulativeReadings WHERE tenant_id IS NULL;
    ALTER TABLE AccumulativeReadings ALTER COLUMN tenant_id INT NOT NULL
END
"""


def get_connection():
    return pyodbc.connect(CONNECTION_STRING)


def ensure_default_admin():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(1) FROM Admins")
        if cursor.fetchone()[0] == 0:
            cursor.execute(
                "INSERT INTO Admins ([user], [password]) VALUES (?, ?)",
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
    conn.execute(CREATE_ADMINS_TABLE_SQL)
    conn.execute(CREATE_TENANTS_TABLE_SQL)
    conn.execute(MIGRATE_TENANTS_OPTIONAL_COLS_SQL)
    conn.execute(CREATE_READINGS_TABLE_SQL)
    conn.execute(MIGRATE_ADD_TENANT_ID_SQL)
    conn.execute(MIGRATE_TENANT_ID_NOT_NULL_SQL)
    conn.commit()
    conn.close()
    ensure_default_admin()
    if SIMULATION_ENABLED:
        reading_stream_service.start()


@app.on_event("shutdown")
def shutdown():
    reading_stream_service.stop()


# ── Models ────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    user: str = Field(..., max_length=255)
    password: str = Field(..., min_length=1, max_length=128)


class CreateAdminRequest(BaseModel):
    user: str = Field(..., max_length=255)
    password: str = Field(..., min_length=6, max_length=128)


class CreateTenantRequest(BaseModel):
    user: str = Field(..., max_length=255)
    password: str = Field(..., min_length=6, max_length=128)
    register_no: Optional[str] = Field(None, max_length=100)
    gateway_ip: Optional[str] = Field(None, max_length=45)
    email: Optional[str] = Field(None, max_length=255)
    phone_no: Optional[str] = Field(None, max_length=50)


class ReadingRequest(BaseModel):
    tenant_id: int
    component_name: str = Field(..., max_length=100)
    accumulative_value: float


# ── Health ────────────────────────────────────────────────────────────────────

@app.get("/")
def health_check():
    return {"status": "ok", "message": "WattWise API is running"}


# ── Auth ──────────────────────────────────────────────────────────────────────

@app.post("/auth/admin/login")
def admin_login(request: LoginRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, [user] FROM Admins WHERE [user] = ? AND [password] = ?",
            request.user,
            request.password,
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=401, detail="Invalid user or password")
        return {"id": row[0], "user": row[1], "role": "admin"}
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.post("/auth/tenant/login")
def tenant_login(request: LoginRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, [user] FROM Tenants WHERE [user] = ? AND [password] = ?",
            request.user,
            request.password,
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=401, detail="Invalid user or password")
        return {"id": row[0], "user": row[1], "role": "tenant"}
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


# ── Admins ────────────────────────────────────────────────────────────────────

@app.get("/admins")
def get_admins():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, [user], created_at FROM Admins ORDER BY id DESC")
        rows = cursor.fetchall()
        return [{"id": r[0], "user": r[1], "created_at": r[2].isoformat()} for r in rows]
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.post("/admins", status_code=201)
def create_admin(request: CreateAdminRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(1) FROM Admins WHERE [user] = ?", request.user)
        if cursor.fetchone()[0] > 0:
            raise HTTPException(status_code=409, detail="Admin already exists")
        cursor.execute(
            """
            INSERT INTO Admins ([user], [password])
            OUTPUT INSERTED.id, INSERTED.[user], INSERTED.created_at
            VALUES (?, ?)
            """,
            request.user,
            request.password,
        )
        result = cursor.fetchone()
        conn.commit()
        return {"id": result[0], "user": result[1], "created_at": result[2].isoformat()}
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.delete("/admins/{admin_id}", status_code=200)
def delete_admin(admin_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Admins WHERE id = ?", admin_id)
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Admin not found")
        conn.commit()
        return {"message": "Admin deleted successfully", "deleted_id": admin_id}
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


# ── Tenants ───────────────────────────────────────────────────────────────────

@app.get("/tenants")
def get_tenants():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, [user], register_no, gateway_ip, email, phone_no, created_at "
            "FROM Tenants ORDER BY id DESC"
        )
        rows = cursor.fetchall()
        return [
            {
                "id": r[0],
                "user": r[1],
                "register_no": r[2],
                "gateway_ip": r[3],
                "email": r[4],
                "phone_no": r[5],
                "created_at": r[6].isoformat(),
            }
            for r in rows
        ]
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.post("/tenants", status_code=201)
def create_tenant(request: CreateTenantRequest):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(1) FROM Tenants WHERE [user] = ?", request.user)
        if cursor.fetchone()[0] > 0:
            raise HTTPException(status_code=409, detail="Tenant already exists")
        cursor.execute(
            """
            INSERT INTO Tenants ([user], [password], register_no, gateway_ip, email, phone_no)
            OUTPUT
                INSERTED.id,
                INSERTED.[user],
                INSERTED.register_no,
                INSERTED.gateway_ip,
                INSERTED.email,
                INSERTED.phone_no,
                INSERTED.created_at
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            request.user,
            request.password,
            request.register_no,
            request.gateway_ip,
            request.email,
            request.phone_no,
        )
        result = cursor.fetchone()
        conn.commit()
        return {
            "id": result[0],
            "user": result[1],
            "register_no": result[2],
            "gateway_ip": result[3],
            "email": result[4],
            "phone_no": result[5],
            "created_at": result[6].isoformat(),
        }
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.delete("/tenants/{tenant_id}", status_code=200)
def delete_tenant(tenant_id: int):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Tenants WHERE id = ?", tenant_id)
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Tenant not found")
        conn.commit()
        return {"message": "Tenant deleted successfully", "deleted_id": tenant_id}
    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


# ── System Reset ──────────────────────────────────────────────────────────────

@app.post("/system-reset", status_code=200)
def system_reset():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("IF OBJECT_ID('AccumulativeReadings', 'U') IS NOT NULL DROP TABLE AccumulativeReadings")
        cursor.execute("IF OBJECT_ID('Tenants', 'U') IS NOT NULL DROP TABLE Tenants")
        cursor.execute("IF OBJECT_ID('Admins', 'U') IS NOT NULL DROP TABLE Admins")
        cursor.execute("IF OBJECT_ID('SystemUsers', 'U') IS NOT NULL DROP TABLE SystemUsers")

        cursor.execute("""
            CREATE TABLE Admins (
                id         INT IDENTITY(1,1) PRIMARY KEY,
                [user]     NVARCHAR(255) NOT NULL UNIQUE,
                [password] NVARCHAR(255) NOT NULL,
                created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
            )
        """)

        cursor.execute("""
            CREATE TABLE Tenants (
                id          INT IDENTITY(1,1) PRIMARY KEY,
                [user]      NVARCHAR(255) NOT NULL UNIQUE,
                [password]  NVARCHAR(255) NOT NULL,
                register_no NVARCHAR(100) NULL,
                gateway_ip  NVARCHAR(45)  NULL,
                email       NVARCHAR(255) NULL,
                phone_no    NVARCHAR(50)  NULL,
                created_at  DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
            )
        """)

        cursor.execute("""
            CREATE TABLE AccumulativeReadings (
                id                      INT IDENTITY(1,1) PRIMARY KEY,
                tenant_id               INT NOT NULL
                    CONSTRAINT FK_AccumulativeReadings_tenant REFERENCES Tenants(id),
                component_name          NVARCHAR(100) NOT NULL,
                accumulative_value      DECIMAL(18,3) NOT NULL,
                past_accumulative_value DECIMAL(18,3) NOT NULL,
                relative_value          AS (accumulative_value - past_accumulative_value) PERSISTED,
                created_at              DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
                record_date             AS CAST(created_at AS DATE) PERSISTED,
                record_time             AS CAST(created_at AS TIME(0)) PERSISTED,
                [day]                   AS DAY(created_at)   PERSISTED,
                [month]                 AS MONTH(created_at) PERSISTED,
                [year]                  AS YEAR(created_at)  PERSISTED
            )
        """)

        cursor.execute(
            "INSERT INTO Admins ([user], [password]) VALUES (?, ?)",
            "tawaky", "tawaky",
        )

        conn.commit()
        return {"message": "System reset successful. Admin account restored."}

    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


# ── Readings ──────────────────────────────────────────────────────────────────

@app.get("/readings")
def get_all_readings(
    tenant_id: Optional[int] = Query(None),
    tenant_name: Optional[str] = Query(None),
):
    try:
        conn = get_connection()
        cursor = conn.cursor()

        if tenant_name is not None:
            cursor.execute(
                """
                SELECT ar.id, ar.tenant_id, ar.component_name, ar.accumulative_value,
                       ar.past_accumulative_value, ar.relative_value, ar.created_at
                FROM AccumulativeReadings ar
                JOIN Tenants t ON ar.tenant_id = t.id
                WHERE t.[user] = ?
                ORDER BY ar.id DESC
                """,
                tenant_name,
            )
        elif tenant_id is not None:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                WHERE tenant_id = ?
                ORDER BY id DESC
                """,
                tenant_id,
            )
        else:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                ORDER BY id DESC
                """
            )

        rows = cursor.fetchall()
        return [
            {
                "id": r[0],
                "tenant_id": r[1],
                "component_name": r[2],
                "accumulative_value": float(r[3]),
                "past_accumulative_value": float(r[4]),
                "relative_value": float(r[5]),
                "created_at": r[6].isoformat(),
            }
            for r in rows
        ]
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/readings/range")
def get_specific_range(
    start_date: date = Query(..., description="Start date (YYYY-MM-DD)"),
    end_date: date = Query(None, description="End date (YYYY-MM-DD), defaults to today"),
    tenant_id: Optional[int] = Query(None),
    tenant_name: Optional[str] = Query(None),
):
    if end_date is None:
        end_date = date.today()

    try:
        conn = get_connection()
        cursor = conn.cursor()

        if tenant_name is not None:
            cursor.execute(
                """
                SELECT ar.id, ar.tenant_id, ar.component_name, ar.accumulative_value,
                       ar.past_accumulative_value, ar.relative_value, ar.created_at
                FROM AccumulativeReadings ar
                JOIN Tenants t ON ar.tenant_id = t.id
                WHERE ar.record_date BETWEEN ? AND ? AND t.[user] = ?
                ORDER BY ar.id DESC
                """,
                start_date, end_date, tenant_name,
            )
        elif tenant_id is not None:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                WHERE record_date BETWEEN ? AND ? AND tenant_id = ?
                ORDER BY id DESC
                """,
                start_date, end_date, tenant_id,
            )
        else:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                WHERE record_date BETWEEN ? AND ?
                ORDER BY id DESC
                """,
                start_date, end_date,
            )

        rows = cursor.fetchall()
        return [
            {
                "id": r[0],
                "tenant_id": r[1],
                "component_name": r[2],
                "accumulative_value": float(r[3]),
                "past_accumulative_value": float(r[4]),
                "relative_value": float(r[5]),
                "created_at": r[6].isoformat(),
            }
            for r in rows
        ]
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()


@app.get("/readings/monthly")
def get_monthly_values(
    tenant_id: Optional[int] = Query(None),
    tenant_name: Optional[str] = Query(None),
):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        today = date.today()

        if tenant_name is not None:
            cursor.execute(
                """
                SELECT ar.id, ar.tenant_id, ar.component_name, ar.accumulative_value,
                       ar.past_accumulative_value, ar.relative_value, ar.created_at
                FROM AccumulativeReadings ar
                JOIN Tenants t ON ar.tenant_id = t.id
                WHERE ar.[month] = ? AND ar.[year] = ? AND t.[user] = ?
                ORDER BY ar.id DESC
                """,
                today.month, today.year, tenant_name,
            )
        elif tenant_id is not None:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                WHERE [month] = ? AND [year] = ? AND tenant_id = ?
                ORDER BY id DESC
                """,
                today.month, today.year, tenant_id,
            )
        else:
            cursor.execute(
                """
                SELECT id, tenant_id, component_name, accumulative_value,
                       past_accumulative_value, relative_value, created_at
                FROM AccumulativeReadings
                WHERE [month] = ? AND [year] = ?
                ORDER BY id DESC
                """,
                today.month, today.year,
            )

        rows = cursor.fetchall()
        return [
            {
                "id": r[0],
                "tenant_id": r[1],
                "component_name": r[2],
                "accumulative_value": float(r[3]),
                "past_accumulative_value": float(r[4]),
                "relative_value": float(r[5]),
                "created_at": r[6].isoformat(),
            }
            for r in rows
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

        cursor.execute("SELECT COUNT(1) FROM Tenants WHERE id = ?", reading.tenant_id)
        if cursor.fetchone()[0] == 0:
            raise HTTPException(status_code=404, detail="Tenant not found")

        cursor.execute(
            "SELECT TOP 1 accumulative_value FROM AccumulativeReadings "
            "WHERE component_name = ? AND tenant_id = ? ORDER BY id DESC",
            reading.component_name,
            reading.tenant_id,
        )
        row = cursor.fetchone()
        past_accumulative_value = float(row[0]) if row else 0.0

        cursor.execute(
            """
            INSERT INTO AccumulativeReadings (tenant_id, component_name, accumulative_value, past_accumulative_value)
            OUTPUT
                INSERTED.id,
                INSERTED.tenant_id,
                INSERTED.component_name,
                INSERTED.accumulative_value,
                INSERTED.past_accumulative_value,
                INSERTED.relative_value,
                INSERTED.created_at
            VALUES (?, ?, ?, ?)
            """,
            reading.tenant_id,
            reading.component_name,
            reading.accumulative_value,
            past_accumulative_value,
        )
        result = cursor.fetchone()
        conn.commit()

        return {
            "id": result[0],
            "tenant_id": result[1],
            "component_name": result[2],
            "accumulative_value": float(result[3]),
            "past_accumulative_value": float(result[4]),
            "relative_value": float(result[5]),
            "created_at": result[6].isoformat(),
        }

    except HTTPException:
        raise
    except pyodbc.Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if "conn" in locals():
            conn.close()
