' StationInput VBA Module
' Paste this code into a standard module in StationInput.xlsm (Alt+F11 -> Insert -> Module)
Option Explicit

Public Function GetConfigValue(key As String) As String
    On Error Resume Next
    Dim sh As Worksheet: Set sh = ThisWorkbook.Worksheets("Config")
    If sh Is Nothing Then Exit Function
    Dim f As Range
    Set f = sh.Range("A:A").Find(What:=key, LookAt:=xlWhole, LookIn:=xlValues)
    If Not f Is Nothing Then
        GetConfigValue = Trim(sh.Cells(f.Row, 2).Value)
    End If
End Function

Public Sub AppendScanToCSV(empNo As String)
    On Error GoTo ErrHandler
    Dim folderPath As String
    folderPath = GetConfigValue("ScanFolder")
    If folderPath = "" Then folderPath = ThisWorkbook.Path & Application.PathSeparator
    If Right(folderPath, 1) <> "\" And Right(folderPath, 1) <> "/" Then folderPath = folderPath & "\"
    Dim stationID As String
    stationID = GetConfigValue("StationID")
    If stationID = "" Then stationID = Environ("COMPUTERNAME")
    Dim fileName As String
    fileName = folderPath & stationID & "_log.csv"
    
    Dim ts As String
    ts = Format(Now, "yyyy-mm-dd HH:nn:ss")
    Dim userComp As String
    userComp = Environ("COMPUTERNAME")
    
    Dim line As String
    ' CSV columns: EMP_NO, ScanTime, StationID, ComputerName
    line = """" & Replace(empNo, """", """""") & ""","""" & ts & ""","""" & Replace(stationID, """", """""") & ""","""" & Replace(userComp, """", """""") & """"
    
    Dim fnum As Integer
    fnum = FreeFile
    Dim success As Boolean
    success = False
    On Error Resume Next
    Open fileName For Append As #fnum
    If Err.Number = 0 Then
        Print #fnum, line
        Close #fnum
        success = True
    Else
        Err.Clear
        Dim localFolder As String
        localFolder = ThisWorkbook.Path & "\PendingScans\"
        If Dir(localFolder, vbDirectory) = "" Then MkDir localFolder
        Dim localFile As String
        localFile = localFolder & stationID & "_pending.csv"
        fnum = FreeFile
        Open localFile For Append As #fnum
        Print #fnum, line
        Close #fnum
        success = False
    End If
    On Error GoTo 0
    
    If frmScanner.Visible Then
        frmScanner.txtScan.Text = ""
        frmScanner.txtScan.SetFocus
        If success Then
            frmScanner.lblStatus.Caption = "Saved: " & empNo & " @ " & ts
        Else
            frmScanner.lblStatus.Caption = "Saved locally (network down)."
        End If
    End If
    
    Exit Sub
ErrHandler:
    Resume Next
End Sub

Public Sub FlushPendingToServer()
    On Error Resume Next
    Dim folderPath As String
    folderPath = GetConfigValue("ScanFolder")
    If folderPath = "" Then folderPath = ThisWorkbook.Path & Application.PathSeparator
    If Right(folderPath, 1) <> "\" And Right(folderPath, 1) <> "/" Then folderPath = folderPath & "\"
    Dim localFolder As String
    localFolder = ThisWorkbook.Path & "\PendingScans\"
    If Dir(localFolder, vbDirectory) = "" Then Exit Sub
    Dim fso As Object: Set fso = CreateObject("Scripting.FileSystemObject")
    Dim f As Object
    For Each f In fso.GetFolder(localFolder).Files
        Dim dest As String
        dest = folderPath & f.Name
        On Error Resume Next
        f.Copy dest
        If Err.Number = 0 Then
            f.Delete True
        End If
    Next
End Sub
