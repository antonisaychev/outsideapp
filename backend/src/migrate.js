require('dotenv').config();
const fs = require('fs');
const path = require('path');
const db = require('./db');
async function run() {
  await db.query(`CREATE TABLE IF NOT EXISTS _migrations (name TEXT PRIMARY KEY, run_at TIMESTAMPTZ DEFAULT now())`);
  const dir = path.join(__dirname, '..', 'migrations');
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql')).sort();
  for (const f of files) {
    const done = await db.query('SELECT 1 FROM _migrations WHERE name=$1', [f]);
    if (done.rowCount) { console.log('skip', f); continue; }
    console.log('apply', f);
    const sql = fs.readFileSync(path.join(dir, f), 'utf8');
    await db.query('BEGIN');
    try { await db.query(sql); await db.query('INSERT INTO _migrations (name) VALUES ($1)', [f]); await db.query('COMMIT'); }
    catch (e) { await db.query('ROLLBACK'); throw e; }
  }
  console.log('migrations done'); process.exit(0);
}
run().catch(e => { console.error(e); process.exit(1); });
