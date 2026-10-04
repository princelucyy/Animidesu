import http from 'node:http';
import fs from 'node:fs';
import { URL } from 'node:url';

const PORT = Number(process.env.PORT || 8787);
const HOST = process.env.HOST || '0.0.0.0';
const catalog = JSON.parse(fs.readFileSync(new URL('./catalog.json', import.meta.url), 'utf8'));

function json(res, status, body) {
  res.writeHead(status, {'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*'});
  res.end(JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {'access-control-allow-origin': '*', 'access-control-allow-methods': 'GET,OPTIONS', 'access-control-allow-headers': 'content-type'});
    return res.end();
  }
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const match = url.pathname.match(/^\/streams\/(\d+)\/(\d+)$/);
  if (!match) return json(res, 404, {error: 'Not found'});
  const key = `${match[1]}:${match[2]}`;
  const streams = Array.isArray(catalog.streams[key]) ? catalog.streams[key] : [];
  return json(res, 200, {streams});
});

server.listen(PORT, HOST, () => console.log(`Animidesu Stream API listening on ${HOST}:${PORT}`));
