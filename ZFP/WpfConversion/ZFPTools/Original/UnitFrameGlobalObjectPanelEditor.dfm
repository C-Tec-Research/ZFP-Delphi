object FrameGlobalObjectPanelEditor: TFrameGlobalObjectPanelEditor
  Left = 0
  Top = 0
  Width = 1137
  Height = 676
  TabOrder = 0
  object Panel17: TPanel
    Left = 486
    Top = 0
    Width = 651
    Height = 676
    Align = alRight
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    object Panel18: TPanel
      Left = 1
      Top = 1
      Width = 649
      Height = 674
      Align = alClient
      TabOrder = 0
      object Panel42: TPanel
        Left = 1
        Top = 1
        Width = 647
        Height = 39
        Align = alTop
        Caption = 'Properties'
        TabOrder = 0
      end
      object Panel43: TPanel
        Left = 1
        Top = 40
        Width = 647
        Height = 633
        Align = alClient
        TabOrder = 1
        object SigVariableEditorList: TSigVariableEditorList
          Left = 1
          Top = 1
          Width = 645
          Height = 631
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  object Panel44: TPanel
    Left = 0
    Top = 0
    Width = 486
    Height = 676
    Align = alClient
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 1
    object SigGeneralGridUsage: TSigGeneralGrid
      Left = 1
      Top = 41
      Width = 484
      Height = 634
      Align = alClient
      ColCount = 3
      FixedCols = 0
      RowCount = 0
      TabOrder = 0
      Visible = True
      NormalFont.Charset = DEFAULT_CHARSET
      NormalFont.Color = clWindowText
      NormalFont.Height = -11
      NormalFont.Name = 'Tahoma'
      NormalFont.Style = []
      ErrorFont.Charset = DEFAULT_CHARSET
      ErrorFont.Color = clRed
      ErrorFont.Height = -11
      ErrorFont.Name = 'Tahoma'
      ErrorFont.Style = [fsBold, fsItalic]
      ColWidths = (
        256
        64
        24)
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 484
      Height = 40
      Align = alTop
      Caption = 'Usage on this panel'
      TabOrder = 1
      object SpeedButtonShowHide: TSpeedButton
        Left = 312
        Top = 8
        Width = 161
        Height = 22
        AllowAllUp = True
        GroupIndex = 1
        Caption = 'Show/Hide Unused'
      end
    end
  end
end
