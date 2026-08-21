object FormVCLMacroEditor: TFormVCLMacroEditor
  Left = 0
  Top = 0
  Caption = 'Macro Editor'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenuMacroEditor
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object SigPanel1: TSigPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 299
    Align = alClient
    Caption = 'SigPanel1'
    TabOrder = 0
    ExplicitLeft = 168
    ExplicitTop = 88
    ExplicitWidth = 185
    ExplicitHeight = 41
    object SigPanel2: TSigPanel
      Left = 1
      Top = 1
      Width = 633
      Height = 41
      Align = alTop
      BevelOuter = bvRaised
      Caption = 'SigPanel2'
      TabOrder = 0
      PanelStyle = psChildTop
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
    end
    object SigPanel3: TSigPanel
      Left = 1
      Top = 42
      Width = 633
      Height = 256
      Align = alClient
      BevelOuter = bvRaised
      Caption = 'SigPanel3'
      TabOrder = 1
      PanelStyle = psChildFill
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 185
      ExplicitHeight = 41
    end
  end
  object SigSaveDialogMacro: TSigSaveDialog
    DefaultExt = 'macro'
    Filter = 'Macros (*.macro)|*.macro'
    Left = 513
    Top = 66
  end
  object MainMenuMacroEditor: TMainMenu
    Left = 345
    Top = 66
  end
  object SigRegistryMacros: TSigRegistry
    Left = 241
    Top = 146
  end
end
