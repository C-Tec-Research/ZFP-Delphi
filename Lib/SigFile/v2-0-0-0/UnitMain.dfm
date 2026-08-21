object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 576
  ClientWidth = 949
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 949
    Height = 494
    Align = alClient
    TabOrder = 0
    object PageControlMain: TPageControl
      Left = 1
      Top = 1
      Width = 947
      Height = 492
      ActivePage = TabSheetFiles
      Align = alClient
      TabOrder = 0
      OnChange = PageControlMainChange
      object TabSheetFiles: TTabSheet
        Caption = 'Files'
        ImageIndex = 2
        object SigPanel6: TSigPanel
          Left = 0
          Top = 0
          Width = 939
          Height = 464
          Align = alClient
          Caption = 'SigPanel6'
          TabOrder = 0
          object SigPanel7: TSigPanel
            Left = 1
            Top = 422
            Width = 937
            Height = 41
            Align = alBottom
            BevelOuter = bvRaised
            Caption = 'SigPanel7'
            TabOrder = 0
            PanelStyle = psChildBottom
            DesignSize = (
              937
              41)
            object SpeedButtonNewFile: TSpeedButton
              Left = 160
              Top = 8
              Width = 91
              Height = 22
              Caption = 'New File'
            end
            object SpeedButtonBuildSource: TSpeedButton
              Left = 717
              Top = 6
              Width = 89
              Height = 22
              Anchors = [akTop, akRight]
              Caption = 'Build Source'
              OnClick = SpeedButtonBuildSourceClick
              ExplicitLeft = 528
            end
          end
          object SigPanel8: TSigPanel
            Left = 586
            Top = 1
            Width = 352
            Height = 421
            Align = alRight
            BevelOuter = bvRaised
            Caption = 'SigPanel8'
            TabOrder = 1
            PanelStyle = psChildRight
            object SigPanel10: TSigPanel
              Left = 1
              Top = 1
              Width = 350
              Height = 41
              Align = alTop
              Caption = 'Source'
              ShowCaption = True
              TabOrder = 0
              PanelStyle = psChildTop
            end
            object SigPanel11: TSigPanel
              Left = 1
              Top = 42
              Width = 350
              Height = 378
              Align = alClient
              Caption = 'SigPanel11'
              TabOrder = 1
              PanelStyle = psChildFill
              object MemoFilesSource: TMemo
                Left = 1
                Top = 1
                Width = 348
                Height = 376
                Align = alClient
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'Courier New'
                Font.Style = []
                Lines.Strings = (
                  'MemoFilesSource')
                ParentFont = False
                ScrollBars = ssBoth
                TabOrder = 0
                WordWrap = False
              end
            end
          end
          object SigPanel9: TSigPanel
            Left = 1
            Top = 1
            Width = 585
            Height = 421
            Align = alClient
            BevelOuter = bvRaised
            Caption = 'SigPanel9'
            TabOrder = 2
            PanelStyle = psChildFill
            object TabControlFiles: TTabControl
              Left = 1
              Top = 1
              Width = 583
              Height = 419
              Align = alClient
              TabOrder = 0
              Tabs.Strings = (
                '<New>')
              TabIndex = 0
              object SigPanel12: TSigPanel
                Left = 4
                Top = 24
                Width = 575
                Height = 391
                Align = alClient
                Caption = 'SigPanel12'
                TabOrder = 0
                object PageControlFiles: TPageControl
                  Left = 1
                  Top = 1
                  Width = 573
                  Height = 389
                  ActivePage = TabSheetFile
                  Align = alClient
                  TabOrder = 0
                  object TabSheetFile: TTabSheet
                    Caption = 'File'
                    ImageIndex = 2
                    object SigPanel13: TSigPanel
                      Left = 0
                      Top = 0
                      Width = 565
                      Height = 361
                      Align = alClient
                      Anchors = [akLeft, akTop, akRight]
                      Caption = 'SigPanel13'
                      TabOrder = 0
                      DesignSize = (
                        565
                        361)
                      object Label2: TLabel
                        Left = 26
                        Top = 16
                        Width = 53
                        Height = 13
                        Caption = 'Base Name'
                      end
                      object Label4: TLabel
                        Left = 26
                        Top = 67
                        Width = 79
                        Height = 13
                        Caption = 'Additional Types'
                      end
                      object Label5: TLabel
                        Left = 26
                        Top = 154
                        Width = 76
                        Height = 13
                        Caption = 'Additional (Priv)'
                      end
                      object Label6: TLabel
                        Left = 26
                        Top = 245
                        Width = 76
                        Height = 13
                        Caption = 'Additional (pub)'
                      end
                      object SpeedButtonDeleteFile: TSpeedButton
                        Left = 192
                        Top = 328
                        Width = 261
                        Height = 22
                        Caption = 'Delete this file and all it'#39's indexes'
                        OnClick = SpeedButtonDeleteFileClick
                      end
                      object EditFileBaseName: TEdit
                        Left = 111
                        Top = 13
                        Width = 121
                        Height = 21
                        TabOrder = 0
                        Text = 'EditFileBaseName'
                      end
                      object MemoFileAdditionalTypes: TMemo
                        Left = 111
                        Top = 56
                        Width = 439
                        Height = 89
                        Anchors = [akLeft, akTop, akRight]
                        Font.Charset = DEFAULT_CHARSET
                        Font.Color = clWindowText
                        Font.Height = -11
                        Font.Name = 'Courier New'
                        Font.Style = []
                        Lines.Strings = (
                          'MemoFileAdditionalTypes')
                        ParentFont = False
                        ScrollBars = ssBoth
                        TabOrder = 1
                        WordWrap = False
                      end
                      object MemoAdditionalPrivateMembers: TMemo
                        Left = 111
                        Top = 151
                        Width = 439
                        Height = 85
                        Anchors = [akLeft, akTop, akRight]
                        Font.Charset = DEFAULT_CHARSET
                        Font.Color = clWindowText
                        Font.Height = -11
                        Font.Name = 'Courier New'
                        Font.Style = []
                        Lines.Strings = (
                          'MemoAdditionalPrivateMembers')
                        ParentFont = False
                        ScrollBars = ssBoth
                        TabOrder = 2
                        WordWrap = False
                      end
                      object MemoAdditionalPublicMembers: TMemo
                        Left = 111
                        Top = 242
                        Width = 439
                        Height = 87
                        Anchors = [akLeft, akTop, akRight]
                        Font.Charset = DEFAULT_CHARSET
                        Font.Color = clWindowText
                        Font.Height = -11
                        Font.Name = 'Courier New'
                        Font.Style = []
                        Lines.Strings = (
                          'MemoAdditionalPublicMembers')
                        ParentFont = False
                        ScrollBars = ssBoth
                        TabOrder = 3
                        WordWrap = False
                      end
                      object CheckBoxInterceptBaseFile: TCheckBox
                        Left = 264
                        Top = 16
                        Width = 189
                        Height = 17
                        Caption = 'Intercept? (NOT recommended)'
                        TabOrder = 4
                      end
                    end
                  end
                  object TabSheetRecord: TTabSheet
                    Caption = 'Fields'
                    object SigPanel17: TSigPanel
                      Left = 0
                      Top = 0
                      Width = 565
                      Height = 361
                      Align = alClient
                      Caption = 'SigPanel17'
                      TabOrder = 0
                      object SigPanel18: TSigPanel
                        Left = 1
                        Top = 319
                        Width = 563
                        Height = 41
                        Align = alBottom
                        BevelOuter = bvRaised
                        Caption = 'SigPanel18'
                        TabOrder = 0
                        PanelStyle = psChildBottom
                        object SpeedButtonAddField: TSpeedButton
                          Left = 149
                          Top = 6
                          Width = 121
                          Height = 22
                          Caption = 'Add Field'
                        end
                        object SpeedButtonDeleteSelectedField: TSpeedButton
                          Left = 276
                          Top = 6
                          Width = 121
                          Height = 22
                          Caption = 'Delete Field'
                        end
                      end
                      object SigPanel19: TSigPanel
                        Left = 1
                        Top = 1
                        Width = 563
                        Height = 318
                        Align = alClient
                        BevelOuter = bvRaised
                        Caption = 'SigPanel19'
                        TabOrder = 1
                        PanelStyle = psChildFill
                        object SigGeneralGridFields: TSigGeneralGrid
                          Left = 1
                          Top = 1
                          Width = 561
                          Height = 316
                          Align = alClient
                          FixedCols = 0
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
                          ColWidths = (
                            64
                            180
                            180
                            120
                            180)
                        end
                      end
                    end
                  end
                  object TabSheetIndexes: TTabSheet
                    Caption = 'Indexes'
                    ImageIndex = 1
                    object SigPanel20: TSigPanel
                      Left = 0
                      Top = 0
                      Width = 565
                      Height = 361
                      Align = alClient
                      Caption = 'SigPanel20'
                      TabOrder = 0
                      object SigPanel21: TSigPanel
                        Left = 1
                        Top = 328
                        Width = 563
                        Height = 32
                        Align = alBottom
                        BevelOuter = bvRaised
                        Caption = 'SigPanel21'
                        TabOrder = 0
                        PanelStyle = psChildBottom
                        object SpeedButtonAddIndexFile: TSpeedButton
                          Left = 161
                          Top = 6
                          Width = 110
                          Height = 22
                          Caption = 'Add Index File'
                        end
                        object SpeedButtonDeleteIndexFile: TSpeedButton
                          Left = 276
                          Top = 6
                          Width = 121
                          Height = 22
                          Caption = 'Delete Index File'
                        end
                      end
                      object SigPanel22: TSigPanel
                        Left = 1
                        Top = 1
                        Width = 563
                        Height = 327
                        Align = alClient
                        BevelOuter = bvRaised
                        Caption = 'SigPanel22'
                        TabOrder = 1
                        PanelStyle = psChildFill
                        object TabControlIndexFiles: TTabControl
                          Left = 1
                          Top = 1
                          Width = 561
                          Height = 325
                          Align = alClient
                          TabOrder = 0
                          Tabs.Strings = (
                            '<New>')
                          TabIndex = 0
                          object PageControlIndexes: TPageControl
                            Left = 4
                            Top = 24
                            Width = 553
                            Height = 297
                            ActivePage = TabSheetIndexFind
                            Align = alClient
                            TabOrder = 0
                            object TabSheetIndexFields: TTabSheet
                              Caption = 'Fields'
                              object SigPanel23: TSigPanel
                                Left = 0
                                Top = 0
                                Width = 545
                                Height = 269
                                Align = alClient
                                Caption = 'SigPanel23'
                                TabOrder = 0
                                DesignSize = (
                                  545
                                  269)
                                object Label7: TLabel
                                  Left = 16
                                  Top = 16
                                  Width = 47
                                  Height = 13
                                  Caption = 'Extension'
                                end
                                object Label8: TLabel
                                  Left = 16
                                  Top = 56
                                  Width = 39
                                  Height = 13
                                  Caption = 'Indexes'
                                end
                                object EditIndexExtension: TEdit
                                  Left = 87
                                  Top = 13
                                  Width = 121
                                  Height = 21
                                  TabOrder = 0
                                  Text = 'EditIndexExtension'
                                end
                                object SigGeneralGridIndexes: TSigGeneralGrid
                                  Left = 87
                                  Top = 75
                                  Width = 450
                                  Height = 158
                                  Anchors = [akLeft, akTop, akBottom]
                                  ColCount = 4
                                  DefaultColWidth = 32
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
                                    32
                                    160
                                    120
                                    120)
                                end
                                object SigSpinEditIndexCount: TSigSpinEdit
                                  Left = 16
                                  Top = 75
                                  Width = 65
                                  Height = 22
                                  MaxValue = 0
                                  MinValue = 0
                                  TabOrder = 2
                                  Value = 0
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
                                end
                                object CheckBoxMirrorDataFields: TCheckBox
                                  Left = 244
                                  Top = 15
                                  Width = 229
                                  Height = 17
                                  Caption = 'Mirror Data Fields (recommended)'
                                  TabOrder = 3
                                end
                                object CheckBoxInterceptIndexFile: TCheckBox
                                  Left = 244
                                  Top = 38
                                  Width = 189
                                  Height = 17
                                  Caption = 'Intercept? (recommended)'
                                  TabOrder = 4
                                end
                              end
                            end
                            object TabSheetIndexFind: TTabSheet
                              Caption = 'Find Functions'
                              ImageIndex = 1
                              object SigPanel24: TSigPanel
                                Left = 0
                                Top = 0
                                Width = 545
                                Height = 269
                                Align = alClient
                                Caption = 'SigPanel24'
                                TabOrder = 0
                                object SpeedButtonAddFindFunction: TSpeedButton
                                  Left = 101
                                  Top = 214
                                  Width = 311
                                  Height = 22
                                  Caption = 'Add Find Function'
                                end
                                object Label14: TLabel
                                  Left = 64
                                  Top = 16
                                  Width = 413
                                  Height = 13
                                  Caption = 
                                    'Note: Match count ignored for Find functions. A value of -1 mean' +
                                    's same as Key Count'
                                end
                                object SigGeneralGridFind: TSigGeneralGrid
                                  Left = 64
                                  Top = 40
                                  Width = 379
                                  Height = 153
                                  ColCount = 3
                                  FixedCols = 0
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
                                  ColWidths = (
                                    150
                                    64
                                    64)
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                  object TabSheetEncryption: TTabSheet
                    Caption = 'Encryption'
                    ImageIndex = 3
                    object SigPanel26: TSigPanel
                      Left = 0
                      Top = 0
                      Width = 565
                      Height = 361
                      Align = alClient
                      Caption = 'SigPanel26'
                      TabOrder = 0
                      object TabControlEncryption: TTabControl
                        Left = 1
                        Top = 1
                        Width = 563
                        Height = 359
                        Align = alClient
                        TabOrder = 0
                        Tabs.Strings = (
                          'All Files')
                        TabIndex = 0
                        object SigPanel27: TSigPanel
                          Left = 4
                          Top = 24
                          Width = 555
                          Height = 331
                          Align = alClient
                          Caption = 'SigPanel27'
                          TabOrder = 0
                          object Label13: TLabel
                            Left = 32
                            Top = 32
                            Width = 95
                            Height = 13
                            Caption = 'Encryption Methods'
                          end
                          object CheckListBoxEncryptionMethods: TCheckListBox
                            Left = 27
                            Top = 64
                            Width = 230
                            Height = 225
                            ItemHeight = 13
                            TabOrder = 0
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      object TabSheetPas: TTabSheet
        Caption = 'Full Pas Source'
        ImageIndex = 3
        object SigPanel14: TSigPanel
          Left = 0
          Top = 0
          Width = 939
          Height = 464
          Align = alClient
          Caption = 'SigPanel14'
          TabOrder = 0
          object TabControlPasSources: TTabControl
            Left = 1
            Top = 1
            Width = 937
            Height = 462
            Align = alClient
            TabOrder = 0
            Tabs.Strings = (
              'Database'
              'File Lists'
              'Intercept Files'
              'Raw Files')
            TabIndex = 0
            object SigPanel25: TSigPanel
              Left = 4
              Top = 24
              Width = 929
              Height = 434
              Align = alClient
              Caption = 'SigPanel25'
              TabOrder = 0
              object SigPanel16: TSigPanel
                Left = 1
                Top = 1
                Width = 927
                Height = 391
                Align = alClient
                BevelOuter = bvRaised
                Caption = 'SigPanel16'
                TabOrder = 0
                object MemoPasSource: TMemo
                  Left = 1
                  Top = 1
                  Width = 925
                  Height = 389
                  Align = alClient
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -11
                  Font.Name = 'Courier New'
                  Font.Style = []
                  Lines.Strings = (
                    'MemoPas')
                  ParentFont = False
                  ScrollBars = ssBoth
                  TabOrder = 0
                  WordWrap = False
                end
              end
              object SigPanel15: TSigPanel
                Left = 1
                Top = 392
                Width = 927
                Height = 41
                Align = alBottom
                BevelOuter = bvRaised
                Caption = 'SigPanel15'
                TabOrder = 1
                object SpeedButtonSaveSource: TSpeedButton
                  Left = 391
                  Top = 5
                  Width = 153
                  Height = 22
                  Caption = 'Save Source'
                  OnClick = SpeedButtonSaveSourceClick
                end
              end
            end
          end
        end
      end
      object TabSheetTreeView: TTabSheet
        Caption = 'Tree View'
        ImageIndex = 4
        object SigPanel28: TSigPanel
          Left = 0
          Top = 0
          Width = 939
          Height = 464
          Align = alClient
          Caption = 'SigPanel28'
          TabOrder = 0
          object SigPanel29: TSigPanel
            Left = 1
            Top = 1
            Width = 937
            Height = 41
            Align = alTop
            BevelOuter = bvRaised
            Caption = 'SigPanel29'
            TabOrder = 0
            PanelStyle = psChildTop
          end
          object SigPanel30: TSigPanel
            Left = 1
            Top = 422
            Width = 937
            Height = 41
            Align = alBottom
            BevelOuter = bvRaised
            Caption = 'SigPanel30'
            TabOrder = 1
            PanelStyle = psChildBottom
          end
          object SigPanel31: TSigPanel
            Left = 1
            Top = 42
            Width = 937
            Height = 380
            Align = alClient
            BevelOuter = bvRaised
            Caption = 'SigPanel31'
            TabOrder = 2
            PanelStyle = psChildFill
            object SigPanel32: TSigPanel
              Left = 1
              Top = 1
              Width = 328
              Height = 378
              Align = alLeft
              Caption = 'SigPanel32'
              TabOrder = 0
              PanelStyle = psChildLeft
              object TreeViewDatabase: TTreeView
                Left = 1
                Top = 1
                Width = 326
                Height = 376
                Align = alClient
                Indent = 19
                TabOrder = 0
              end
            end
            object SigPanel33: TSigPanel
              Left = 329
              Top = 1
              Width = 607
              Height = 378
              Align = alClient
              Caption = 'SigPanel33'
              TabOrder = 1
              PanelStyle = psChildFill
              object PageControlProperties: TPageControl
                Left = 1
                Top = 1
                Width = 605
                Height = 376
                ActivePage = TabSheetDatabaseProperties
                Align = alClient
                TabOrder = 0
                object TabSheetDatabaseProperties: TTabSheet
                  Caption = 'TabSheetDatabaseProperties'
                  object SigPanelDatabaseProperties: TSigPanel
                    Left = 0
                    Top = 0
                    Width = 597
                    Height = 348
                    Align = alClient
                    Caption = 'SigPanelDatabaseProperties'
                    TabOrder = 0
                    ExplicitWidth = 939
                    ExplicitHeight = 464
                    DesignSize = (
                      597
                      348)
                    object Label1: TLabel
                      Left = 26
                      Top = 56
                      Width = 38
                      Height = 13
                      Caption = 'File Unit'
                    end
                    object Label3: TLabel
                      Left = 26
                      Top = 179
                      Width = 79
                      Height = 13
                      Caption = 'Additional Types'
                    end
                    object Label11: TLabel
                      Left = 26
                      Top = 141
                      Width = 68
                      Height = 13
                      Caption = 'Database Unit'
                    end
                    object Label10: TLabel
                      Left = 26
                      Top = 83
                      Width = 67
                      Height = 13
                      Caption = 'Intercept Unit'
                    end
                    object Label12: TLabel
                      Left = 26
                      Top = 110
                      Width = 54
                      Height = 13
                      Caption = 'FileList Unit'
                    end
                    object Label9: TLabel
                      Left = 26
                      Top = 29
                      Width = 69
                      Height = 13
                      Caption = 'DB Base Name'
                    end
                    object EditFileUnitName: TEdit
                      Left = 122
                      Top = 53
                      Width = 280
                      Height = 21
                      TabOrder = 0
                      Text = 'EditFileUnitName'
                      OnChange = EditFileUnitNameChange
                    end
                    object MemoAdditionalTypes: TMemo
                      Left = 122
                      Top = 179
                      Width = 443
                      Height = 150
                      Anchors = [akLeft, akTop, akRight, akBottom]
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clWindowText
                      Font.Height = -11
                      Font.Name = 'Courier New'
                      Font.Style = []
                      Lines.Strings = (
                        'MemoAdditionalTypes')
                      ParentFont = False
                      ScrollBars = ssBoth
                      TabOrder = 1
                      WordWrap = False
                    end
                    object BitBtnFileBrowse: TBitBtn
                      Left = 439
                      Top = 51
                      Width = 75
                      Height = 25
                      Caption = 'Browse...'
                      TabOrder = 2
                      OnClick = BitBtnFileBrowseClick
                    end
                    object EditDatabaseUnitName: TEdit
                      Left = 122
                      Top = 138
                      Width = 280
                      Height = 21
                      TabOrder = 3
                      Text = 'EditDatabaseUnitName'
                      OnChange = EditDatabaseUnitNameChange
                    end
                    object BitBtnDatabaseBrowse: TBitBtn
                      Left = 439
                      Top = 136
                      Width = 75
                      Height = 25
                      Caption = 'Browse...'
                      TabOrder = 4
                      OnClick = BitBtnDatabaseBrowseClick
                    end
                    object EditInterceptUnitName: TEdit
                      Left = 122
                      Top = 80
                      Width = 280
                      Height = 21
                      TabOrder = 5
                      Text = 'EditInterceptUnitName'
                      OnChange = EditInterceptUnitNameChange
                    end
                    object BitBtnInterceptBrowse: TBitBtn
                      Left = 439
                      Top = 78
                      Width = 75
                      Height = 25
                      Caption = 'Browse...'
                      TabOrder = 6
                      OnClick = BitBtnInterceptBrowseClick
                    end
                    object EditFileListUnitName: TEdit
                      Left = 122
                      Top = 107
                      Width = 280
                      Height = 21
                      TabOrder = 7
                      Text = 'EditDatabaseUnitName'
                      OnChange = EditFileListUnitNameChange
                    end
                    object BitBtnFileListBrowse: TBitBtn
                      Left = 439
                      Top = 105
                      Width = 75
                      Height = 25
                      Caption = 'Browse...'
                      TabOrder = 8
                      OnClick = BitBtnFileListBrowseClick
                    end
                    object EditDBBaseName: TEdit
                      Left = 122
                      Top = 26
                      Width = 121
                      Height = 21
                      TabOrder = 9
                      Text = 'EditDBBaseName'
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  object PanelEditMode: TPanel
    Left = 0
    Top = 0
    Width = 949
    Height = 41
    Align = alTop
    TabOrder = 1
    object SpeedButtonUndo: TSpeedButton
      Left = 232
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Undo'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000444400000000000077770000000000004C664444000
        0000078887777000000004666664000000000788888700000000046666400000
        0000078888700000000004666400000000000788870000000000044466400000
        0000078788700000000004404640000000000770787000000000040047740000
        0440070078870000077000000487440044000000078877707700000000478444
        4000000000788887700000000004444000000000000777700000000000000000
        0000000000000000000000000000000000000000000000000000}
      NumGlyphs = 2
      OnClick = SpeedButtonUndoClick
    end
    object SpeedButtonRedo: TSpeedButton
      Left = 263
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Redo'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0400000000000000070000000000000444000000000000077700000000000446
        6400000000000778870000000004466666400000000778888870000000004666
        6640000000007888887000000000046666400000000007888870000000000466
        6644000000000788887700000000046664440000000007888777040000004776
        4004070000007888700700440004786400000077000788870000000444487640
        0000000777788870000000000444440000000000077777000000000000000000
        0000000000000000000000000000000000000000000000000000}
      NumGlyphs = 2
      OnClick = SpeedButtonRedoClick
    end
    object SpeedButtonPrint: TSpeedButton
      Left = 382
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Print...'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
        00033FFFFFFFFFFFFFFF0888888888888880777777777777777F088888888888
        8880777777777777777F0000000000000000FFFFFFFFFFFFFFFF0F8F8F8F8F8F
        8F80777777777777777F08F8F8F8F8F8F9F0777777777777777F0F8F8F8F8F8F
        8F807777777777777F7F0000000000000000777777777777777F3330FFFFFFFF
        03333337F3FFFF3F7F333330F0000F0F03333337F77773737F333330FFFFFFFF
        03333337F3FF3FFF7F333330F00F000003333337F773777773333330FFFF0FF0
        33333337F3FF7F3733333330F08F0F0333333337F7737F7333333330FFFF0033
        33333337FFFF7733333333300000033333333337777773333333}
      NumGlyphs = 2
      OnClick = SpeedButtonPrintClick
    end
    object SpeedButtonPrintPreview: TSpeedButton
      Left = 413
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Print Preview'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000001
        AA13377777777778778308888888881AA18078888888888778870888888881AA
        188078888888887788870000000001AA100077777777787787770F8F8F811AA1
        8F807F8F8F8777788F8708F8111FF111F9F078F8777FF888F7F70F81FFFFFFFF
        1F807F87FFFFFFFF8F870001FFFFFFFF10007777FFFFFFFF87773331F0000F0F
        13333337F7777F7F8333331FF0000F0FF133338FF7777F7FF733331FFFFFFFFF
        F133338FFFFFFFFFF7333331F00000FF13333338F77777FF73333331F00000FF
        13333338F77777FF73333331FFFFFFFF13333338FFFFFFFF73333330111FF111
        33333337888FF777333333300001133333333337777883333333}
      NumGlyphs = 2
      OnClick = SpeedButtonPrintPreviewClick
    end
    object SpeedButtonPrintSetup: TSpeedButton
      Left = 444
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Print Setup...'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
        00033FFFFFFFFFFFFFFF0888888888888880777777777777777F088888888888
        8880777777777777777F0000000000000000FFFFFFFFFFFFFFFF0F8F8F8F808F
        8F80777777777077777F08F8F8F80B08F9F0777777770F07777F0F8F8F80BBB0
        8F8077777770FFF07F7F000000000BBB0000777777770FFF077F3333003330BB
        03333333003330FF03333330BB0330BB03333330FF0330FF03333330BBB00BBB
        03333330FFF00FFF033333330BBBBBBBB03333330FFFFFFFF033333330BBBBBB
        BB03333330FFFFFFFF033333330000BBBBB03333330000FFFFF033333333330B
        BBBB33333333330FFFFF333333333330BBBB333333333330FFFF}
      NumGlyphs = 2
      OnClick = SpeedButtonPrintSetupClick
    end
    object SpeedButtonNew: TSpeedButton
      Left = 31
      Top = 10
      Width = 26
      Height = 25
      Hint = 'New'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0033333333B333
        333B33FF33337F3333F73BB3777BB7777BB3377FFFF77FFFF77333B000000000
        0B3333777777777777333330FFFFFFFF07333337F33333337F333330FFFFFFFF
        07333337F33333337F333330FFFFFFFF07333337F33333337F333330FFFFFFFF
        07333FF7F33333337FFFBBB0FFFFFFFF0BB37777F3333333777F3BB0FFFFFFFF
        0BBB3777F3333FFF77773330FFFF000003333337F333777773333330FFFF0FF0
        33333337F3337F37F3333330FFFF0F0B33333337F3337F77FF333330FFFF003B
        B3333337FFFF77377FF333B000000333BB33337777777F3377FF3BB3333BB333
        3BB33773333773333773B333333B3333333B7333333733333337}
      NumGlyphs = 2
      OnClick = SpeedButtonNewClick
    end
    object SpeedButtonOpen: TSpeedButton
      Left = 63
      Top = 10
      Width = 26
      Height = 25
      Hint = 'Open'
      Glyph.Data = {
        06020000424D0602000000000000760000002800000028000000140000000100
        0400000000009001000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        333FFFFFFFFFFFFFF3333380000000000000333333888888888888883F333300
        7B7B7B7B7B7B033333883F33333333338F33330F07B7B7B7B7B70333338F8F33
        3333333383F3330B0B7B7B7B7B7B7033338F83F33333333338F3330FB0B7B7B7
        B7B7B033338F38F333333333383F330BF07B7B7B7B7B7B03338F383FFFFF3333
        338F330FBF000007B7B7B703338F33888883FFFFFF83330BFBFBFBF000000033
        338F3333333888888833330FBFBFBFBFBFB03333338F333333333338F333330B
        FBFBFBFBFBF03333338F33333FFFFFF83333330FBFBF0000000333333387FFFF
        8888888333333330000033333333333333388888333333333333333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        33333333333333333333}
      NumGlyphs = 2
      OnClick = SpeedButtonOpenClick
    end
    object SpeedButtonSave: TSpeedButton
      Left = 95
      Top = 10
      Width = 26
      Height = 25
      Hint = 'Save'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333FFFFFFFFFFFFF33000077777770033377777777777773F000007888888
        00037F3337F3FF37F37F00000780088800037F3337F77F37F37F000007800888
        00037F3337F77FF7F37F00000788888800037F3337777777337F000000000000
        00037F3FFFFFFFFFFF7F00000000000000037F77777777777F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF00037F7F333333337F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF00037F7F333333337F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF07037F7F33333333777F000FFFFFFFFF
        0003737FFFFFFFFF7F7330099999999900333777777777777733}
      NumGlyphs = 2
      OnClick = SpeedButtonSaveClick
    end
    object SpeedButtonSaveAs: TSpeedButton
      Left = 127
      Top = 10
      Width = 42
      Height = 25
      Hint = 'Save'
      Caption = '...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333FFFFFFFFFFFFF33000077777770033377777777777773F000007888888
        00037F3337F3FF37F37F00000780088800037F3337F77F37F37F000007800888
        00037F3337F77FF7F37F00000788888800037F3337777777337F000000000000
        00037F3FFFFFFFFFFF7F00000000000000037F77777777777F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF00037F7F333333337F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF00037F7F333333337F7F000FFFFFFFFF
        00037F7F333333337F7F000FFFFFFFFF07037F7F33333333777F000FFFFFFFFF
        0003737FFFFFFFFF7F7330099999999900333777777777777733}
      NumGlyphs = 2
      ParentFont = False
      OnClick = SpeedButtonSaveAsClick
    end
    object SpeedButtonBack: TSpeedButton
      Left = 310
      Top = 10
      Width = 25
      Height = 25
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        5555555555555555555555555555555555555555555555555555555555555F55
        5555555555555F5555555555555FFF5555555555555FFF555555555555F2AF55
        5555555555F88F5555555555FF2A2F5555555555FF888F55555555FFA2A2AFFF
        FFF555FF88888FFFFFF55F2A2A2A2A2A2AF55F888888888888F557A2A2A2A2A2
        A2F557888888888888F555772A2A277777755577888887777775555577A2AF55
        5555555577888F5555555555557A2F555555555555788F555555555555577F55
        5555555555577F55555555555555575555555555555557555555555555555555
        5555555555555555555555555555555555555555555555555555}
      NumGlyphs = 2
    end
    object SpeedButtonForward: TSpeedButton
      Left = 341
      Top = 10
      Width = 25
      Height = 25
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        5555555555555555555555555555555555555555555555555555555555F55555
        5555555555F555555555555555FFF5555555555555FFF5555555555555FA2F55
        5555555555F88F555555555555F2A2FF5555555555F888FF555557FFFFFA2A2A
        FF5557FFFFF88888FF5557A2A2A2A2A2A2F557888888888888F5572A2A2A2A2A
        2A75578888888888887557777772A2A2775557777778888877555555557A2A77
        5555555555788877555555555572A75555555555557887555555555555777555
        5555555555777555555555555575555555555555557555555555555555555555
        5555555555555555555555555555555555555555555555555555}
      NumGlyphs = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 535
    Width = 949
    Height = 41
    Align = alBottom
    TabOrder = 2
    object SpeedButtonSaveAllSources: TSpeedButton
      Left = 402
      Top = 6
      Width = 153
      Height = 22
      Caption = 'Save All Sources'
      OnClick = SpeedButtonSaveAllSourcesClick
    end
  end
  object MainMenu: TMainMenu
    Left = 248
    Top = 56
  end
  object SigRegistry: TSigRegistry
    Left = 720
    Top = 48
  end
  object SigSaveDialogMain: TSigSaveDialog
    DefaultExt = 'dbb'
    Filter = 'DBBuilder files(*.dbb)|*.dbb|Pascal Files(*.pas)|*.pas'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    SigRegistry = SigRegistry
    Left = 776
    Top = 48
  end
  object ImageListUndoRedo: TImageList
    Left = 848
    Top = 56
    Bitmap = {
      494C010104000A00C80010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000080000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000008000000000000000000000000000000080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800000000000000000000000000080000000FF0000008080
      0000808000008000000080000000800000008000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008080
      0000808000008000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C0008080800080808000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080800080808000C0C0
      C000C0C0C0008080800000000000000000000000000080000000808000008080
      0000808000008080000080800000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080800000808000008080
      0000808000008080000080000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008080800080808000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000080000000808000008080
      0000808000008080000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000080800000808000008080
      0000808000008080000080000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000080000000808000008080
      0000808000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000808000008080
      0000808000008080000080000000000000000000000080808000C0C0C000C0C0
      C000C0C0C0008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000000000000000000080000000800000008000
      0000808000008080000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000808000008080
      0000808000008080000080000000800000000000000080808000C0C0C0008080
      8000C0C0C000C0C0C00080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C00080808000808080000000000080000000800000000000
      0000800000008080000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000808000008080
      0000808000008000000080000000800000000000000080808000808080000000
      000080808000C0C0C00080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C0008080800080808000808080000000000080000000000000000000
      0000800000008080800080808000800000000000000000000000000000000000
      0000000000008000000080000000000000000000000080000000000000000000
      0000000000000000000000000000000000008000000080808000808080008080
      0000800000000000000000000000800000000000000080808000000000000000
      000080808000C0C0C000C0C0C000808080000000000000000000000000000000
      0000000000008080800080808000000000000000000080808000000000000000
      00000000000000000000000000000000000080808000C0C0C000C0C0C000C0C0
      C000808080000000000000000000808080000000000000000000000000000000
      00000000000080000000C0C0C000808080008000000080000000000000000000
      0000800000008000000000000000000000000000000000000000800000008000
      00000000000000000000000000008000000080808000C0C0C000808000008000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080808000C0C0C000C0C0C0008080800080808000808080000000
      0000808080008080800000000000000000000000000000000000808080008080
      800000000000000000000000000080808000C0C0C000C0C0C000C0C0C0008080
      8000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008000000080808000C0C0C00080000000800000008000
      0000800000000000000000000000000000000000000000000000000000008000
      0000800000008000000080000000C0C0C0008080800080800000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000808080000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000C0C0C000C0C0C000C0C0C000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800080808000808080008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFBFFFFFFFB87FFFFE387FFFFE3807FFF83807FFF8380FFFE0180FFFE01
      81FFFF0181FFFF0183FFFF8183FFFF8181FFFF8081FFFF8091FFFF8091FFFF80
      B0F9BF06B0F9BF06F833CE0FF813CE0FFC07E01FFC07E01FFE1FF83FFE1FF83F
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object PreviewPrinterMain: TPreviewPrinter
    Orientation = poPortrait
    TextOptions.DrawStyle = dsStandard
    TextOptions.MarginLeft = 1.000000000000000000
    TextOptions.MarginTop = 1.000000000000000000
    TextOptions.MarginRight = 1.000000000000000000
    TextOptions.MarginBottom = 1.000000000000000000
    TextOptions.BodyFont.Charset = DEFAULT_CHARSET
    TextOptions.BodyFont.Color = clWindowText
    TextOptions.BodyFont.Height = -13
    TextOptions.BodyFont.Name = 'Arial'
    TextOptions.BodyFont.Style = []
    TextOptions.HeaderFont.Charset = DEFAULT_CHARSET
    TextOptions.HeaderFont.Color = clWindowText
    TextOptions.HeaderFont.Height = -24
    TextOptions.HeaderFont.Name = 'Times New Roman'
    TextOptions.HeaderFont.Style = [fsBold]
    TextOptions.FooterFont.Charset = DEFAULT_CHARSET
    TextOptions.FooterFont.Color = clWindowText
    TextOptions.FooterFont.Height = -13
    TextOptions.FooterFont.Name = 'Times New Roman'
    TextOptions.FooterFont.Style = [fsItalic]
    TextOptions.PageNumFont.Charset = DEFAULT_CHARSET
    TextOptions.PageNumFont.Color = clWindowText
    TextOptions.PageNumFont.Height = -13
    TextOptions.PageNumFont.Name = 'Times New Roman'
    TextOptions.PageNumFont.Style = [fsItalic]
    TextOptions.HeaderMargin = 0.500000000000000000
    TextOptions.FooterMargin = 0.750000000000000000
    TextOptions.HeaderAlign = taCenter
    TextOptions.FooterAlign = taCenter
    TextOptions.PrintPageNumber = pnBottom
    TextOptions.PageNumAlign = taRightJustify
    TextOptions.PageNumText = 'Page %d'
    Units = unInches
    ShowGrid = False
    ZoomOption = zoFitToPage
    ZoomVal = 100
    UsePrinterOrientation = True
    Left = 312
    Top = 56
  end
  object PrintDialog: TPrintDialog
    Options = [poPageNums]
    Left = 384
    Top = 56
  end
  object PrinterSetupDialog: TPrinterSetupDialog
    Left = 448
    Top = 56
  end
  object SigGridEditorFieldID: TSigGridEditor
    SigGrid = SigGeneralGridFields
    Style = esSpinEdit
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'ID')
    ParentColWidth = False
    Left = 56
    Top = 344
  end
  object SigGridEditorFieldName: TSigGridEditor
    SigGrid = SigGeneralGridFields
    Style = esMaskEdit
    Column = 1
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Field Name')
    ParentColWidth = False
    ColWidth = 180
    Left = 56
    Top = 376
  end
  object SigGridEditorFieldType: TSigGridEditor
    SigGrid = SigGeneralGridFields
    Style = esMaskEdit
    Column = 2
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'FieldType')
    ParentColWidth = False
    ColWidth = 180
    Left = 56
    Top = 328
  end
  object SigGridEditorCompareStyle: TSigGridEditor
    SigGrid = SigGeneralGridFields
    Style = esDropDownList
    Column = 3
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Compare Style')
    ParentColWidth = False
    ColWidth = 120
    Left = 56
    Top = 408
  end
  object SigGridEditorIndexField: TSigGridEditor
    SigGrid = SigGeneralGridIndexes
    Style = esDropDownList
    Column = 1
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Field')
    ParentColWidth = False
    ColWidth = 160
    Left = 176
    Top = 392
  end
  object SigGridEditorOrder: TSigGridEditor
    SigGrid = SigGeneralGridIndexes
    Style = esDropDown
    Column = 2
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Order/Filter')
    ParentColWidth = False
    ColWidth = 120
    ItemsList.Strings = (
      'Index Ascending'
      'Index Descending'
      'Filter <'
      'Filter <='
      'Filter ='
      'Filter <>'
      'Filter >='
      'Filter >'
      'Filter contains'
      'Filter does not contain'
      'Test Changed')
    Left = 320
    Top = 376
  end
  object SigGridEditorIndexCompare: TSigGridEditor
    SigGrid = SigGeneralGridIndexes
    Style = esMaskEdit
    Column = 3
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Compare with (filter)')
    ParentColWidth = False
    ColWidth = 120
    Left = 176
    Top = 352
  end
  object SigGridEditorIndexSeq: TSigGridEditor
    SigGrid = SigGeneralGridIndexes
    Titles.Strings = (
      'Seq')
    Left = 176
    Top = 304
  end
  object SigGridEditorFindParm1: TSigGridEditor
    SigGrid = SigGeneralGridFind
    Style = esDropDownList
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Find Mode')
    ParentColWidth = False
    ColWidth = 150
    ItemsList.Strings = (
      'Find( Variable )'
      'Find( Equal )'
      'Find( Less Than or Equal )'
      'Find( Greater Than or Equal )'
      'First'
      'Next'
      'Prev'
      'Last')
    MaxVal = 10
    MinVal = 1
    Left = 472
    Top = 208
  end
  object SigGridEditorFieldComment: TSigGridEditor
    SigGrid = SigGeneralGridFields
    Style = esMaskEdit
    Column = 4
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Field Name/Title')
    ParentColWidth = False
    ColWidth = 128
    Left = 56
    Top = 296
  end
  object ImageListChecked: TImageList
    Height = 24
    Masked = False
    Width = 24
    Left = 848
    Top = 120
    Bitmap = {
      494C010102000800640018001800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000600000001800000001002000000000000024
      000000000000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0C0C000C0C0C00080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C0C0C000C0C0C00080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000000080000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000008000000080000080000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF0080000000008000000080000000800000008000008000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF008000000000800000008000000080000000800000008000000080
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF008000000000800000008000000080000000FF000000800000008000000080
      00000080000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF0000800000008000000080000000FF0000FFFFFF0000FF0000008000000080
      00000080000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF0000FF00000080000000FF0000FFFFFF00FFFFFF00FFFFFF0000FF00000080
      0000008000000080000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF0000FF0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      000000800000008000000080000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000FF000000800000008000000080000080000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000FF000000800000008000000080000080000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000FF000000800000008000000080000080000000FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FF00000080000000800000008000008000
      0000FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000800000008000008000
      0000FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF0000008000000080
      0000FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF0000FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C000C0C0C0008080800000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C0C0C000C0C0C00080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000C0C0C000C0C0C00080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000060000000180000000100010000000000200100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object SigGridEditorKeyCount: TSigGridEditor
    SigGrid = SigGeneralGridFind
    Style = esSpinEdit
    Column = 1
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Key count')
    ParentColWidth = False
    MaxVal = 100
    Left = 472
    Top = 256
  end
  object SigGridEditorMatchCount: TSigGridEditor
    SigGrid = SigGeneralGridFind
    Style = esSpinEdit
    Column = 2
    ParentAutoSizeColumn = False
    Titles.Strings = (
      'Match count')
    ParentColWidth = False
    MaxVal = 100
    MinVal = -1
    Left = 472
    Top = 328
  end
end
