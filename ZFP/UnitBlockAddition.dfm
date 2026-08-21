object FormBlockAddition: TFormBlockAddition
  Left = 0
  Top = 0
  Caption = 'Block Addition'
  ClientHeight = 207
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
    Left = 32
    Top = 32
    Width = 74
    Height = 13
    Caption = 'Name Template'
  end
  object Label2: TLabel
    Left = 32
    Top = 72
    Width = 155
    Height = 13
    Caption = 'Replace <n> with numbers from'
  end
  object Label3: TLabel
    Left = 303
    Top = 72
    Width = 10
    Height = 13
    Caption = 'to'
  end
  object EditName: TEdit
    Left = 224
    Top = 29
    Width = 249
    Height = 21
    TabOrder = 0
    Text = 'EditName'
    OnKeyPress = EditNameKeyPress
  end
  object SigSpinEditFrom: TSigSpinEdit
    Left = 224
    Top = 69
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = clWindowText
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    ErrorFont.Charset = DEFAULT_CHARSET
    ErrorFont.Color = clWindowText
    ErrorFont.Height = -11
    ErrorFont.Name = 'Tahoma'
    ErrorFont.Style = []
  end
  object SigSpinEditTo: TSigSpinEdit
    Left = 336
    Top = 69
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
    NormalFont.Charset = DEFAULT_CHARSET
    NormalFont.Color = clWindowText
    NormalFont.Height = -11
    NormalFont.Name = 'Tahoma'
    NormalFont.Style = []
    ErrorFont.Charset = DEFAULT_CHARSET
    ErrorFont.Color = clWindowText
    ErrorFont.Height = -11
    ErrorFont.Name = 'Tahoma'
    ErrorFont.Style = []
  end
  object BitBtn1: TBitBtn
    Left = 144
    Top = 128
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 3
  end
  object BitBtn2: TBitBtn
    Left = 304
    Top = 128
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 4
  end
end
