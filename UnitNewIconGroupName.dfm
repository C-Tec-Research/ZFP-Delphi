object FormNewIconGroupName: TFormNewIconGroupName
  Left = 0
  Top = 0
  Caption = 'New Icon Group Name'
  ClientHeight = 138
  ClientWidth = 357
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
    Left = 32
    Top = 32
    Width = 83
    Height = 13
    Caption = 'New Group Name'
  end
  object BitBtnOK: TBitBtn
    Left = 72
    Top = 72
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object BitBtnCancel: TBitBtn
    Left = 208
    Top = 72
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object EditGroupName: TEdit
    Left = 136
    Top = 32
    Width = 147
    Height = 21
    TabOrder = 2
    Text = 'EditGroupName'
    OnChange = EditGroupNameChange
  end
end
