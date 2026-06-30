require('dotenv').config();
const express = require('express');
const sql = require('mssql');

const app = express();
app.use(express.json());

const dbConfig = {
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT),
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
};

let pool;

async function getPool() {
  if (!pool) {
    pool = await sql.connect(dbConfig);
  }
  return pool;
}

// GET /users — return all system users
app.get('/users', async (req, res) => {
  try {
    const db = await getPool();
    const result = await db.request().query('SELECT id, [user], [role] FROM system_users');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /users — create a new system user
app.post('/users', async (req, res) => {
  const { user, password, role } = req.body;

  if (!user || !password || !role) {
    return res.status(400).json({ error: 'user, password, and role are required' });
  }

  if (!['admin', 'tenant'].includes(role)) {
    return res.status(400).json({ error: "role must be 'admin' or 'tenant'" });
  }

  try {
    const db = await getPool();
    const result = await db
      .request()
      .input('user', sql.NVarChar(100), user)
      .input('password', sql.NVarChar(255), password)
      .input('role', sql.NVarChar(10), role)
      .query(
        'INSERT INTO system_users ([user], [password], [role]) OUTPUT INSERTED.id, INSERTED.[user], INSERTED.[role] VALUES (@user, @password, @role)'
      );
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /system-reset — drop all tables, recreate schema, seed admin account
app.post('/system-reset', async (req, res) => {
  try {
    const db = await getPool();

    await db.request().batch(`
      IF OBJECT_ID('AccumulativeReadings', 'U') IS NOT NULL DROP TABLE AccumulativeReadings;
      IF OBJECT_ID('system_users', 'U') IS NOT NULL DROP TABLE system_users;
    `);

    await db.request().batch(`
      CREATE TABLE system_users (
        id         INT IDENTITY(1,1) PRIMARY KEY,
        [user]     NVARCHAR(100) NOT NULL,
        [password] NVARCHAR(255) NOT NULL,
        [role]     NVARCHAR(10)  NOT NULL
          CONSTRAINT CK_system_users_role CHECK ([role] IN ('admin', 'tenant'))
      );
    `);

    await db.request().batch(`
      CREATE TABLE AccumulativeReadings (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        component_name          NVARCHAR(100)  NOT NULL,
        accumulative_value      DECIMAL(18,3)  NOT NULL,
        past_accumulative_value DECIMAL(18,3)  NOT NULL,
        relative_value AS (accumulative_value - past_accumulative_value) PERSISTED,
        created_at              DATETIME2(0)   NOT NULL
          CONSTRAINT DF_AccumulativeReadings_created_at DEFAULT SYSDATETIME(),
        record_date AS CAST(created_at AS DATE)    PERSISTED,
        record_time AS CAST(created_at AS TIME(0)) PERSISTED,
        [day]   AS DAY(created_at)   PERSISTED,
        [month] AS MONTH(created_at) PERSISTED,
        [year]  AS YEAR(created_at)  PERSISTED
      );
    `);

    await db
      .request()
      .input('user', sql.NVarChar(100), 'tawaky')
      .input('password', sql.NVarChar(255), 'tawaky')
      .input('role', sql.NVarChar(10), 'admin')
      .query(
        "INSERT INTO system_users ([user], [password], [role]) VALUES (@user, @password, @role)"
      );

    res.json({ message: 'System reset successful. Admin account restored.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
