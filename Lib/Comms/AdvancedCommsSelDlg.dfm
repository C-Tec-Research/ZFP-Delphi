object DlgSelCommPort: TDlgSelCommPort
  Left = 0
  Top = 0
  Caption = 'Select Comms Port'
  ClientHeight = 204
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LabelError: TLabel
    Left = 24
    Top = 56
    Width = 169
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = 'No Ports available!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object RadioGroupCommsPorts: TRadioGroup
    Left = 24
    Top = 8
    Width = 169
    Height = 129
    Caption = 'Comms Ports'
    TabOrder = 0
  end
  object BitBtnOK: TBitBtn
    Left = 24
    Top = 159
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtnCancel: TBitBtn
    Left = 118
    Top = 159
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
end
