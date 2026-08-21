object FormSigFileDebug: TFormSigFileDebug
  Left = 0
  Top = 0
  Caption = 'FormSigFileDebug'
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
    Top = 0
    Width = 643
    Height = 41
    Align = alTop
    TabOrder = 0
    object BitBtnLoad: TBitBtn
      Left = 272
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Load'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = BitBtnLoadClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 643
    Height = 255
    Align = alClient
    TabOrder = 1
  end
  object Panel3: TPanel
    Left = 0
    Top = 296
    Width = 643
    Height = 45
    Align = alBottom
    TabOrder = 2
    object BitBtnDone: TBitBtn
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      DoubleBuffered = True
      Kind = bkClose
      ParentDoubleBuffered = False
      TabOrder = 0
      OnClick = BitBtnDoneClick
    end
  end
end
