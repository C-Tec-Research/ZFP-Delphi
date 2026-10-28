object FormLoadErrors: TFormLoadErrors
  Left = 0
  Top = 0
  Caption = 'Load Errors'
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
  object LabelMsg: TLabel
    Left = 32
    Top = 24
    Width = 248
    Height = 13
    Caption = 'The following error(s) were found when loading file:'
  end
  object MemoLoadErrors: TMemo
    Left = 24
    Top = 56
    Width = 481
    Height = 121
    Lines.Strings = (
      'MemoLoadErrors')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object BitBtnContinue: TBitBtn
    Left = 144
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Continue'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtnAbort: TBitBtn
    Left = 280
    Top = 200
    Width = 75
    Height = 25
    Kind = bkAbort
    NumGlyphs = 2
    TabOrder = 2
  end
end
