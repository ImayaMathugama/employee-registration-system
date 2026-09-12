' Aggregator AutoRefresh VBA module
' Paste into a standard module in Aggregator.xlsm
Option Explicit

Sub AutoRefreshEvery(seconds As Long)
    Application.OnTime Now + TimeSerial(0, 0, seconds), "RefreshQueries"
End Sub

Sub RefreshQueries()
    ThisWorkbook.RefreshAll
    AutoRefreshEvery 30
End Sub

Sub StartAutoRefresh()
    AutoRefreshEvery 30
End Sub

Sub StopAutoRefresh()
    On Error Resume Next
    Application.OnTime EarliestTime:=Now + TimeSerial(0, 0, 30), Procedure:="RefreshQueries", Schedule:=False
End Sub
