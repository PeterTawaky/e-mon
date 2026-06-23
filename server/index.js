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
    const result = await db.request().query('SELECT id, [user] FROM system_users');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /users — create a new system user
app.post('/users', async (req, res) => {
  const { user, password } = req.body;

  if (!user || !password) {
    return res.status(400).json({ error: 'user and password are required' });
  }

  try {
    const db = await getPool();
    const result = await db
      .request()
      .input('user', sql.NVarChar(100), user)
      .input('password', sql.NVarChar(255), password)
      .query(
        'INSERT INTO system_users ([user], [password]) OUTPUT INSERTED.id, INSERTED.[user] VALUES (@user, @password)'
      );
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
