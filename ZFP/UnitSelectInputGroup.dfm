object FormSelectGlobalObject: TFormSelectGlobalObject
  Left = 0
  Top = 0
  Caption = 'Select Group'
  ClientHeight = 321
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    527
    321)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelTabs: TLabel
    Left = 16
    Top = 22
    Width = 127
    Height = 13
    Caption = 'Select tab for correct type'
  end
  object BitBtn1: TBitBtn
    Left = 120
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
  end
  object BitBtn2: TBitBtn
    Left = 216
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&None'
    Kind = bkNo
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtn3: TBitBtn
    Left = 312
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
  object TabControlObjects: TTabControl
    Left = 16
    Top = 41
    Width = 503
    Height = 233
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = TabControlObjectsChange
    object Panel1: TPanel
      Left = 4
      Top = 6
      Width = 495
      Height = 223
      Align = alClient
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        495
        223)
      object LabelPrompt: TLabel
        Left = 40
        Top = 13
        Width = 118
        Height = 13
        Caption = 'Select from the following'
      end
      object LabelOr: TLabel
        Left = 13
        Top = 165
        Width = 10
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'or'
        ExplicitTop = 147
      end
      object LabelNewPrompt: TLabel
        Left = 40
        Top = 165
        Width = 147
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Type New Name and click '#39'Add'#39
        ExplicitTop = 147
      end
      object LabelNewName: TLabel
        Left = 40
        Top = 184
        Width = 51
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'New Name'
        ExplicitTop = 166
      end
      object SpeedButtonAddIG: TSpeedButton
        Left = 407
        Top = 177
        Width = 66
        Height = 22
        Anchors = [akRight, akBottom]
        Caption = 'Add'
        OnClick = SpeedButtonAddIGClick
        ExplicitTop = 159
      end
      object ListBoxIG: TListBox
        Left = 40
        Top = 32
        Width = 433
        Height = 123
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 0
      end
      object EditNewObject: TEdit
        Left = 112
        Top = 178
        Width = 289
        Height = 21
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 1
        Text = 'EditNewObject'
        OnChange = EditNewObjectChange
      end
    end
  end
end
