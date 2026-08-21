object FormReplace: TFormReplace
  Left = 0
  Top = 0
  Caption = 'Replace...'
  ClientHeight = 338
  ClientWidth = 335
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
  object Label1: TLabel
    Left = 32
    Top = 32
    Width = 74
    Height = 19
    Caption = 'Warning:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 32
    Top = 72
    Width = 143
    Height = 13
    Caption = 'You are attempting to replace'
  end
  object Label3: TLabel
    Left = 32
    Top = 128
    Width = 12
    Height = 13
    Caption = 'By'
  end
  object Label4: TLabel
    Left = 32
    Top = 208
    Width = 167
    Height = 13
    Caption = 'Do you really want to do this?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SigImageReplace: TSigImage
    Left = 208
    Top = 64
    Width = 32
    Height = 32
  end
  object SigImageReplaceBy: TSigImage
    Left = 208
    Top = 120
    Width = 32
    Height = 32
  end
  object LabelAddress: TLabel
    Left = 32
    Top = 176
    Width = 39
    Height = 13
    Caption = 'Address'
  end
  object Label5: TLabel
    Left = 32
    Top = 227
    Width = 293
    Height = 13
    Caption = '(Note - this will reset device fields to default values)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object CheckBoxRememberAnswer: TCheckBox
    Left = 32
    Top = 256
    Width = 329
    Height = 17
    Caption = 'Remember my answer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 32
    Top = 296
    Width = 75
    Height = 25
    Kind = bkYes
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 181
    Top = 296
    Width = 75
    Height = 25
    Kind = bkNo
    NumGlyphs = 2
    TabOrder = 2
  end
end
