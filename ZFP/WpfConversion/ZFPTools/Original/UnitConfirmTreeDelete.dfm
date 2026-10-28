object FormConfirmCETreeDelete: TFormConfirmCETreeDelete
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Confirm Deletion from CE Tree'
  ClientHeight = 340
  ClientWidth = 484
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
    Width = 47
    Height = 13
    Caption = 'Warning'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 32
    Top = 64
    Width = 285
    Height = 13
    Caption = 'This action will also delete the entry from the main CE Tree.'
  end
  object Label3: TLabel
    Left = 32
    Top = 96
    Width = 207
    Height = 13
    Caption = 'It may also possibly lead to an Invalid tree.'
  end
  object RadioGroupPruneParents: TRadioGroup
    Left = 32
    Top = 136
    Width = 401
    Height = 81
    Caption = 'You may..'
    Items.Strings = (
      
        'Just delete this item, even if it leaves an illegal tree (I will' +
        ' correct later)'
      
        'Prune tree to leave a valid tree (may require more effort to cor' +
        'rect later)')
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 72
    Top = 272
    Width = 131
    Height = 25
    Caption = 'Confirm Delete'
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 272
    Top = 272
    Width = 137
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
  object CheckBoxDontAskAgain: TCheckBox
    Left = 40
    Top = 240
    Width = 369
    Height = 17
    Caption = ' Always do this (don'#39't ask me again)'
    TabOrder = 3
  end
end
