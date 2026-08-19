object FrameSimSystem: TFrameSimSystem
  Left = 0
  Top = 0
  Width = 605
  Height = 333
  TabOrder = 0
  object SigPanelMain: TSigPanel
    Left = 0
    Top = 0
    Width = 605
    Height = 333
    Align = alClient
    Caption = 'SigPanelMain'
    TabOrder = 0
    object SigGeneralGridSimSystem: TSigGeneralGrid
      Left = 1
      Top = 1
      Width = 487
      Height = 331
      Align = alClient
      ColCount = 4
      DefaultColWidth = 20
      RowCount = 1
      TabOrder = 0
      Visible = False
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
        20
        100
        100
        100)
      RowHeights = (
        24
        24
        24
        24
        24)
    end
    object SigPanelRight: TSigPanel
      Left = 488
      Top = 1
      Width = 116
      Height = 331
      Align = alRight
      Caption = 'SigPanelRight'
      TabOrder = 1
      object RadioButtonDefault: TRadioButton
        Left = 6
        Top = 16
        Width = 113
        Height = 17
        Caption = 'Keep Typcodes?'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object RadioButtonSounders: TRadioButton
        Left = 6
        Top = 39
        Width = 113
        Height = 17
        Caption = 'Change Sounders?'
        TabOrder = 1
      end
      object RadioButtonAllDevices: TRadioButton
        Left = 6
        Top = 62
        Width = 113
        Height = 17
        Caption = 'Change All?'
        TabOrder = 2
      end
    end
  end
  object SigGridEditorPanelName: TSigGridEditor
    SigGrid = SigGeneralGridSimSystem
    Column = 1
    Titles.Strings = (
      'Panel Name')
    ParentColWidth = False
    ColWidth = 100
    Left = 56
    Top = 144
  end
  object SigGridEditorPanelID: TSigGridEditor
    SigGrid = SigGeneralGridSimSystem
    Column = 2
    Titles.Strings = (
      'Panel ID')
    ParentColWidth = False
    ColWidth = 100
    Left = 176
    Top = 144
  end
  object SigGridEditorFileID: TSigGridEditor
    SigGrid = SigGeneralGridSimSystem
    Style = esSpinEdit
    Column = 3
    Titles.Strings = (
      'File ID')
    ParentColWidth = False
    ColWidth = 100
    Left = 280
    Top = 144
  end
end
