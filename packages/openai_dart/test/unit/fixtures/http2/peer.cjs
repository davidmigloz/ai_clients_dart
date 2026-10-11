// Evaluation-only TLS peer. Node standard library; never records credentials/payloads.
const http2 = require('node:http2');
const https = require('node:https');
const http = require('node:http');
const fs = require('node:fs');
const readline = require('node:readline');
const zlib = require('node:zlib');
const [keyPath, certPath, streamLimit = '100'] = process.argv.slice(2);
const tls = {key: fs.readFileSync(keyPath), cert: fs.readFileSync(certPath)};
const sessions = new Set(), sockets = new Set(), releases = new Map();
const records = []; const sessionEvents = [];
let connections = 0, h2Sessions = 0, requests = 0;
const response = JSON.stringify({id:'resp_fixture', object:'response', created_at:1,
  status:'completed', model:'fixture', output:[], padding:'x'.repeat(4096)});
const frame = (n) => `data: ${JSON.stringify({type:'fixture.tick', sequence_number:n, padding:'x'.repeat(4096)})}\n\n`;
function handler(req, res) {
  if (++requests > 256) { res.writeHead(429); res.end(); return; }
  const mode = req.headers['x-fixture-mode'] || 'json';
  const record = {id:requests, mode, protocol:req.httpVersion, bodyBytes:0, bodyEnded:false,
    sentBytes:0, writes:0, drains:0, finished:false, endCalled:false, rstCode:null, reset:false};
  records.push(record);
  req.on('data', bytes => { record.bodyBytes += bytes.length; });
  req.on('end', () => { record.bodyEnded = true; });
  req.on('error', () => {}); res.on('error', () => {});
  res.on('finish', () => { record.finished = record.endCalled; });
  res.on('close', () => { record.rstCode = req.stream ? req.stream.rstCode : null; record.reset = (record.rstCode !== null && record.rstCode !== 0) || !record.endCalled; releases.delete(record.id); });
  const write = (bytes) => { record.sentBytes += Buffer.byteLength(bytes); record.writes++; return res.write(bytes); };
  const end = (bytes = '') => { record.endCalled = true; record.sentBytes += Buffer.byteLength(bytes); res.end(bytes); };
  const json = () => { res.writeHead(200, {'content-type':'application/json'}); end(response); };
  const hold = (release) => { releases.set(record.id, release); setTimeout(() => {
    if (releases.has(record.id)) { releases.delete(record.id); release(); }
  }, 5000).unref(); };
  if (req.url === '/v1/target') { json(); return; }
  if (mode === 'redirect') { res.writeHead(302, {location:'/v1/target'}); end(); return; }
  if (mode === 'gzip') { res.writeHead(200, {'content-type':'application/json','content-encoding':'gzip'}); end(zlib.gzipSync(response)); return; }
  if (mode === 'json-hold') { hold(json); return; }
  if (mode === 'body-hold') { res.writeHead(200, {'content-type':'application/json'}); write(response.slice(0, 20)); hold(() => end(response.slice(20))); return; }
  if (mode === 'sse-before') {hold(() => {res.writeHead(200, {'content-type':'text/event-stream'});end(frame(0)+'data: [DONE]\n\n');});return;}
  if (mode === 'sse-hold' || mode === 'sse') {
    res.writeHead(200, {'content-type':'text/event-stream'}); write(frame(0));
    if (mode === 'sse-hold') { hold(() => end(frame(1)+'data: [DONE]\n\n')); return; }
    let i=1;
    const timer=setInterval(() => { if (res.destroyed) {clearInterval(timer); return;}
      write(frame(i++)); if (i===10) {clearInterval(timer); end('data: [DONE]\n\n');}
    }, 10);
    res.on('close', () => clearInterval(timer)); return;
  }
  if (mode === 'download') {
    res.writeHead(200, {'content-type':'application/octet-stream'});
    let remaining=64; const chunk=Buffer.alloc(65536, 65);
    const pump=() => { while (remaining>0 && !res.destroyed) {remaining--; if (!write(chunk)) {res.once('drain', () => {record.drains++; pump();});return;}}
      if (!remaining && !res.destroyed) end(); };
    pump(); return;
  }
  // Fully consume uploads before returning valid Files API metadata.
  if (req.url === '/v1/files') {
    req.on('end', () => {res.writeHead(200, {'content-type':'application/json'}); end(JSON.stringify({id:'file_fixture',object:'file',bytes:record.bodyBytes,created_at:1,filename:'fixture.bin',purpose:'assistants'}));});return;
  }
  req.on('end', () => {setTimeout(json, 5);});
}
const peer=http2.createSecureServer({...tls, allowHTTP1:true, settings:{maxConcurrentStreams:Number(streamLimit)}}, handler);
peer.on('session', session => { h2Sessions++; sessions.add(session);session.on('error',error=>sessionEvents.push({event:'error',code:error.code}));session.on('goaway',(code,last)=>sessionEvents.push({event:'goaway',code,last}));session.on('frameError',(type,code,id)=>sessionEvents.push({event:'frameError',type,code,id}));session.on('close',()=>sessions.delete(session)); });
const h1=https.createServer({...tls, ALPNProtocols:['http/1.1']}, handler);
const plain=http.createServer(handler);
for (const server of [peer,h1,plain]) {
  server.on('connection', socket => {connections++;sockets.add(socket);socket.on('error',()=>{});socket.on('close',()=>sockets.delete(socket));});
  server.on('error', error => {process.stderr.write(`${error.code || 'peer error'}\n`);});
}
const listen = server => new Promise(resolve => server.listen(0,'127.0.0.1',resolve));
(async () => {await Promise.all([listen(peer),listen(h1),listen(plain)]);
 process.stdout.write(JSON.stringify({ready:true,port:peer.address().port,http1Port:h1.address().port,plainPort:plain.address().port,node:process.version})+'\n');
})();
readline.createInterface({input:process.stdin}).on('line', async line => {
 const command=JSON.parse(line); let reference=null;
 if(command.action==='reference-sse') reference=await referenceSse();
 if (command.action==='release') {for (const [id,release] of [...releases]) {releases.delete(id);release();}}
 if (command.action==='goaway') {for (const session of sessions) session.goaway();}
 if (command.action==='stop') {for(const socket of sockets)socket.destroy();for(const server of [peer,h1,plain])server.close();}
 process.stdout.write(JSON.stringify({command:command.id,connections,h2Sessions,openSockets:sockets.size,requests,records,sessionEvents,reference})+'\n');
 if (command.action==='stop') setTimeout(()=>process.exit(0),10);
});
process.stdin.on('end',()=>process.exit(0));

async function referenceSse() {
 const client=http2.connect(`https://127.0.0.1:${peer.address().port}`, {ca:tls.cert,servername:'localhost'});
 let successful=0;let events=0;
 try {
  for(let i=0;i<8;i++) {
   await new Promise((resolve,reject)=>{
    const request=client.request({':method':'POST',':path':'/v1/responses',
     'content-type':'application/json; charset=utf-8','accept':'text/event-stream','x-fixture-mode':'sse'});
    let body='';request.on('data',bytes=>{body+=bytes.toString();});request.on('error',reject);
    request.on('end',()=>{const n=(body.match(/fixture.tick/g)||[]).length;
     if(n!==10 || !body.includes('[DONE]'))reject(new Error('Reference fixture mismatch'));
     else {successful++;events+=n;resolve();}});
    request.end(JSON.stringify({model:'fixture',input:'synthetic',stream:true}));
   });
  }
 } finally {client.close();}
 return {successful,events};
}
