object FormDissociation: TFormDissociation
  Left = 0
  Top = 0
  Caption = 'Disassociation'
  ClientHeight = 318
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 33
    Height = 16
    Caption = 'Error'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object MemoNotes: TMemo
    Left = 16
    Top = 32
    Width = 513
    Height = 81
    Lines.Strings = (
      
        'You are attempting to remove the association between a panel and' +
        ' a zone but there are devices on the '
      'panel that use this zone. This is not permitted.'
      ''
      'You may do one of the following:')
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object RadioGroupCorrection: TRadioGroup
    Left = 16
    Top = 128
    Width = 513
    Height = 137
    Caption = 'Corrective Action'
    ItemIndex = 0
    Items.Strings = (
      
        'Move all devices in this zone on this panel to a different zone ' +
        '(recommended)'
      'Show Errors'
      'Abort')
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 200
    Top = 280
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
end
