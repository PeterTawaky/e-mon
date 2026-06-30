CREATE TABLE Admins
(
    id         INT IDENTITY(1,1) PRIMARY KEY,
    [user]     NVARCHAR(255) NOT NULL UNIQUE,
    [password] NVARCHAR(255) NOT NULL,
    created_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_Admins_created_at DEFAULT SYSDATETIME()
);

CREATE TABLE Tenants
(
    id          INT IDENTITY(1,1) PRIMARY KEY,
    [user]      NVARCHAR(255) NOT NULL UNIQUE,
    [password]  NVARCHAR(255) NOT NULL,
    register_no NVARCHAR(100) NULL,
    gateway_ip  NVARCHAR(45)  NULL,
    email       NVARCHAR(255) NULL,
    phone_no    NVARCHAR(50)  NULL,
    created_at  DATETIME2(0)  NOT NULL
        CONSTRAINT DF_Tenants_created_at DEFAULT SYSDATETIME()
);

CREATE TABLE AccumulativeReadings
(
    id INT IDENTITY(1,1) PRIMARY KEY,

    tenant_id INT NOT NULL
        CONSTRAINT FK_AccumulativeReadings_tenant REFERENCES Tenants(id),

    component_name          NVARCHAR(100) NOT NULL,

    accumulative_value      DECIMAL(18,3) NOT NULL,
    past_accumulative_value DECIMAL(18,3) NOT NULL,

    relative_value AS
        (accumulative_value - past_accumulative_value) PERSISTED,

    created_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_AccumulativeReadings_created_at DEFAULT SYSDATETIME(),

    record_date AS CAST(created_at AS DATE)    PERSISTED,
    record_time AS CAST(created_at AS TIME(0)) PERSISTED,

    [day]   AS DAY(created_at)   PERSISTED,
    [month] AS MONTH(created_at) PERSISTED,
    [year]  AS YEAR(created_at)  PERSISTED
);

-- Seed default admin account
INSERT INTO Admins ([user], [password]) VALUES ('tawaky', 'tawaky');
