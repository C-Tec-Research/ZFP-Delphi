object FrameSigDBFileStructure: TFrameSigDBFileStructure
  Left = 0
  Top = 0
  Width = 710
  Height = 329
  TabOrder = 0
  OnResize = FrameResize
  object SigPanel1: TSigPanel
    Left = 0
    Top = 0
    Width = 710
    Height = 329
    Align = alClient
    Caption = 'SigPanel1'
    TabOrder = 0
    object SigPanelTop: TSigPanel
      Left = 1
      Top = 1
      Width = 708
      Height = 72
      Align = alTop
      BevelOuter = bvRaised
      Caption = 'SigPanelTop'
      TabOrder = 0
      PanelStyle = psChildTop
      object SigPanelOptions: TSigPanel
        Left = 1
        Top = 1
        Width = 384
        Height = 70
        Align = alLeft
        Caption = 'SigPanelOptions'
        TabOrder = 0
        PanelStyle = psChildLeft
        object SpeedButtonShowNow: TSpeedButton
          Left = 248
          Top = 5
          Width = 42
          Height = 50
          Caption = 'Show'
          OnClick = SpeedButtonShowNowClick
        end
        object Label3: TLabel
          Left = 24
          Top = 8
          Width = 45
          Height = 13
          Caption = 'From Rec'
        end
        object Label4: TLabel
          Left = 24
          Top = 35
          Width = 52
          Height = 13
          Caption = 'Max Count'
        end
        object SpeedButtonReindex: TSpeedButton
          Left = 296
          Top = 5
          Width = 58
          Height = 50
          Caption = 'Reindex'
          OnClick = SpeedButtonReindexClick
        end
        object SigSpinEditFromRec: TSigSpinEdit
          Left = 120
          Top = 5
          Width = 105
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 1
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
        object SigSpinEditMaxCount: TSigSpinEdit
          Left = 120
          Top = 33
          Width = 105
          Height = 22
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxValue = 0
          MinValue = 0
          ParentFont = False
          TabOrder = 1
          Value = 100
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
      end
      object SigPanel5: TSigPanel
        Left = 385
        Top = 1
        Width = 322
        Height = 70
        Align = alClient
        Caption = 'SigPanel5'
        TabOrder = 1
        PanelStyle = psChildFill
        ExplicitLeft = 361
        ExplicitWidth = 346
        object Label1: TLabel
          Left = 16
          Top = 8
          Width = 38
          Height = 13
          Caption = 'Last Ins'
        end
        object Label2: TLabel
          Left = 16
          Top = 35
          Width = 38
          Height = 13
          Caption = 'Last Del'
        end
        object Label5: TLabel
          Left = 192
          Top = 8
          Width = 50
          Height = 13
          Caption = 'Rec Count'
        end
        object EditLastIns: TEdit
          Left = 80
          Top = 5
          Width = 73
          Height = 21
          ReadOnly = True
          TabOrder = 0
          Text = 'EditLastIns'
        end
        object EditLastDel: TEdit
          Left = 80
          Top = 32
          Width = 73
          Height = 21
          ReadOnly = True
          TabOrder = 1
          Text = 'EditLastDel'
        end
        object EditRecCount: TEdit
          Left = 176
          Top = 32
          Width = 89
          Height = 21
          ReadOnly = True
          TabOrder = 2
          Text = 'EditRecCount'
        end
      end
    end
    object SigPanel3: TSigPanel
      Left = 1
      Top = 73
      Width = 708
      Height = 255
      Align = alClient
      BevelOuter = bvRaised
      Caption = 'SigPanel3'
      TabOrder = 1
      PanelStyle = psChildFill
      object SigGeneralGridIndexFile: TSigGeneralGrid
        Left = 1
        Top = 1
        Width = 706
        Height = 253
        Align = alClient
        ColCount = 8
        DefaultColWidth = 32
        DefaultRowHeight = 16
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
          38
          64
          63
          64
          57
          63
          66
          35)
      end
    end
  end
  object SigGridEditorRecNo: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Rec#')
    ParentColWidth = False
    ColWidth = 32
    Left = 88
    Top = 112
  end
  object SigGridEditorNext: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 1
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Next Rec#')
    ParentColWidth = False
    ColWidth = 32
    Left = 88
    Top = 168
  end
  object SigGridEditorPrev: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 2
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Prev Rec#'
      '')
    ParentColWidth = False
    ColWidth = 32
    Left = 88
    Top = 224
  end
  object SigGridEditorData: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 3
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Data Rec#')
    ParentColWidth = False
    ColWidth = 32
    Left = 208
    Top = 112
  end
  object SigGridEditorLeftChild: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 4
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Left Child')
    ParentColWidth = False
    ColWidth = 32
    Left = 208
    Top = 168
  end
  object SigGridEditorRightChild: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 5
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Right Child')
    ParentColWidth = False
    ColWidth = 32
    Left = 216
    Top = 224
  end
  object SigGridEditorTreeDepth: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 6
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Tree Depth'
      '')
    ParentColWidth = False
    ColWidth = 32
    Left = 344
    Top = 104
  end
  object SigGridEditorDataVal: TSigGridEditor
    SigGrid = SigGeneralGridIndexFile
    Column = 7
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Data')
    ParentColWidth = False
    Left = 345
    Top = 161
  end
end
