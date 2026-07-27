// Отправка писем с кодами. Без SMTP-настроек работает в dev-режиме: код в консоль.
const nodemailer = require('nodemailer');
let transport = null;
if (process.env.SMTP_HOST) {
  transport = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
}
async function sendCode(email, code, purpose) {
  const subject = purpose === 'reset' ? 'Outside: код для сброса пароля' : 'Outside: подтвердите почту';
  const text = `Ваш код: ${code}\nОн действует 10 минут. Если это были не вы — просто проигнорируйте письмо.`;
  if (!transport) { console.log(`[DEV MAIL] to=${email} purpose=${purpose} code=${code}`); return; }
  await transport.sendMail({ from: process.env.MAIL_FROM, to: email, subject, text });
}
module.exports = { sendCode };
