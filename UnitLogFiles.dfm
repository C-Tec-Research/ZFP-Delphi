object FrameLogFiles: TFrameLogFiles
  Left = 0
  Top = 0
  Width = 839
  Height = 499
  TabOrder = 0
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 839
    Height = 499
    Align = alClient
    TabOrder = 0
    object TabControlLogs: TTabControl
      Left = 1
      Top = 1
      Width = 837
      Height = 497
      Align = alClient
      TabOrder = 0
      object SigPanelLog: TSigPanel
        Left = 4
        Top = 6
        Width = 829
        Height = 487
        Align = alClient
        ShowCaption = True
        TabOrder = 0
        object MemoLog: TMemo
          Left = 1
          Top = 1
          Width = 827
          Height = 235
          Align = alTop
          Lines.Strings = (
            'MemoLog')
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object StringGridLog: TStringGrid
          Left = 1
          Top = 236
          Width = 827
          Height = 250
          Align = alClient
          DefaultColWidth = 16
          DefaultRowHeight = 16
          TabOrder = 1
          ExplicitLeft = 272
          ExplicitTop = 320
          ExplicitWidth = 320
          ExplicitHeight = 120
        end
      end
    end
  end
end
