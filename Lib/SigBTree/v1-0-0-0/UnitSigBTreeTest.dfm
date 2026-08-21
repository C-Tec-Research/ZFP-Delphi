object FormBTreeTest: TFormBTreeTest
  Left = 0
  Top = 0
  Caption = 'BTree Test'
  ClientHeight = 360
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 527
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object SpeedButtonAdd: TSpeedButton
      Left = 248
      Top = 7
      Width = 89
      Height = 22
      Caption = 'Add'
      OnClick = SpeedButtonAddClick
    end
    object EditAdd: TEdit
      Left = 88
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 0
      OnKeyPress = EditAddKeyPress
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 319
    Width = 527
    Height = 41
    Align = alBottom
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object BitBtn1: TBitBtn
      Left = 232
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      ModalResult = 1
      NumGlyphs = 2
      TabOrder = 0
      OnClick = BitBtn1Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 41
    Width = 527
    Height = 278
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object PaintBoxBinaryTree: TPaintBox
      Left = 1
      Top = 1
      Width = 525
      Height = 276
      Align = alClient
      ExplicitLeft = 168
      ExplicitTop = 104
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
  end
end
