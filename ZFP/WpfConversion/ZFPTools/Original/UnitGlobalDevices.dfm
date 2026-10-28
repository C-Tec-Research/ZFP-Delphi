object FrameGlobalDevices: TFrameGlobalDevices
  Left = 0
  Top = 0
  Width = 906
  Height = 485
  TabOrder = 0
  OnResize = FrameResize
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 906
    Height = 485
    Align = alClient
    AutoSize = True
    BevelOuter = bvLowered
    TabOrder = 0
    object PageControlPanelDevices: TPageControl
      Left = 1
      Top = 1
      Width = 904
      Height = 483
      ActivePage = TabSheetDeviceSummary
      Align = alClient
      TabOrder = 0
      object TabSheetDeviceSummary: TTabSheet
        Caption = 'Device Summary'
        object SigGeneralGridGlobalDevices: TSigGeneralGrid
          Left = 0
          Top = 0
          Width = 896
          Height = 455
          Align = alClient
          ColCount = 11
          DefaultRowHeight = 19
          DrawingStyle = gdsClassic
          FixedCols = 4
          RowCount = 0
          FixedRows = 2
          Options = [goFixedVertLine, goVertLine, goHorzLine, goRangeSelect, goFixedRowClick]
          TabOrder = 0
          Visible = True
          OnDrawCell = SigGeneralGridGlobalDevicesDrawCell
          AutoSizeRows = True
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
            30
            35
            51
            44
            32
            180
            64
            70
            70
            70
            64)
        end
      end
      object TabSheetZonalSummary: TTabSheet
        Caption = 'Zonal Summary'
        ImageIndex = 1
        object SigGeneralGridZonalSummary: TSigGeneralGrid
          Left = 0
          Top = 0
          Width = 896
          Height = 455
          Align = alClient
          ColCount = 9
          DefaultRowHeight = 16
          DrawingStyle = gdsClassic
          FixedCols = 8
          RowCount = 0
          FixedRows = 2
          Options = [goFixedVertLine, goVertLine, goHorzLine, goRangeSelect]
          TabOrder = 0
          Visible = True
          OnDrawCell = SigGeneralGridZonalSummaryDrawCell
          AutoSizeRows = True
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
            32
            150
            32
            48
            48
            180
            32
            180)
        end
      end
    end
  end
  object SigGridEditorLoop: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Column = 1
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Loop'
      'ID')
    ParentColWidth = False
    ColWidth = 30
    Left = 48
    Top = 224
  end
  object SigGridEditorDevice: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Column = 2
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Device'
      'Address')
    ParentColWidth = False
    ColWidth = 45
    Left = 48
    Top = 272
  end
  object SigGridEditorDeviceType: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Column = 3
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Device'
      'Type')
    ParentColWidth = False
    ColWidth = 40
    Left = 48
    Top = 320
  end
  object SigGridEditorDeviceImage: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esImageList
    Column = 4
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Dev'
      'Image')
    ParentColWidth = False
    ColWidth = 32
    Left = 48
    Top = 368
  end
  object SigGridEditorDevName: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esMaskEdit
    Column = 5
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Device'
      'Name')
    ParentColWidth = False
    ColWidth = 180
    Left = 48
    Top = 416
  end
  object SigGridEditorLoopName: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Titles.Strings = (
      'Loop'
      'Name')
    ParentColWidth = False
    ColWidth = 30
    Left = 48
    Top = 176
  end
  object SigGridEditorZoneName: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Titles.Strings = (
      'Zone'
      'Name')
    ParentColWidth = False
    ColWidth = 150
    Left = 216
    Top = 128
  end
  object SigGridEditorZoneLoopName: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 2
    Titles.Strings = (
      'Loop'
      'Name')
    ParentColWidth = False
    ColWidth = 150
    Left = 216
    Top = 176
  end
  object SigGridEditorZoneLoop: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 3
    Titles.Strings = (
      'Loop'
      'ID')
    ParentColWidth = False
    ColWidth = 32
    Left = 216
    Top = 224
  end
  object SigGridEditorZoneLoopSubdevices: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 5
    Titles.Strings = (
      'Sub'
      'Devices')
    ParentColWidth = False
    ColWidth = 48
    Left = 376
    Top = 272
  end
  object SigGridEditorZoneDevice: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 4
    Titles.Strings = (
      'Device'
      'Address')
    ParentColWidth = False
    ColWidth = 48
    Left = 216
    Top = 272
  end
  object SigGridEditorZoneDeviceType: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 6
    Titles.Strings = (
      'Device'
      'Type')
    ParentColWidth = False
    ColWidth = 180
    Left = 216
    Top = 320
  end
  object SigGridEditorZoneDeviceImage: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Style = esImageList
    Column = 7
    Titles.Strings = (
      'Dev'
      'Image')
    ParentColWidth = False
    ColWidth = 32
    Left = 216
    Top = 368
  end
  object SigGridEditorZoneDeviceName: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 8
    Titles.Strings = (
      'Device'
      'Name')
    ParentColWidth = False
    ColWidth = 180
    Left = 216
    Top = 416
  end
  object SigGridEditorZoneID: TSigGridEditor
    SigGrid = SigGeneralGridZonalSummary
    Column = 1
    Titles.Strings = (
      'Zone'
      'ID')
    ParentColWidth = False
    ColWidth = 32
    Left = 376
    Top = 128
  end
  object SigGridEditorDevIG: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esButton
    Column = 7
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Input'
      'Group')
    ParentColWidth = False
    Left = 376
    Top = 216
  end
  object SigGridEditorDevOG: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esButton
    Column = 8
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Output'
      'Group')
    ParentColWidth = False
    Left = 376
    Top = 184
  end
  object SigGridEditorDevZone: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esButton
    Column = 6
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Zone')
    ParentColWidth = False
    Left = 376
    Top = 328
  end
  object SigGridEditorDevDisablement: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esButton
    Column = 9
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Disablement'
      'Activates')
    ParentColWidth = False
    Left = 480
    Top = 144
  end
  object SigGridEditorFaultGroup: TSigGridEditor
    SigGrid = SigGeneralGridGlobalDevices
    Style = esButton
    Column = 10
    ParentAutoSizeColumn = False
    AutoSizeColumn = True
    Titles.Strings = (
      'Fault'
      'Activates')
    ParentColWidth = False
    Left = 480
    Top = 208
  end
end
