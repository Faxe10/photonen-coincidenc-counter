// app.js — fetches values via REST API and updates the UI.
// Adjust BASE_URL to your backend.
const BASE_URL = '/api';

// --- Utilities --------------------------------------------------------------
const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
const txt = (el, v) => (el.textContent = v);

async function fetchJSON(path, opts = {}){
  try{
    const res = await fetch(BASE_URL + path, { headers:{'Accept':'application/json'}, ...opts });
    if(!res.ok) throw new Error(`${res.status} ${res.statusText}`);
    return await res.json();
  }catch(err){
    log(`[fetch] ${path} → ${err.message}`);
    return null;
  }
}

function log(msg){
  const t = $('#terminal');
  const time = new Date().toLocaleTimeString();
  t.value += `[${time}] ${msg}\n`;
  t.scrollTop = t.scrollHeight;
}

// --- Sidebar: Detectors -----------------------------------------------------
const DETECTORS = ["AV","AH","AD","AA","BV","BH","BD","BA","Alice","Bob"];

function renderDetectors(){
  const host = $('#detector-list');
  host.innerHTML = '';
  for(const name of DETECTORS){
    const row = document.createElement('div');
    row.className = 'row';
    row.innerHTML = `
      <div style="width:60px">${name}</div>
      <input type="number" class="det-delay" data-det="${name}" value="0" step="0.1" />
      <span class="toggle" data-det="${name}"></span>
    `;
    host.appendChild(row);
  }
  host.addEventListener('click', (e)=>{
    const t = e.target.closest('.toggle');
    if(!t) return;
    t.classList.toggle('on');
    saveDetector(t.dataset.det);
  });
  host.addEventListener('change', (e)=>{
    const input = e.target.closest('.det-delay');
    if(!input) return;
    saveDetector(input.dataset.det);
  });
}

async function saveDetector(name){
  const delay = +$(`.det-delay[data-det="${name}"]`).value;
  const on = $(`.toggle[data-det="${name}"]`).classList.contains('on');
  const payload = { name, delay_ns: delay, enabled: on };
  // POST to /api/detectors/{name}
  await fetchJSON(`/detectors/${encodeURIComponent(name)}`, {
    method:'POST', body: JSON.stringify(payload),
    headers:{'Content-Type':'application/json'}
  });
  log(`Detector ${name} saved: delay=${delay} ns on=${on}`);
}

// --- Charts (lightweight placeholder drawing) -------------------------------
function drawAxes(canvas){
  const ctx = canvas.getContext('2d');
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0,0,w,h);
  ctx.strokeStyle = 'rgba(255,255,255,0.25)';
  ctx.lineWidth = 1;
  // axes
  ctx.beginPath();
  ctx.moveTo(40, h-30); ctx.lineTo(w-10, h-30); // x
  ctx.moveTo(40, h-30); ctx.lineTo(40, 10);     // y
  ctx.stroke();
}

function plotLine(canvas, data){
  const ctx = canvas.getContext('2d');
  const w = canvas.width, h = canvas.height;
  const xmin=0, xmax=Math.max(1, data.length-1);
  const ymin=0, ymax=Math.max(1, Math.max(...data));
  ctx.beginPath();
  for(let i=0;i<data.length;i++){
    const x = 40 + (i/xmax) * (w-50);
    const y = (h-30) - (data[i]/ymax) * (h-40);
    if(i===0) ctx.moveTo(x,y); else ctx.lineTo(x,y);
  }
  ctx.strokeStyle = 'rgba(255,255,255,0.8)';
  ctx.lineWidth = 1.5;
  ctx.stroke();
}

function randomData(n=50, amp=1){
  return Array.from({length:n}, (_,i)=> Math.max(0, (Math.sin(i/6)+1)*0.5*amp + (Math.random()*0.3)));
}

// --- REST updaters ----------------------------------------------------------
async function updateCounts(){
  // expected: { detectors: { AV: 123, ... }, timeseries: [..] }
  const data = await fetchJSON('/counts');
  const cvs = $('#chart-detectors');
  if(!cvs) return;
  drawAxes(cvs);
  if(data?.timeseries){
    plotLine(cvs, data.timeseries);
  }else{
    // fallback demo data
    plotLine(cvs, randomData(80,1.2));
  }
}

