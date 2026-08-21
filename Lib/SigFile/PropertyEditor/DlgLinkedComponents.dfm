object FormSigFile7PropertyEditor: TFormSigFile7PropertyEditor
  Left = 0
  Top = 0
  Caption = 'Linked Components'
  ClientHeight = 322
  ClientWidth = 352
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
    Width = 352
    Height = 322
    Align = alClient
    Caption = 'SigPanel1'
    TabOrder = 0
    ExplicitLeft = 128
    ExplicitTop = 88
    ExplicitWidth = 185
    ExplicitHeight = 41
    object SigPanelComponentName: TSigPanel
      Left = 1
      Top = 1
      Width = 350
      Height = 41
      Align = alTop
      BevelOuter = bvRaised
      Caption = 'SigPanelComponentName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowCaption = True
      TabOrder = 0
      PanelStyle = psChildTop
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
    end
    object SigPanel3: TSigPanel
      Left = 1
      Top = 280
      Width = 350
      Height = 41
      Align = alBottom
      BevelOuter = bvRaised
      Caption = 'SigPanel3'
      TabOrder = 1
      PanelStyle = psChildBottom
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
      object BitBtn1: TBitBtn
        Left = 80
        Top = 6
        Width = 75
        Height = 25
        Kind = bkOK
        NumGlyphs = 2
        TabOrder = 0
      end
      object BitBtn2: TBitBtn
        Left = 200
        Top = 6
        Width = 75
        Height = 25
        Kind = bkCancel
        NumGlyphs = 2
        TabOrder = 1
      end
    end
    object SigPanel4: TSigPanel
      Left = 1
      Top = 42
      Width = 350
      Height = 238
      Align = alClient
      BevelOuter = bvRaised
      Caption = 'SigPanel4'
      TabOrder = 2
      PanelStyle = psChildFill
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
      ExplicitHeight = 41
      object SigGeneralGridEditor: TSigGeneralGrid
        Left = 1
        Top = 1
        Width = 348
        Height = 236
        Align = alClient
        ColCount = 2
        TabOrder = 0
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
        ExplicitLeft = 224
        ExplicitTop = 40
        ExplicitWidth = 320
        ExplicitHeight = 120
        ColWidths = (
          64
          256)
      end
    end
  end
  object SigGridEditorAction: TSigGridEditor
    SigGrid = SigGeneralGridEditor
    Style = esButton
    Titles.Strings = (
      '    Add')
    Left = 153
    Top = 90
  end
  object SigGridEditorLinkedComponents: TSigGridEditor
    SigGrid = SigGeneralGridEditor
    Style = esDropDownList
    Column = 1
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Linked Components')
    ParentColWidth = False
    ColWidth = 256
    Left = 169
    Top = 162
  end
end
