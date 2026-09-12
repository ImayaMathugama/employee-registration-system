/* Power Query M script to combine station CSV files in a folder, merge with MasterDB table in the workbook, and add flags.

Replace the folder path in Folder.Files("PUT_YOUR_SCAN_FOLDER_HERE") with your UNC or local folder path, e.g. "\\\\SERVER\\\\Scans" or "C:\\Users\\<user>\\OneDrive\\Scans".

Load this in Power Query (Data -> Get Data -> From Other Sources -> Blank Query -> Advanced Editor) and replace the code or create From Folder and adjust steps as needed.
*/

let
    Source = Folder.Files("PUT_YOUR_SCAN_FOLDER_HERE"),
    CSVFiles = Table.SelectRows(Source, each Text.EndsWith([Name], "_log.csv")),
    TransformFile = Table.AddColumn(CSVFiles, "Imported", each Csv.Document(File.Contents([Folder Path] & [Name]), [Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None])),
    Expand = Table.ExpandTableColumn(TransformFile, "Imported", {"Column1", "Column2", "Column3", "Column4"}, {"EMP_NO", "ScanTime", "StationID", "ComputerName"}),
    ChangeType = Table.TransformColumnTypes(Expand, {{"EMP_NO", type text}, {"ScanTime", type datetime}, {"StationID", type text}, {"ComputerName", type text}}),
    // MasterDB is an Excel table in the workbook named MasterDB
    Master = Excel.CurrentWorkbook(){[Name="MasterDB"]}[Content],
    MasterTyped = Table.TransformColumnTypes(Master, {{"EMP_NO", type text}, {"EMP_NAME", type text}, {"Gender", type text}, {"Active", type text}}),
    Merged = Table.NestedJoin(ChangeType, {"EMP_NO"}, MasterTyped, {"EMP_NO"}, "Master", JoinKind.LeftOuter),
    Expanded = Table.ExpandTableColumn(Merged, "Master", {"EMP_NAME", "Gender", "Active"}, {"Master_EMP_NAME", "Master_Gender", "Active"}),
    AddMismatch = Table.AddColumn(Expanded, "MismatchFlag", each if [Master_EMP_NAME] = null then "NotFound" else null),
    AddInactive = Table.AddColumn(AddMismatch, "InactiveFlag", each if [Active] = null then null else if Text.Lower(Text.From([Active])) = "no" or Text.Lower(Text.From([Active])) = "false" then "Inactive" else null)
in
    AddInactive
