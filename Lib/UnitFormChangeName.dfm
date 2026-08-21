object FormName: TFormName
  Left = 0
  Top = 0
  Caption = 'Name'
  ClientHeight = 125
  ClientWidth = 403
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
    Left = 16
    Top = 21
    Width = 67
    Height = 13
    Caption = 'Current Name'
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 51
    Height = 13
    Caption = 'New Name'
  end
  object EditCurrentName: TEdit
    Left = 208
    Top = 18
    Width = 177
    Height = 21
    TabStop = False
    ParentColor = True
    ReadOnly = True
    TabOrder = 3
    Text = 'EditCurrentName'
  end
  object EditNewName: TEdit
    Left = 208
    Top = 45
    Width = 177
    Height = 21
    TabOrder = 0
    Text = 'EditNewName'
  end
  object BitBtn1: TBitBtn
    Left = 96
    Top = 80
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 224
    Top = 80
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
  object EditCurrentPrefix: TEdit
    Left = 89
    Top = 18
    Width = 120
    Height = 21
    TabStop = False
    Alignment = taRightJustify
    ParentColor = True
    ReadOnly = True
    TabOrder = 4
    Text = 'EditCurrentName'
  end
  object EditNewPrefix: TEdit
    Left = 89
    Top = 45
    Width = 120
    Height = 21
    TabStop = False
    Alignment = taRightJustify
    ParentColor = True
    ReadOnly = True
    TabOrder = 5
    Text = 'EditNewPrefix'
  end
end
