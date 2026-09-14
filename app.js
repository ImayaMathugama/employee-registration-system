const STORAGE_SCANS = 'ers_scans_v1';
const SAMPLE_MASTER = `EMP_NO,EMP_NAME,Gender,Active
81017,J.K. Ranasinghe,Male,Active
60033,G.C. G.C.Fernando,Male,Active
100012,M.A.S.R.R. Perera,Male,Active
100013,K.P.G.U. K.P.G. Udaya Kumara,Female,Active
100017,K.P.G.C. Kumari,Female,Active
100023,H.M.K. H.M.K. Damayanthi,Female,Active
23986,W.N.R Fernando,Female,Active
70212,W.D.H. De Silva,Female,Active
27229,K.A.N.T.N. Chandrarathna,Male,Active
70266,J.M.S. Koralage,Male,Active
27684,K.G.S.R.M. Manoj,Male,Active
27775,P.I.U. Pathirana,Male,Active
28047,M.H.K. Susantha,Male,Active
28084,M.S.N. Fernando,Male,Active
28180,A.M.P.H.S. Perera,Male,Active
28187,W.P.G. Kalani,Female,Active`;

const state = {
  masterById: new Map(),
  scans: loadScans(),
};

const el = {
  masterCsv: document.getElementById('masterCsv'),
  masterFile: document.getElementById('masterFile'),
  masterStatus: document.getElementById('masterStatus'),
  loadSampleBtn: document.getElementById('loadSampleBtn'),
  applyMasterBtn: document.getElementById('applyMasterBtn'),
  scanForm: document.getElementById('scanForm'),
  stationId: document.getElementById('stationId'),
  scanInput: document.getElementById('scanInput'),
  cardName: document.getElementById('cardName'),
  cardGender: document.getElementById('cardGender'),
  scanStatus: document.getElementById('scanStatus'),
  recordsBody: document.getElementById('recordsBody'),
  totalScans: document.getElementById('totalScans'),
  uniqueScans: document.getElementById('uniqueScans'),
  maleCount: document.getElementById('maleCount'),
  femaleCount: document.getElementById('femaleCount'),
  mismatchCount: document.getElementById('mismatchCount'),
  inactiveCount: document.getElementById('inactiveCount'),
  duplicateCount: document.getElementById('duplicateCount'),
  exportBtn: document.getElementById('exportBtn'),
  clearBtn: document.getElementById('clearBtn'),
};

init();

function init() {
  el.masterCsv.value = SAMPLE_MASTER;
  bindEvents();
  applyMasterData();
  render();
}

function bindEvents() {
  el.loadSampleBtn.addEventListener('click', () => {
    el.masterCsv.value = SAMPLE_MASTER;
    setStatus(el.masterStatus, 'Sample master data loaded.', 'ok');
  });

  el.masterFile.addEventListener('change', async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const text = await file.text();
    el.masterCsv.value = text;
    setStatus(el.masterStatus, `Loaded ${file.name}. Click "Apply master data".`, 'ok');
  });

  el.applyMasterBtn.addEventListener('click', applyMasterData);

  el.scanForm.addEventListener('submit', (event) => {
    event.preventDefault();
    registerScan();
  });

  el.exportBtn.addEventListener('click', exportCsv);

  el.clearBtn.addEventListener('click', () => {
    if (!confirm('Clear all scanned records?')) return;
    state.scans = [];
    persistScans();
    render();
    setStatus(el.scanStatus, 'All scan records cleared.', 'warn');
    el.scanInput.focus();
  });
}

function applyMasterData() {
  try {
    const rows = parseCsv(el.masterCsv.value.trim());
    if (!rows.length) throw new Error('No master rows found.');

    const required = ['EMP_NO', 'EMP_NAME', 'Gender'];
    const first = Object.keys(rows[0]);
    for (const col of required) {
      if (!first.includes(col)) throw new Error(`Missing required column: ${col}`);
    }

    const map = new Map();
    for (const row of rows) {
      const empNo = sanitizeEmpNo(row.EMP_NO);
      if (!empNo) continue;
      map.set(empNo, {
        empNo,
        empName: (row.EMP_NAME || '').trim(),
        gender: normalizeGender(row.Gender),
        active: normalizeActive(row.Active),
      });
    }

    state.masterById = map;
    setStatus(el.masterStatus, `Master database loaded: ${map.size} employees.`, 'ok');
    render();
    el.scanInput.focus();
  } catch (error) {
    setStatus(el.masterStatus, error.message, 'warn');
  }
}

function registerScan() {
  const empNo = sanitizeEmpNo(el.scanInput.value);
  if (!empNo) {
    setStatus(el.scanStatus, 'Scan value is empty.', 'warn');
    return;
  }

  const master = state.masterById.get(empNo);
  const cardName = (el.cardName.value || '').trim();
  const cardGender = normalizeGender(el.cardGender.value);

  const duplicate = state.scans.some((s) => s.empNo === empNo);
  const inactive = master ? !master.active : false;
  const notFound = !master;
  const nameMismatch = !!master && !!cardName && normalizeText(cardName) !== normalizeText(master.empName);
  const genderMismatch = !!master && !!cardGender && cardGender !== master.gender;
  const mismatch = notFound || nameMismatch || genderMismatch;

  const record = {
    row: state.scans.length + 1,
    empNo,
    empName: cardName || master?.empName || '-',
    gender: cardGender || master?.gender || 'Unknown',
    stationId: el.stationId.value,
    scanTime: new Date().toISOString(),
    duplicate,
    inactive,
    mismatch,
    notFound,
    nameMismatch,
    genderMismatch,
  };

  state.scans.push(record);
  persistScans();
  render();

  const statuses = buildStatuses(record).join(', ') || 'OK';
  setStatus(el.scanStatus, `Recorded EMP_NO ${empNo}. Status: ${statuses}.`, mismatch || inactive || duplicate ? 'warn' : 'ok');

  el.scanInput.value = '';
  el.cardName.value = '';
  el.cardGender.value = '';
  el.scanInput.focus();
}

