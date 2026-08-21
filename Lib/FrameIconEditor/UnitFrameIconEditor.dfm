object FrameIconEditor: TFrameIconEditor
  Left = 0
  Top = 0
  Width = 370
  Height = 240
  TabOrder = 0
  object PanelEdit: TPanel
    Left = 0
    Top = 199
    Width = 370
    Height = 41
    Align = alBottom
    TabOrder = 0
    object BitBtnLoadNew: TBitBtn
      Left = 216
      Top = 6
      Width = 113
      Height = 25
      Caption = 'Add New Icon...'
      TabOrder = 0
      OnClick = BitBtnLoadNewClick
    end
    object BitBtn1: TBitBtn
      Left = 40
      Top = 6
      Width = 113
      Height = 25
      Caption = 'Add New Group...'
      TabOrder = 1
      OnClick = BitBtn1Click
    end
  end
  object TabControlClasses: TTabControl
    Left = 0
    Top = 0
    Width = 370
    Height = 199
    Align = alClient
    TabOrder = 1
    Tabs.Strings = (
      '<All>')
    TabIndex = 0
    OnChange = TabControlClassesChange
    object StringGridMain: TStringGrid
      Left = 4
      Top = 24
      Width = 362
      Height = 171
      Align = alClient
      DefaultColWidth = 32
      DefaultRowHeight = 32
      TabOrder = 0
      OnDrawCell = SigNETStringGridMainDrawCell
      ExplicitLeft = 88
      ExplicitTop = 88
      ExplicitWidth = 320
      ExplicitHeight = 120
    end
  end
  object ImageListMain: TImageList
    Height = 32
    Masked = False
    Width = 32
    Left = 32
    Top = 16
  end
  object OpenPictureDialog: TOpenPictureDialog
    Left = 248
    Top = 88
  end
end
