object FormEditArea: TFormEditArea
  Left = 0
  Top = 0
  Caption = 'Edit Area'
  ClientHeight = 393
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
  object LabelAreaName: TLabel
    Left = 112
    Top = 43
    Width = 53
    Height = 13
    Caption = 'Area Name'
  end
  object LabelPicture: TLabel
    Left = 112
    Top = 152
    Width = 33
    Height = 13
    Caption = 'Picture'
  end
  object SpeedButtonBrowse: TSpeedButton
    Left = 392
    Top = 303
    Width = 89
    Height = 22
    Caption = 'Browse...'
  end
  object EditAreaName: TEdit
    Left = 264
    Top = 40
    Width = 233
    Height = 21
    TabOrder = 0
    Text = 'EditAreaName'
    OnChange = EditAreaNameChange
  end
  object RadioGroupStyle: TRadioGroup
    Left = 112
    Top = 80
    Width = 385
    Height = 57
    Caption = 'Style'
    ItemIndex = 0
    Items.Strings = (
      'Normal'
      'Float')
    TabOrder = 1
    OnClick = RadioGroupStyleClick
  end
  object BitBtnOK: TBitBtn
    Left = 200
    Top = 352
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 2
  end
  object BitBtnCancel: TBitBtn
    Left = 344
    Top = 352
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object EditFileName: TEdit
    Left = 151
    Top = 304
    Width = 218
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 4
    Text = 'EditFileName'
  end
  object Panel1: TPanel
    Left = 151
    Top = 152
    Width = 218
    Height = 146
    BevelInner = bvLowered
    BevelWidth = 2
    Caption = 'No Picture Loaded'
    TabOrder = 5
    object ImagePreview: TImage
      Left = 4
      Top = 4
      Width = 210
      Height = 138
      Align = alClient
      Proportional = True
      ExplicitLeft = 9
      ExplicitTop = 8
    end
  end
  object OpenPictureDialogPicture: TOpenPictureDialog
    Left = 512
    Top = 304
  end
end
