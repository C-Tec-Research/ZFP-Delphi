object FormNewFile: TFormNewFile
  Left = 0
  Top = 0
  Caption = 'New...'
  ClientHeight = 243
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 80
    Width = 56
    Height = 13
    Caption = 'Table Name'
  end
  object LabelBasedOn: TLabel
    Left = 48
    Top = 120
    Width = 46
    Height = 13
    Caption = 'Based On'
  end
  object EditTableName: TEdit
    Left = 144
    Top = 77
    Width = 209
    Height = 21
    TabOrder = 0
    Text = 'EditTableName'
    OnChange = EditTableNameChange
    OnKeyPress = EditTableNameKeyPress
  end
  object BitBtnOK: TBitBtn
    Left = 96
    Top = 160
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtnCancel: TBitBtn
    Left = 256
    Top = 160
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
  object ComboBoxBasedOn: TComboBox
    Left = 144
    Top = 117
    Width = 209
    Height = 21
    Style = csDropDownList
    TabOrder = 3
  end
end
