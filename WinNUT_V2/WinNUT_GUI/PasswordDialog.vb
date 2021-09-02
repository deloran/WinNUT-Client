' WinNUT is a NUT windows client for monitoring your ups hooked up to your favorite linux server.
' Copyright (C) 2019-2021 Gawindx (Decaux Nicolas)
'
' This program is free software: you can redistribute it and/or modify it under the terms of the
' GNU General Public License as published by the Free Software Foundation, either version 3 of the
' License, or any later version.
'
' This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY

Public Class PasswordDialog
    Private _parentForm As Form
    Public Sub New(parentForm As Form)
        MyBase.New()
        InitializeComponent()

        _parentForm = parentForm
    End Sub
    Private Sub PasswordDialog_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Left = _parentForm.Left + (_parentForm.Width - Width) / 2
        Me.Top = _parentForm.Top + (_parentForm.Height - Height) / 2
        Tb_Password.Select()
    End Sub

    Private Sub Tb_Password_KeyDown(sender As Object, e As KeyEventArgs) Handles Tb_Password.KeyDown
        If e.KeyCode = Keys.Enter Then
            DialogResult = DialogResult.OK
        ElseIf e.KeyCode = Keys.Escape Then
            DialogResult = DialogResult.Cancel
        End If
    End Sub
End Class
