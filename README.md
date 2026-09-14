# Employee Registration System

This repository contains the code and assets to build the Excel-based employee registration system described in the issue. It includes VBA modules, Power Query M, and setup instructions so you can create the StationInput (.xlsm) workbooks and the Aggregator (.xlsm) workbook locally.

Important: Because this environment cannot generate binary Excel (.xlsm) files directly, the repository provides the ready-to-paste VBA modules, Power Query M, a sample MasterDB CSV and detailed instructions. Follow the instructions to paste the VBA into new macro-enabled workbooks (.xlsm) and configure them.

Files included:
- StationInput_Module.bas          — VBA module for station workbook (append scans, write headers, flush pending)
- frmScanner_code.frm             — UserForm code for scanner input
- ThisWorkbook_code.bas           — Workbook_Open code to show the form and flush pending items
- Station_Config_Station01.txt ... Station_Config_Station12.txt — Config templates for 12 stations
- Aggregator_PowerQuery_M.pq      — Power Query M script to combine station CSVs, detect duplicates and merge with MasterDB
- Aggregator_AutoRefresh.bas      — VBA module for Aggregator auto-refresh (30s)
- MasterDB_sample.csv             — Sample master database rows you provided
- Aggregator_Instructions.md      — Step-by-step to create Aggregator workbook and dashboard
- Station_Instructions.md        — Step-by-step to create StationInput workbook(s)

Next steps (short):
1. Download this repo.
2. Create a new Excel Macro-Enabled Workbook for StationInput.xlsm; import the modules and UserForm code from the files in this repo, create Config sheet and save.
3. Repeat for Station01..Station12 (or copy the template and edit the Config!StationID cell).
4. Create Aggregator.xlsm, import Power Query M (From Folder -> Advanced Editor) and the AutoRefresh module, paste your full MasterDB into sheet MasterDB, and load the CombinedScans query to a Scans table. Configure ScanFolder placeholder.
5. Build the Dashboard sheet with cards/charts for Total scans, Registered, Duplicates, Male/Female, Inactive and Mismatches.
6. Export the Scans table to CSV when needed (instructions included in Aggregator_Instructions.md).

If you want, I can also:
- Create the 12 preconfigured .xlsm binaries and upload them for you (I can produce them and add them to the repo) — confirm and I will generate them next.
