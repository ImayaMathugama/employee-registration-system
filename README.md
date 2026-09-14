# Employee Registration System

This repository now includes a browser-based **HTML/CSS/JavaScript** employee registration system for barcode-based check-in.

## Quick start (HTML/CSS version)

1. Open `/home/runner/work/employee-registration-system/employee-registration-system/index.html` in a browser.
2. Load your master database CSV (or click **Load sample data**).
3. Click **Apply master data**.
4. Select the station (`Station01` ... `Station12`).
5. Scan employee ID cards into the **Barcode / EMP_NO** field.

## Features

- One scan input cell for barcode reader input
- Real-time totals: total scans, unique employees, male, female
- Flags for:
  - employee not found / mismatch with master database
  - inactive employees (using `Active` column)
  - duplicate scans
- Full scan log table with timestamp and station ID
- CSV export of all scan records
- Browser persistence (saved in local storage)

## Master CSV format

Required headers:

- `EMP_NO`
- `EMP_NAME`
- `Gender`

Optional header:

- `Active` (`Active/Inactive`, `True/False`, `1/0`, etc.)

Example:

```csv
EMP_NO,EMP_NAME,Gender,Active
81017,J.K. Ranasinghe,Male,Active
100013,K.P.G.U. K.P.G. Udaya Kumara,Female,Active
```

## Multi-station note

This UI captures `StationID` per scan and works immediately for single-browser usage. For strict no-loss synchronization across 12 laptops, connect this front end to a shared central backend/database API so all stations write to the same source of truth.

---

Legacy Excel/VBA assets are still included in the repository (`*.bas`, `*.frm`, Power Query and setup docs) if you need the original workbook workflow.