function buildStatuses(record) {
  const tags = [];
  if (record.notFound) tags.push('Not found');
  if (record.nameMismatch) tags.push('Name mismatch');
  if (record.genderMismatch) tags.push('Gender mismatch');
  if (record.inactive) tags.push('Inactive');
  if (record.duplicate) tags.push('Duplicate');
  if (!tags.length) tags.push('Matched');
  return tags;
}

function render() {
  renderStats();
  renderTable();
}

function renderStats() {
  const uniqueEmp = new Set(state.scans.map((s) => s.empNo));
  const male = state.scans.filter((s) => s.gender === 'Male').length;
  const female = state.scans.filter((s) => s.gender === 'Female').length;

  el.totalScans.textContent = String(state.scans.length);
  el.uniqueScans.textContent = String(uniqueEmp.size);
  el.maleCount.textContent = String(male);
  el.femaleCount.textContent = String(female);
  el.mismatchCount.textContent = String(state.scans.filter((s) => s.mismatch).length);
  el.inactiveCount.textContent = String(state.scans.filter((s) => s.inactive).length);
  el.duplicateCount.textContent = String(state.scans.filter((s) => s.duplicate).length);
}

function renderTable() {
  const rowsHtml = [...state.scans].reverse().map((record) => {
    const statuses = buildStatuses(record).map((status) => {
      const cls = status === 'Matched' ? 'ok' : (status === 'Duplicate' || status === 'Inactive' ? 'warn' : 'bad');
      return `<span class="badge ${cls}">${escapeHtml(status)}</span>`;
    }).join('');

    return `<tr>
      <td>${record.row}</td>
      <td>${escapeHtml(record.empNo)}</td>
      <td>${escapeHtml(record.empName)}</td>
      <td>${escapeHtml(record.gender)}</td>
      <td>${escapeHtml(record.stationId)}</td>
      <td>${new Date(record.scanTime).toLocaleString()}</td>
      <td>${statuses}</td>
    </tr>`;
  }).join('');

  el.recordsBody.innerHTML = rowsHtml || '<tr><td colspan="7">No records yet.</td></tr>';
}

function exportCsv() {
  if (!state.scans.length) {
    setStatus(el.scanStatus, 'No records to export.', 'warn');
    return;
  }

  const header = ['Row', 'EMP_NO', 'EMP_NAME', 'Gender', 'StationID', 'ScanTime', 'Mismatch', 'Inactive', 'Duplicate', 'NotFound', 'NameMismatch', 'GenderMismatch'];
  const lines = [header.join(',')];

  for (const s of state.scans) {
    const row = [
      s.row,
      s.empNo,
      s.empName,
      s.gender,
      s.stationId,
      s.scanTime,
      s.mismatch,
      s.inactive,
      s.duplicate,
      s.notFound,
      s.nameMismatch,
      s.genderMismatch,
    ].map(csvEscape);
    lines.push(row.join(','));
  }

  const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `employee_scans_${new Date().toISOString().replace(/[:.]/g, '-')}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
  setStatus(el.scanStatus, 'Scans exported to CSV.', 'ok');
}

function loadScans() {
  try {
    const raw = localStorage.getItem(STORAGE_SCANS);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function persistScans() {
  localStorage.setItem(STORAGE_SCANS, JSON.stringify(state.scans));
}

function parseCsv(text) {
  if (!text) return [];
  const lines = text.split(/\r?\n/).filter((line) => line.trim());
  if (lines.length < 2) return [];

  const headers = splitCsvLine(lines[0]).map((h) => h.trim());
  const rows = [];

  for (let i = 1; i < lines.length; i++) {
    const values = splitCsvLine(lines[i]);
    const row = {};
    headers.forEach((header, idx) => {
      row[header] = (values[idx] || '').trim();
    });
    rows.push(row);
  }
  return rows;
}

function splitCsvLine(line) {
  const out = [];
  let current = '';
  let quoted = false;

  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (quoted && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        quoted = !quoted;
      }
      continue;
    }
    if (ch === ',' && !quoted) {
      out.push(current);
      current = '';
      continue;
    }
    current += ch;
  }
  out.push(current);
  return out;
}

function normalizeActive(value) {
  if (value == null || String(value).trim() === '') return true;
  const v = String(value).trim().toLowerCase();
  return !['0', 'false', 'inactive', 'no', 'n'].includes(v);
}

function normalizeGender(value) {
  const v = String(value || '').trim().toLowerCase();
  if (v === 'male' || v === 'm') return 'Male';
  if (v === 'female' || v === 'f') return 'Female';
  return '';
}

function sanitizeEmpNo(value) {
  return String(value || '').trim().replace(/\s+/g, '');
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase().replace(/\s+/g, ' ');
}

function csvEscape(value) {
  const text = String(value ?? '');
  if (/[",\n]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
  return text;
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function setStatus(node, msg, type = '') {
  node.textContent = msg;
  node.className = `status ${type}`.trim();
}
