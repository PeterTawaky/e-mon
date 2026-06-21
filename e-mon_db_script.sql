CREATE TABLE dbo.AccumulativeReadings
(
    id INT IDENTITY(1,1) PRIMARY KEY,

    component_name NVARCHAR(100) NOT NULL,

    accumulative_value DECIMAL(18,3) NOT NULL,
    past_accumulative_value DECIMAL(18,3) NOT NULL,

    relative_value AS 
        (accumulative_value - past_accumulative_value) PERSISTED,

    created_at DATETIME2(0) NOT NULL 
        CONSTRAINT DF_AccumulativeReadings_created_at DEFAULT SYSDATETIME(),

    record_date AS CAST(created_at AS DATE) PERSISTED,
    record_time AS CAST(created_at AS TIME(0)) PERSISTED,

    [day] AS DAY(created_at) PERSISTED,
    [month] AS MONTH(created_at) PERSISTED,
    [year] AS YEAR(created_at) PERSISTED
);