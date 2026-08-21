object FormChangeTableName: TFormChangeTableName
  Left = 0
  Top = 0
  Caption = 'Change Name'
  ClientHeight = 243
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 56
    Top = 48
    Width = 66
    Height = 13
    Caption = 'Current name'
  end
  object Label2: TLabel
    Left = 56
    Top = 96
    Width = 50
    Height = 13
    Caption = 'New name'
  end
  object EditCurrentName: TEdit
    Left = 184
    Top = 45
    Width = 233
    Height = 21
    TabStop = False
    ParentColor = True
    ReadOnly = True
    TabOrder = 1
    Text = 'EditCurrentName'
  end
  object EditNewName: TEdit
    Left = 184
    Top = 93
    Width = 233
    Height = 21
    TabOrder = 0
    Text = 'EditNewName'
    OnKeyPress = EditNewNameKeyPress
  end
  object BitBtnOK: TBitBtn
    Left = 96
    Top = 160
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtnCancel: TBitBtn
    Left = 256
    Top = 160
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
end
