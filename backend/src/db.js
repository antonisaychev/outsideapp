const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // На VPS с одним процессом 10 соединений хватает с запасом; лимит нужен,
  // чтобы всплеск запросов не выел все коннекты Postgres
  max: Number(process.env.PG_POOL_MAX) || 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
});

// Соединение может оборваться (перезапуск Postgres, сеть) — pg сам поднимет
// новое, нам важно не уронить процесс необработанным событием
pool.on('error', (err) => console.error('Ошибка соединения с базой:', err.message));

/// Несколько запросов одной сделкой: либо всё, либо ничего.
/// Нужен там, где данные связаны — мэтч, удаление карточки.
async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  query: (text, params) => pool.query(text, params),
  withTransaction,
  pool,
};
