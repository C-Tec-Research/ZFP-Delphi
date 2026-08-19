object FormShortNameAndIconEditor: TFormShortNameAndIconEditor
  Left = 0
  Top = 0
  Caption = 'Short Name And Icon Editor'
  ClientHeight = 400
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 410
    Top = 73
    Width = 233
    Height = 272
    Align = alRight
    TabOrder = 0
    object LabelSubDeviceIcon: TLabel
      Left = 16
      Top = 24
      Width = 21
      Height = 13
      Caption = 'Icon'
    end
    object ImageSubDevice: TImage
      Left = 112
      Top = 24
      Width = 32
      Height = 32
    end
    object Label43: TLabel
      Left = 16
      Top = 56
      Width = 47
      Height = 13
      Caption = 'Brief Text'
    end
    object Label1: TLabel
      Left = 16
      Top = 107
      Width = 68
      Height = 13
      Caption = 'Edit Brief Text'
    end
    object Label2: TLabel
      Left = 24
      Top = 166
      Width = 201
      Height = 13
      Caption = '(Sample with substitutions shown to right)'
    end
    object Label3: TLabel
      Left = 24
      Top = 193
      Width = 69
      Height = 13
      Caption = 'Substitutions: '
    end
    object Label4: TLabel
      Left = 99
      Top = 193
      Width = 60
      Height = 13
      Caption = '<n> = node'
    end
    object Label5: TLabel
      Left = 99
      Top = 212
      Width = 52
      Height = 13
      Caption = '<l> = loop'
    end
    object Label6: TLabel
      Left = 99
      Top = 231
      Width = 67
      Height = 13
      Caption = '<d> = device'
    end
    object Label7: TLabel
      Left = 99
      Top = 250
      Width = 83
      Height = 13
      Caption = '<s> = subdevice'
    end
    object EditSubunitBriefText: TEdit
      Left = 112
      Top = 56
      Width = 33
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = '1:1/2.3'
    end
    object EditFullBriefText: TEdit
      Left = 56
      Top = 126
      Width = 169
      Height = 21
      TabOrder = 1
      Text = 'EditBriefTextFull'
      OnChange = EditFullBriefTextChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 643
    Height = 73
    Align = alTop
    TabOrder = 1
    object LabelDeviceType: TLabel
      Left = 80
      Top = 30
      Width = 59
      Height = 13
      Caption = 'Device Type'
    end
    object EditSubDeviceType: TEdit
      Left = 152
      Top = 27
      Width = 145
      Height = 21
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
      Text = 'EditSubDeviceType'
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 345
    Width = 643
    Height = 55
    Align = alBottom
    TabOrder = 2
    object BitBtn1: TBitBtn
      Left = 152
      Top = 16
      Width = 75
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 360
      Top = 16
      Width = 75
      Height = 25
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 73
    Width = 410
    Height = 272
    Align = alClient
    TabOrder = 3
    ExplicitWidth = 71
    ExplicitHeight = 73
    inline FrameIconEditor1: TFrameIconEditor
      Left = 1
      Top = 1
      Width = 408
      Height = 270
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 69
      ExplicitHeight = 71
      inherited PanelEdit: TPanel
        Top = 229
        Width = 408
        ExplicitTop = 229
        ExplicitWidth = 408
        inherited BitBtnLoadNew: TBitBtn
          OnClick = FrameIconEditor1BitBtnLoadNewClick
        end
      end
      inherited TabControlClasses: TTabControl
        Width = 408
        Height = 229
        ExplicitWidth = 69
        ExplicitHeight = 30
        inherited StringGridMain: TStringGrid
          Width = 400
          Height = 201
          ColWidths = (
            32
            32
            32
            32
            32)
          RowHeights = (
            32
            32
            32
            32
            32)
        end
      end
    end
  end
end
