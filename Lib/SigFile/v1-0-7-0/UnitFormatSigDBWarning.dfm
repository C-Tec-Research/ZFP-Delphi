object FormFormat: TFormFormat
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Format Database'
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
  object MemoFormatWarning: TMemo
    Left = 48
    Top = 24
    Width = 417
    Height = 137
    Alignment = taCenter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Lines.Strings = (
      'Warning'
      ''
      'This operation will erase all data for this '
      'database. This operation is not reversible. '
      ''
      'Are you sure that you wish to proceed?')
    ParentColor = True
    ParentFont = False
    TabOrder = 0
  end
  object BitBtnAbort: TBitBtn
    Left = 160
    Top = 192
    Width = 75
    Height = 25
    Kind = bkAbort
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtnProceed: TBitBtn
    Left = 296
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Proceed'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
end