async function updateCoincidences(){
  // expected: { timeseries: [..] }
  const data = await fetchJSON('/coincidences');
  const cvs = $('#chart-coinc');
  drawAxes(cvs);
  plotLine(cvs, data?.timeseries ?? randomData(60,0.8));
}

async function updateCorrelation(){
  // expected: { timeseries: [..] }
  const data = await fetchJSON('/correlation');
  const cvs = $('#chart-corr');
  drawAxes(cvs);
  plotLine(cvs, data?.timeseries ?? randomData(90,1));
}

async function updateMatrix(){
  // expected: { header:["BV","BH","BD","BA"], rows:[["AV",1,2,3,4], ...], s:{s1:..,s2:..,s3:..,s4:..} }
  const data = await fetchJSON('/matrix');
  const table = $('#matrix');
  if(data?.header && data?.rows){
    // header
    const thead = table.tHead;
    thead.rows[0].innerHTML = '<th></th>' + data.header.map(h=>`<th>${h}</th>`).join('');
    // body
    const tbody = table.tBodies[0];
    tbody.innerHTML = '';
    for(const row of data.rows){
      const [label, ...vals] = row;
      const tr = document.createElement('tr');
      tr.innerHTML = `<th>${label}</th>` + vals.map(v=>`<td>${v}</td>`).join('');
      tbody.appendChild(tr);
    }
  }
  if(data?.s){
    txt($('#s1'), data.s.s1 ?? '-');
    txt($('#s2'), data.s.s2 ?? '-');
    txt($('#s3'), data.s.s3 ?? '-');
    txt($('#s4'), data.s.s4 ?? '-');
  }
}

async function applySettings(){
  const payload = {
    counts:{ binwidth_ns:+$('#cc-binwidth').value, timeframe_s:+$('#cc-timeframe').value, tw_ns:+$('#cc-tw').value, int_time_s:+$('#cc-inttime').value },
    correlation:{ binwidth_ns:+$('#corr-binwidth').value, timeframe_s:+$('#corr-timeframe').value }
  };
  await fetchJSON('/settings', { method:'POST', body:JSON.stringify(payload), headers:{'Content-Type':'application/json'} });
  log('Settings applied');
}

// --- Device / Buttons -------------------------------------------------------
$('#btn-init').addEventListener('click', async ()=>{
  await fetchJSON('/device/initialize', { method:'POST' });
  log('Device initialized');
});

$('#btn-disconnect').addEventListener('click', async ()=>{
  await fetchJSON('/device/disconnect', { method:'POST' });
  log('Device disconnected');
});

$('#btn-apply').addEventListener('click', applySettings);

$('#btn-calib').addEventListener('click', async ()=>{
  const payload = { A:+$('#calA').value, B:+$('#calB').value };
  await fetchJSON('/stepmotors/calibrate', {method:'POST', body:JSON.stringify(payload), headers:{'Content-Type':'application/json'}});
  log('Stepmotors calibrated');
});

$('#btn-pol-corr-step').addEventListener('click', async ()=>{
  await fetchJSON('/measurements/pol-corr-step', {method:'POST'});
  log('Measurement started: Pol. Corr. (Stepmotors)');
});

$('#btn-pol-corr-quad').addEventListener('click', async ()=>{
  await fetchJSON('/measurements/pol-corr-quad', {method:'POST'});
  log('Measurement started: Pol. Corr. (Quadrant Det.)');
});

$('#btn-bell-quad').addEventListener('click', async ()=>{
  await fetchJSON('/measurements/bell-quad', {method:'POST'});
  log('Measurement started: Bell with Quadrant Det.');
});

$('#btn-save-matrix').addEventListener('click', async ()=>{
  await fetchJSON('/matrix/save', {method:'POST'});
  log('Current Coincidence Matrix saved');
});

// --- Boot -------------------------------------------------------------------
function boot(){
  renderDetectors();
  // initial draw
  $$('canvas.chart').forEach(c=>drawAxes(c));
  // periodic updates
  updateCounts();
  updateCoincidences();
  updateCorrelation();
  updateMatrix();
  setInterval(updateCounts, 2000);
  setInterval(updateCoincidences, 2500);
  setInterval(updateCorrelation, 3000);
  setInterval(updateMatrix, 4000);
  log('UI ready');
}
window.addEventListener('load', boot);
