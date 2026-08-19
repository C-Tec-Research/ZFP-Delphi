object FormUpdateCommonDeviceFields: TFormUpdateCommonDeviceFields
  Left = 0
  Top = 0
  Caption = 'Common Device Fields'
  ClientHeight = 454
  ClientWidth = 674
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SigPanel1: TSigPanel
    Left = 0
    Top = 0
    Width = 674
    Height = 454
    Align = alClient
    Caption = 'SigPanel1'
    TabOrder = 0
    ExplicitLeft = 128
    ExplicitTop = 72
    ExplicitWidth = 185
    ExplicitHeight = 41
    object SigPanel2: TSigPanel
      Left = 1
      Top = 412
      Width = 672
      Height = 41
      Align = alBottom
      BevelOuter = bvRaised
      Caption = 'SigPanel2'
      TabOrder = 0
      PanelStyle = psChildBottom
      ExplicitLeft = 216
      ExplicitTop = 384
      ExplicitWidth = 185
      object BitBtn1: TBitBtn
        Left = 288
        Top = 6
        Width = 75
        Height = 25
        Caption = 'Done'
        Kind = bkOK
        NumGlyphs = 2
        TabOrder = 0
      end
    end
    object SigPanel3: TSigPanel
      Left = 1
      Top = 1
      Width = 672
      Height = 411
      Align = alClient
      BevelOuter = bvRaised
      Caption = 'SigPanel3'
      TabOrder = 1
      PanelStyle = psChildFill
      ExplicitLeft = 144
      ExplicitTop = 88
      ExplicitWidth = 185
      ExplicitHeight = 41
      object SigImage1: TSigImage
        Left = 34
        Top = 31
        Width = 24
        Height = 24
      end
      object Label1: TLabel
        Left = 88
        Top = 35
        Width = 62
        Height = 13
        Caption = 'Device Name'
      end
      object EditDeviceName: TEdit
        Left = 184
        Top = 32
        Width = 169
        Height = 21
        TabOrder = 0
        Text = 'EditDeviceName'
      end
      object SigGeneralGridCommonDeviceFields: TSigGeneralGrid
        Left = 32
        Top = 80
        Width = 609
        Height = 305
        TabOrder = 1
        Visible = True
        NormalFont.Charset = DEFAULT_CHARSET
        NormalFont.Color = clWindowText
        NormalFont.Height = -11
        NormalFont.Name = 'Tahoma'
        NormalFont.Style = []
        ErrorFont.Charset = DEFAULT_CHARSET
        ErrorFont.Color = clWindowText
        ErrorFont.Height = -11
        ErrorFont.Name = 'Tahoma'
        ErrorFont.Style = []
        ColWidths = (
          64
          91
          64
          70
          78)
      end
    end
  end
  object SigGridEditorSubDeviceName: TSigGridEditor
    SigGrid = SigGeneralGridCommonDeviceFields
    Style = esMaskEdit
    Column = 1
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Subdevice Name')
    ParentColWidth = False
    Left = 40
    Top = 400
  end
  object SigGridEditorSubdeviceZone: TSigGridEditor
    SigGrid = SigGeneralGridCommonDeviceFields
    Style = esButton
    Column = 2
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Zone')
    ParentColWidth = False
    Left = 152
    Top = 400
  end
  object SigGridEditorSubdeviceInputGroup: TSigGridEditor
    SigGrid = SigGeneralGridCommonDeviceFields
    Style = esButton
    Column = 3
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Input Group')
    ParentColWidth = False
    Left = 224
    Top = 392
  end
  object SigGridEditorSubdeviceOutputGroup: TSigGridEditor
    SigGrid = SigGeneralGridCommonDeviceFields
    Style = esButton
    Column = 4
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Output Group')
    ParentColWidth = False
    Left = 384
    Top = 400
  end
end
