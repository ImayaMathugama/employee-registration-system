Aggregator setup (create Aggregator.xlsm)

1) Create new Macro-Enabled Workbook
   - Excel -> New -> Save As -> Aggregator.xlsm

2) Add MasterDB table
   - Create a sheet named MasterDB. Paste your master data with headers EMP_NO, EMP_NAME, Gender, Active (Active recommended: Yes/No).
   - Select the range and Insert -> Table. On Table Design set Table Name = MasterDB.

3) Create CombinedScans query using Power Query
   - Data -> Get Data -> From Other Sources -> Blank Query -> Advanced Editor
   - Paste the M code from Aggregator_PowerQuery_M.pq and change the folder path placeholder PUT_YOUR_SCAN_FOLDER_HERE to your ScanFolder path (e.g. "\\\\SERVER\\\\Scans").
   - Click Done. Verify the query shows columns EMP_NO, ScanTime, StationID, ComputerName, ScanSequence, DuplicateFlag, Master_EMP_NAME, Master_Gender, Active, MismatchFlag, InactiveFlag, RegistrationStatus.

4) Load to worksheet
   - Close & Load To... -> Table -> New Worksheet. Name the sheet ScansTable. In Table Design, set Table Name = Scans.

5) Dashboard
   - Create a sheet named Dashboard and add formulas referencing the Scans table. Example formulas:
       Total scans: =COUNTA(Scans[EMP_NO])
       Registered: =COUNTIF(Scans[RegistrationStatus],"Registered")
       Duplicates: =COUNTIF(Scans[DuplicateFlag],"Duplicate")
       Male: =COUNTIFS(Scans[RegistrationStatus],"Registered",Scans[Master_Gender],"Male")
       Female: =COUNTIFS(Scans[RegistrationStatus],"Registered",Scans[Master_Gender],"Female")
       Mismatches: =COUNTIF(Scans[MismatchFlag],"NotFound")
       Inactive: =COUNTIF(Scans[InactiveFlag],"Inactive")
   - Suggested charts:
       1. Clustered Column: Total vs Registered vs Duplicates.
       2. Doughnut/Pie: Male vs Female.
       3. Column: Mismatches vs Inactive.
       4. Column by Station: pivot chart with StationID in Axis and Count of EMP_NO in Values.

6) Auto Refresh (optional)
   - Insert -> Module and paste Aggregator_AutoRefresh.bas contents.
   - Run StartAutoRefresh to begin periodic refresh every 30s. StopAutoRefresh to stop.

7) Export Scans as CSV
   - Go to ScansTable sheet, click any cell in table Scans.
   - File -> Save As -> CSV UTF-8 (Comma delimited) (*.csv).
   - Save as Employee_Registration_Live.csv (or your preferred file name).
   - This CSV is your live registration output with duplicate/mismatch/inactive flags.

8) Test
   - Place a Station01_log.csv in the ScanFolder (created by station workbook) or perform station scans to generate logs.
   - In Aggregator.xlsm Data -> Refresh All. Verify Scans table populates and Dashboard counts update.

Notes
- For large volumes or cleaner automation, consider Power BI + Power Automate to refresh on new file arrival.
- Keep the Aggregator workbook in a trusted location and enable macros if using auto-refresh.
