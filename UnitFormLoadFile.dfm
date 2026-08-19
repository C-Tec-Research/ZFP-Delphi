object FormLoadFile: TFormLoadFile
  Left = 0
  Top = 0
  Caption = 'Loading...'
  ClientHeight = 243
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LabelPC: TLabel
    Left = 216
    Top = 128
    Width = 44
    Height = 13
    Caption = 'LabelPC'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ProgressBarLoad: TProgressBar
    Left = 32
    Top = 64
    Width = 433
    Height = 41
    Max = 10000
    TabOrder = 0
  end
  object TimerFinish: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = TimerFinishTimer
    Left = 320
    Top = 184
  end
end
