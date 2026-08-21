object FrameLCDText: TFrameLCDText
  Left = 0
  Top = 0
  Width = 493
  Height = 113
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 493
    Height = 113
    Align = alClient
    BevelInner = bvLowered
    BevelWidth = 3
    TabOrder = 0
    OnResize = Panel1Resize
    ExplicitLeft = 4
    ExplicitTop = 3
    ExplicitWidth = 464
    ExplicitHeight = 101
    object MemoText: TMemo
      Left = 6
      Top = 6
      Width = 481
      Height = 101
      Align = alClient
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = 44
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      Lines.Strings = (
        'MemoText'
        '12345678901234567890')
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 4
      ExplicitWidth = 452
      ExplicitHeight = 89
    end
  end
end
