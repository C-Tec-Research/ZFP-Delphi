object FormThreadsafeTest: TFormThreadsafeTest
  Left = 0
  Top = 0
  Caption = 'FormThreadsafeTest'
  ClientHeight = 266
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
  object MemoTest: TMemo
    Left = 48
    Top = 24
    Width = 425
    Height = 177
    Lines.Strings = (
      'MemoTest')
    TabOrder = 0
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 136
    Top = 208
  end
  object Timer2: TTimer
    Interval = 1003
    OnTimer = Timer1Timer
    Left = 248
    Top = 208
  end
end
