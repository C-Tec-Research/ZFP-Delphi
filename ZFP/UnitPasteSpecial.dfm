object FormPasteSpecial: TFormPasteSpecial
  Left = 0
  Top = 0
  Caption = 'Paste Special'
  ClientHeight = 303
  ClientWidth = 527
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
  object CheckBoxAutoIncInput: TCheckBox
    Left = 72
    Top = 40
    Width = 97
    Height = 17
    Caption = 'Auto Inc Input'
    TabOrder = 0
    OnClick = CheckBoxAutoIncInputClick
  end
  object CheckBoxAutoIncOutput: TCheckBox
    Left = 72
    Top = 63
    Width = 97
    Height = 17
    Caption = 'Auto Inc Output'
    TabOrder = 1
  end
  object RadioGroupRepeat: TRadioGroup
    Left = 72
    Top = 104
    Width = 417
    Height = 137
    Caption = 'Repeat'
    ItemIndex = 0
    Items.Strings = (
      'Fixed number of times'
      'Until List Exhausted'
      'Until Object Found or List Exhausted')
    TabOrder = 2
  end
  object SigSpinEditFixedTimes: TSigSpinEdit
    Left = 296
    Top = 128
    Width = 65
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxValue = 0
    MinValue = 0
    ParentFont = False
    TabOrder = 3
    Value = 1
    OnChange = SigSpinEditFixedTimesChange
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
  object BitBtnObject: TBitBtn
    Left = 296
    Top = 204
    Width = 177
    Height = 25
    Caption = '<Select>'
    TabOrder = 4
    OnClick = BitBtnObjectClick
  end
  object BitBtnOK: TBitBtn
    Left = 160
    Top = 256
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 5
  end
  object BitBtn2: TBitBtn
    Left = 304
    Top = 256
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 6
  end
end
