object FormFileNotSaved: TFormFileNotSaved
  Left = 0
  Top = 0
  Caption = 'File Not Saved'
  ClientHeight = 137
  ClientWidth = 305
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
  object LabelNotSavedWarning: TLabel
    Left = 48
    Top = 32
    Width = 213
    Height = 13
    Caption = 'The file has not been save. Save Now?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BitBtnYes: TBitBtn
    Left = 32
    Top = 75
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkYes
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object BitBtnNo: TBitBtn
    Left = 120
    Top = 75
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkNo
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object BitBtnCancel: TBitBtn
    Left = 206
    Top = 75
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 2
  end
end
