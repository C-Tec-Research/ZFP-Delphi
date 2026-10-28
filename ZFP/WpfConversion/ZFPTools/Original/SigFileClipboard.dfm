object FormSigFileClipboard: TFormSigFileClipboard
  Left = 0
  Top = 0
  Caption = 'SigFile Clipboard'
  ClientHeight = 341
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 643
    Height = 259
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 264
    ExplicitTop = 80
    ExplicitWidth = 185
    ExplicitHeight = 41
    object MemoClipboard: TMemo
      Left = 1
      Top = 1
      Width = 641
      Height = 257
      Align = alClient
      ReadOnly = True
      TabOrder = 0
      ExplicitLeft = 192
      ExplicitTop = 104
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 643
    Height = 41
    Align = alTop
    TabOrder = 1
    ExplicitLeft = 272
    ExplicitTop = 88
    ExplicitWidth = 185
  end
  object Panel3: TPanel
    Left = 0
    Top = 300
    Width = 643
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitLeft = 280
    ExplicitTop = 96
    ExplicitWidth = 185
    object BitBtnDone: TBitBtn
      Left = 280
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Done'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
  end
end
