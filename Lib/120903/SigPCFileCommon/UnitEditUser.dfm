object FormEditUser: TFormEditUser
  Left = 0
  Top = 0
  Caption = 'Edit User'
  ClientHeight = 386
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormClick
  PixelsPerInch = 96
  TextHeight = 13
  object LabelName: TLabel
    Left = 88
    Top = 48
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 416
    Top = 24
    Width = 62
    Height = 13
    Caption = 'User Options'
  end
  object SpeedButtonChangePassword: TSpeedButton
    Left = 88
    Top = 272
    Width = 185
    Height = 33
    Caption = 'Change Password ...'
    OnClick = SpeedButtonChangePasswordClick
  end
  object EditName: TEdit
    Left = 152
    Top = 45
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'EditName'
  end
  object CheckListBoxOptions: TCheckListBox
    Left = 352
    Top = 40
    Width = 233
    Height = 265
    ItemHeight = 13
    TabOrder = 1
  end
  object GroupBoxChimes: TGroupBox
    Left = 88
    Top = 88
    Width = 185
    Height = 161
    Caption = 'Chimes'
    TabOrder = 2
    object RadioButtonNoChimes: TRadioButton
      Left = 24
      Top = 24
      Width = 113
      Height = 17
      Caption = 'No Chimes'
      TabOrder = 0
      OnClick = RadioButtonNoChimesClick
    end
    object RadioButton1Chime: TRadioButton
      Left = 24
      Top = 48
      Width = 113
      Height = 17
      Caption = '1 Chime'
      TabOrder = 1
      OnClick = RadioButton1ChimeClick
    end
    object RadioButton2Chimes: TRadioButton
      Left = 24
      Top = 72
      Width = 113
      Height = 17
      Caption = '2 Chimes'
      TabOrder = 2
      OnClick = RadioButton2ChimesClick
    end
    object RadioButton3Chimes: TRadioButton
      Left = 24
      Top = 96
      Width = 113
      Height = 17
      Caption = '3 Chimes'
      TabOrder = 3
      OnClick = RadioButton3ChimesClick
    end
    object RadioButtonAsUnregulated: TRadioButton
      Left = 24
      Top = 119
      Width = 158
      Height = 17
      Caption = 'Same as Unregulated User'
      Checked = True
      TabOrder = 4
      TabStop = True
    end
  end
  object BitBtnCancel: TBitBtn
    Left = 336
    Top = 328
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object BitBtnOK: TBitBtn
    Left = 223
    Top = 328
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 4
  end
end
