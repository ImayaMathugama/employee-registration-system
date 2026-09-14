/* Power Query M script to combine station CSV files in a folder, merge with MasterDB table in the workbook, and add flags.

Replace the folder path in Folder.Files("PUT_YOUR_SCAN_FOLDER_HERE") with your UNC or local folder path, e.g. "\\\\SERVER\\\\Scans" or "C:\\Users\\<user>\\OneDrive\\Scans".

Load this in Power Query (Data -> Get Data -> From Other Sources -> Blank Query -> Advanced Editor) and replace the code or create From Folder and adjust steps as needed.
*/

let
    Source = Folder.Files("PUT_YOUR_SCAN_FOLDER_HERE"),
    CSVFiles = Table.SelectRows(Source, each Text.EndsWith([Name], "_log.csv")),
    TransformFile = Table.AddColumn(CSVFiles, "Imported", each Csv.Document(File.Contents([Folder Path] & [Name]), [Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None])),
    Expand = Table.ExpandTableColumn(TransformFile, "Imported", {"Column1", "Column2", "Column3", "Column4"}, {"EMP_NO", "ScanTime", "StationID", "ComputerName"}),
    RemoveHeaders = Table.SelectRows(Expand, each Text.Upper(Text.Trim(Text.From([EMP_NO]))) <> "EMP_NO"),
    ChangeType = Table.TransformColumnTypes(RemoveHeaders, {{"EMP_NO", type text}, {"ScanTime", type datetime}, {"StationID", type text}, {"ComputerName", type text}}),
    SortedScans = Table.Sort(ChangeType, {{"ScanTime", Order.Ascending}, {"StationID", Order.Ascending}, {"ComputerName", Order.Ascending}}),
    ByEmployee = Table.Group(SortedScans, {"EMP_NO"}, {{"Rows", each Table.AddIndexColumn(_, "ScanSequence", 1, 1, Int64.Type), type table [EMP_NO=nullable text, ScanTime=nullable datetime, StationID=nullable text, ComputerName=nullable text, ScanSequence=number]}}),
    ExpandedScans = Table.ExpandTableColumn(ByEmployee, "Rows", {"ScanTime", "StationID", "ComputerName", "ScanSequence"}, {"ScanTime", "StationID", "ComputerName", "ScanSequence"}),
    AddDuplicateFlag = Table.AddColumn(ExpandedScans, "DuplicateFlag", each if [ScanSequence] > 1 then "Duplicate" else null),
    // MasterDB is an Excel table in the workbook named MasterDB
    Master = Excel.CurrentWorkbook(){[Name="MasterDB"]}[Content],
    MasterAddName = if Table.HasColumns(Master, {"EMP_NAME"}) then Master else Table.AddColumn(Master, "EMP_NAME", each null, type text),
    MasterAddGender = if Table.HasColumns(MasterAddName, {"Gender"}) then MasterAddName else Table.AddColumn(MasterAddName, "Gender", each null, type text),
    MasterAddActive = if Table.HasColumns(MasterAddGender, {"Active"}) then MasterAddGender else Table.AddColumn(MasterAddGender, "Active", each "Yes", type text),
    MasterTyped = Table.TransformColumnTypes(MasterAddActive, {{"EMP_NO", type text}, {"EMP_NAME", type text}, {"Gender", type text}, {"Active", type text}}),
    Merged = Table.NestedJoin(AddDuplicateFlag, {"EMP_NO"}, MasterTyped, {"EMP_NO"}, "Master", JoinKind.LeftOuter),
    Expanded = Table.ExpandTableColumn(Merged, "Master", {"EMP_NAME", "Gender", "Active"}, {"Master_EMP_NAME", "Master_Gender", "Active"}),
    AddMismatch = Table.AddColumn(Expanded, "MismatchFlag", each if [Master_EMP_NAME] = null then "NotFound" else null),
    AddInactive = Table.AddColumn(AddMismatch, "InactiveFlag", each if [MismatchFlag] = "NotFound" then null else if [Active] = null then null else if Text.Lower(Text.From([Active])) = "no" or Text.Lower(Text.From([Active])) = "false" or Text.Lower(Text.From([Active])) = "inactive" or Text.From([Active]) = "0" then "Inactive" else null),
    AddStatus = Table.AddColumn(AddInactive, "RegistrationStatus", each if [MismatchFlag] = "NotFound" then "Mismatch" else if [InactiveFlag] = "Inactive" then "Inactive" else "Registered")
in
    AddStatus
