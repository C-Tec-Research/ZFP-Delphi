object FormChangeDefaultLogo: TFormChangeDefaultLogo
  Left = 0
  Top = 0
  Caption = 'Change Default Logo'
  ClientHeight = 319
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxLogo: TGroupBox
    Left = 62
    Top = 44
    Width = 185
    Height = 209
    Caption = 'Logo'
    TabOrder = 0
    object ImageLogo: TImage
      Left = 16
      Top = 40
      Width = 150
      Height = 150
      Center = True
      OnClick = ImageLogoClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 256
    Top = 44
    Width = 289
    Height = 209
    Caption = 'WARNING'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    DesignSize = (
      289
      209)
    object Memo1: TMemo
      Left = 16
      Top = 24
      Width = 257
      Height = 65
      TabStop = False
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelEdges = []
      BorderStyle = bsNone
      Ctl3D = False
      Lines.Strings = (
        'This process is not reversible. The current '
        'logo will be overwritten and cannot be '
        'recovered.')
      ParentColor = True
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 0
    end
    object Memo2: TMemo
      Left = 16
      Top = 88
      Width = 257
      Height = 65
      TabStop = False
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelEdges = []
      BorderStyle = bsNone
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Lines.Strings = (
        'Click on the logo to change it.')
      ParentColor = True
      ParentCtl3D = False
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
  end
  object BitBtnOK: TBitBtn
    Left = 192
    Top = 272
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtnCancel: TBitBtn
    Left = 312
    Top = 272
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
  object OpenPictureDialogLogo: TOpenPictureDialog
    Filter = 'GIF Image (*.gif)|*.gif'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 152
    Top = 136
  end
end
