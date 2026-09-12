' frmScanner UserForm code
' Paste this into the UserForm code (frmScanner) in the StationInput.xlsm VBA project
Option Explicit

Private Sub UserForm_Activate()
    Me.txtScan.SetFocus
End Sub

Private Sub txtScan_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    If KeyAscii = 13 Then
        Dim scanned As String
        scanned = Trim(Me.txtScan.Text)
        If scanned <> "" Then
            AppendScanToCSV scanned
        End If
        Me.txtScan.Text = ""
        KeyAscii = 0
    End If
End Sub

Private Sub UserForm_Initialize()
    Me.lblStatus.Caption = ""
    Me.txtScan.SetFocus
End Sub
