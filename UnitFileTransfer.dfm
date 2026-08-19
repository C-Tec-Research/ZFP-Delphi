object FormFileTransfer: TFormFileTransfer
  Left = 0
  Top = 0
  Caption = 'FormFileTransfer'
  ClientHeight = 267
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    527
    267)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxFileNameOnPC: TGroupBox
    Left = 32
    Top = 24
    Width = 457
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = 'File Name On PC'
    TabOrder = 0
    object SpeedButtonBrowse: TSpeedButton
      Left = 359
      Top = 24
      Width = 82
      Height = 22
      Caption = 'Browse...'
      OnClick = SpeedButtonBrowseClick
    end
    object EditFileNameOnPC: TEdit
      Left = 16
      Top = 24
      Width = 337
      Height = 21
      TabOrder = 0
      Text = 'EditFileNameOnPC'
      OnChange = EditFileNameOnPCChange
    end
  end
  object BitBtn1: TBitBtn
    Left = 152
    Top = 231
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 273
    Top = 231
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
  end
  object RadioGroupFileNameOnPanel: TRadioGroup
    Left = 32
    Top = 95
    Width = 457
    Height = 105
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'File Name On Panel'
    TabOrder = 3
  end
  object SigSaveDialogTransfer: TSigSaveDialog
    Filter = 'All Files (*.*)|*.*'
    Left = 472
    Top = 72
  end
end
