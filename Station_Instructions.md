StationInput setup (create StationInput.xlsm)

1) Create new Macro-Enabled Workbook
   - Excel -> New -> Save As -> StationInput.xlsm (Excel Macro-Enabled Workbook)

2) Create Config sheet
   - Add a worksheet named Config.
   - Enter these cells:
       A1: StationID    | B1: Station01   (change per station to Station01..Station12, each station must be unique)
       A2: ScanFolder   | B2: PUT_YOUR_SCAN_FOLDER_HERE
   - Save workbook.

3) Add a UserForm
   - Press Alt+F11 to open VBA Editor.
   - Insert -> UserForm. Name it frmScanner (in Properties).
   - Add a TextBox named txtScan, and a Label named lblStatus.
   - Set UserForm ShowModal = False.

4) Import the VBA modules/code
   - Insert -> Module and paste the contents of StationInput_Module.bas (this repo file).
   - In the frmScanner code window paste frmScanner_code.frm contents.
   - In ThisWorkbook paste ThisWorkbook_code.bas contents.

5) Save and test
   - Save StationInput.xlsm.
   - Configure Config!B1 (StationID) and Config!B2 (ScanFolder) to the shared folder you will use.
   - Open the workbook (enable macros). A small scanner form should appear. Scan a barcode (or type a number and press Enter). Confirm a CSV file appears in the ScanFolder named Station01_log.csv with the scanned row.

6) Copy to other stations
   - Copy StationInput.xlsm to the other laptops. On each one edit Config!B1 to set the correct StationID (Station02..Station12).
   - Use one shared ScanFolder path for all 12 laptops so Aggregator reads all scans from one location.

Notes
- The macro writes to StationXX_log.csv in the configured ScanFolder. If network is down, it writes to a local PendingScans folder and appends pending records to StationXX_log.csv when connectivity returns.
- Ensure your barcode reader is configured to send an Enter/CR after scanning (test by scanning into Notepad).
