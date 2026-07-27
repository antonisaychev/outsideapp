// Общая логика над таблицей friendships (используется модулями friends и dating)
const db = require('../db');

// Любая существующая связь между двумя юзерами, в любом направлении
async function getRelationship(userA, userB) {
  const r = await db.query(
    `SELECT * FROM friendships WHERE (requester_id=$1 AND addressee_id=$2) OR (requester_id=$2 AND addressee_id=$1)`,
    [userA, userB]);
  return r.rows[0] || null;
}

// Гарантирует дружбу между юзерами (мэтч в знакомствах = автодружба)
async function ensureFriendship(userA, userB) {
  const existing = await getRelationship(userA, userB);
  if (existing) {
    if (existing.status !== 'accepted') {
      await db.query(`UPDATE friendships SET status='accepted', updated_at=now() WHERE id=$1`, [existing.id]);
    }
  } else {
    await db.query('INSERT INTO friendships (requester_id, addressee_id, status) VALUES ($1,$2,$3)', [userA, userB, 'accepted']);
  }
}

module.exports = { getRelationship, ensureFriendship };
