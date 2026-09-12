' ThisWorkbook code for StationInput.xlsm
' Paste into the ThisWorkbook module
Option Explicit

Private Sub Workbook_Open()
    On Error Resume Next
    frmScanner.Show vbModeless
    FlushPendingToServer
End Sub
