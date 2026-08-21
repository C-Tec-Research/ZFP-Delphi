object FormChangePassword: TFormChangePassword
  Left = 0
  Top = 0
  Caption = 'FormChangePassword'
  ClientHeight = 286
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 128
    Top = 88
    Width = 70
    Height = 13
    Caption = 'New Password'
  end
  object Label2: TLabel
    Left = 128
    Top = 56
    Width = 22
    Height = 13
    Caption = 'User'
  end
  object Label3: TLabel
    Left = 128
    Top = 128
    Width = 92
    Height = 13
    Caption = 'Re-enter Password'
  end
  object EditUserName: TEdit
    Left = 264
    Top = 53
    Width = 121
    Height = 21
    TabStop = False
    ParentColor = True
    ReadOnly = True
    TabOrder = 4
    Text = 'EditUserName'
  end
  object BitBtnOK: TBitBtn
    Left = 112
    Top = 184
    Width = 131
    Height = 25
    Caption = 'Change Password'
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 2
  end
  object BitBtnCancel: TBitBtn
    Left = 296
    Top = 184
    Width = 145
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object MaskEdit1: TMaskEdit
    Left = 264
    Top = 85
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
    Text = 'MaskEdit1'
    OnChange = MaskEdit1Change
  end
  object MaskEdit2: TMaskEdit
    Left = 264
    Top = 125
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    Text = 'MaskEdit2'
    OnChange = MaskEdit1Change
  end
end
