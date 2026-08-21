object FormSigFileGUI: TFormSigFileGUI
  Left = 0
  Top = 0
  Caption = 'SigFile Project Wizard'
  ClientHeight = 412
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 351
    Width = 689
    Height = 61
    Align = alBottom
    TabOrder = 1
    object BitBtnOK: TBitBtn
      Left = 200
      Top = 16
      Width = 75
      Height = 25
      DoubleBuffered = True
      Kind = bkOK
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object BitBtnCancel: TBitBtn
      Left = 360
      Top = 16
      Width = 75
      Height = 25
      DoubleBuffered = True
      Kind = bkCancel
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 689
    Height = 105
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 26
      Top = 32
      Width = 64
      Height = 13
      Caption = 'Project Name'
    end
    object Label2: TLabel
      Left = 26
      Top = 59
      Width = 81
      Height = 13
      Caption = 'Project Directory'
    end
    object SpeedButtonBrowseProjectDirectory: TSpeedButton
      Left = 488
      Top = 56
      Width = 73
      Height = 22
      Caption = 'Browse...'
      OnClick = SpeedButtonBrowseProjectDirectoryClick
    end
    object Label4: TLabel
      Left = 296
      Top = 32
      Width = 182
      Height = 13
      Caption = '(Use Browse to Create a new project)'
    end
    object SpeedButtonExport: TSpeedButton
      Left = 576
      Top = 28
      Width = 81
      Height = 22
      Caption = 'Export...'
      OnClick = SpeedButtonExportClick
    end
    object SpeedButtonImport: TSpeedButton
      Left = 576
      Top = 56
      Width = 81
      Height = 22
      Caption = 'Import...'
      OnClick = SpeedButtonImportClick
    end
    object EditApplicationName: TEdit
      Left = 154
      Top = 29
      Width = 121
      Height = 21
      ReadOnly = True
      TabOrder = 0
      Text = 'EditApplicationName'
    end
    object EditEditProjectDirectory: TEdit
      Left = 154
      Top = 56
      Width = 313
      Height = 21
      ReadOnly = True
      TabOrder = 1
      Text = 'EditEditProjectDirectory'
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 105
    Width = 689
    Height = 246
    Align = alClient
    TabOrder = 2
    object PageControlMain: TPageControl
      Left = 1
      Top = 1
      Width = 687
      Height = 244
      ActivePage = TabSheetSigFileDescendant
      Align = alClient
      TabOrder = 0
      object TabSheetGeneral: TTabSheet
        Caption = 'General'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 679
          Height = 216
          Align = alClient
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object CheckBoxUsesUndRedo: TCheckBox
            Left = 48
            Top = 32
            Width = 97
            Height = 17
            Caption = 'Uses Und/Redo'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object CheckBoxUsesPrint: TCheckBox
            Left = 48
            Top = 55
            Width = 97
            Height = 17
            Caption = 'Uses Print'
            Checked = True
            State = cbChecked
            TabOrder = 1
          end
          object GroupBoxCompanyName: TGroupBox
            Left = 277
            Top = 24
            Width = 300
            Height = 121
            Caption = 'Company Name'
            TabOrder = 2
            object RadioButtonC_Tec: TRadioButton
              Left = 24
              Top = 24
              Width = 113
              Height = 17
              Caption = 'C-Tec'
              TabOrder = 0
            end
            object RadioButtonSigNET: TRadioButton
              Left = 24
              Top = 56
              Width = 113
              Height = 17
              Caption = 'SigNET'
              Checked = True
              TabOrder = 1
              TabStop = True
            end
            object RadioButtonOther: TRadioButton
              Left = 24
              Top = 88
              Width = 49
              Height = 17
              Caption = 'Other'
              TabOrder = 2
            end
            object EditCompanyName: TEdit
              Left = 128
              Top = 87
              Width = 121
              Height = 21
              TabOrder = 3
            end
          end
          object CheckBoxRestoreLastWindowsSetup: TCheckBox
            Left = 48
            Top = 78
            Width = 177
            Height = 17
            Caption = 'Restore Last Screen Layout'
            Checked = True
            State = cbChecked
            TabOrder = 3
          end
          object CheckBoxReloadLastSavedFile: TCheckBox
            Left = 48
            Top = 101
            Width = 177
            Height = 17
            Caption = 'Reload Last Saved File'
            TabOrder = 4
          end
          object CheckBoxUsesCfgFile: TCheckBox
            Left = 48
            Top = 124
            Width = 177
            Height = 17
            Caption = 'Uses Config File'
            TabOrder = 5
          end
        end
      end
      object TabSheetSigFileEnums: TTabSheet
        Caption = 'Enums'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheetCustomTypes: TTabSheet
        Caption = 'Custom Types'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheetSigFileDescendant: TTabSheet
        Caption = 'SigFile Descendant'
        ImageIndex = 3
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PageControl1: TPageControl
          Left = 0
          Top = 0
          Width = 679
          Height = 216
          ActivePage = TabSheetSigFile
          Align = alClient
          TabOrder = 0
          object TabSheetSigFile: TTabSheet
            Caption = 'SigFile Descendant'
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object Panel8: TPanel
              Left = 0
              Top = 0
              Width = 671
              Height = 41
              Align = alTop
              ParentBackground = False
              TabOrder = 0
              object Label5: TLabel
                Left = 80
                Top = 8
                Width = 87
                Height = 13
                Caption = 'Descendant Name'
              end
              object EditSigFileDescendant: TEdit
                Left = 191
                Top = 4
                Width = 235
                Height = 21
                TabOrder = 0
                Text = 'EditSigFileDescendant'
              end
            end
            object Panel9: TPanel
              Left = 0
              Top = 41
              Width = 671
              Height = 147
              Align = alClient
              ParentBackground = False
              TabOrder = 1
            end
          end
          object TabSheetCfgFile: TTabSheet
            Caption = 'CfgFile Descendant'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
          end
        end
      end
      object TabSheetInfo: TTabSheet
        Caption = 'Info'
        ImageIndex = 4
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 679
          Height = 216
          Align = alClient
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object Panel6: TPanel
            Left = 1
            Top = 1
            Width = 677
            Height = 41
            Align = alTop
            TabOrder = 0
            object Label3: TLabel
              Left = 46
              Top = 12
              Width = 55
              Height = 13
              Caption = 'No Modules'
            end
            object EditModuleCount: TEdit
              Left = 112
              Top = 8
              Width = 97
              Height = 21
              ParentColor = True
              ReadOnly = True
              TabOrder = 0
              Text = 'EditModuleCount'
            end
          end
          object Panel7: TPanel
            Left = 1
            Top = 42
            Width = 677
            Height = 173
            Align = alClient
            TabOrder = 1
            object SigGeneralGridModuleInfo: TSigGeneralGrid
              Left = 1
              Top = 1
              Width = 675
              Height = 171
              Align = alClient
              DefaultColWidth = 32
              TabOrder = 0
              AutoSizeCols = True
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
                32
                34
                39
                58
                72)
            end
          end
        end
      end
    end
  end
  object OpenDialogProject: TOpenDialog
    DefaultExt = 'dpr'
    Filter = 'Delphi Projects (*.dpr)|*.dpr'
    Options = [ofHideReadOnly, ofCreatePrompt, ofEnableSizing]
    Title = 'SigFile Project'
    Left = 552
    Top = 88
  end
  object tSigGridEditorModuleType: tSigGridEditor
    SigGrid = SigGeneralGridModuleInfo
    Style = esNone
    Column = 1
    Titles.Strings = (
      'type')
    Left = 480
    Top = 208
  end
  object tSigGridEditorName: tSigGridEditor
    SigGrid = SigGeneralGridModuleInfo
    Style = esNone
    Column = 2
    Titles.Strings = (
      'Name')
    Left = 480
    Top = 256
  end
  object tSigGridEditorFileName: tSigGridEditor
    SigGrid = SigGeneralGridModuleInfo
    Style = esNone
    Column = 3
    Titles.Strings = (
      'File Name')
    Left = 480
    Top = 304
  end
  object tSigGridEditorDesignClass: tSigGridEditor
    SigGrid = SigGeneralGridModuleInfo
    Style = esNone
    Column = 4
    Titles.Strings = (
      'Design Class')
    Left = 344
    Top = 288
  end
  object SigSaveDialogImportExport: TSigSaveDialog
    DefaultExt = 'bpx'
    Filter = 'Borland Project Export (*.bpx)|*.bpx'
    Left = 568
    Top = 200
  end
end
