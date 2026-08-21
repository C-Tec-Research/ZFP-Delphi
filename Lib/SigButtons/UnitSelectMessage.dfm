object FormSelectMessage: TFormSelectMessage
  Left = 232
  Top = 108
  Width = 475
  Height = 352
  Caption = 'Select Message'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MediaPlayer: TMediaPlayer
    Left = 312
    Top = 216
    Width = 85
    Height = 30
    VisibleButtons = [btPlay, btPause, btStop]
    TabOrder = 0
  end
  object DriveComboBoxSelectMessage: TDriveComboBox
    Left = 32
    Top = 16
    Width = 209
    Height = 19
    DirList = DirectoryListBoxSelectMessage
    TabOrder = 1
  end
  object DirectoryListBoxSelectMessage: TDirectoryListBox
    Left = 32
    Top = 56
    Width = 209
    Height = 193
    FileList = FileListBoxSelectMessage
    ItemHeight = 16
    TabOrder = 2
  end
  object FileListBoxSelectMessage: TFileListBox
    Left = 264
    Top = 16
    Width = 193
    Height = 185
    ExtendedSelect = False
    ItemHeight = 13
    Mask = '*.WAV'
    TabOrder = 3
    OnClick = FileListBoxSelectMessageClick
  end
  object BitBtn1: TBitBtn
    Left = 152
    Top = 280
    Width = 75
    Height = 25
    TabOrder = 4
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 256
    Top = 280
    Width = 75
    Height = 25
    TabOrder = 5
    Kind = bkCancel
  end
end
