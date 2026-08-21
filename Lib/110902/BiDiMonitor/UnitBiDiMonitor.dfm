object FormBiDiMonitor: TFormBiDiMonitor
  Left = 0
  Top = 0
  Caption = 'Bi Di Monitor'
  ClientHeight = 341
  ClientWidth = 752
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PanelOptions: TPanel
    Left = 0
    Top = 0
    Width = 752
    Height = 49
    Align = alTop
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 128
      Top = 16
      Width = 105
      Height = 22
      Caption = 'Clear'
      OnClick = SpeedButton1Click
    end
    object CheckBoxLinkFormats: TCheckBox
      Left = 24
      Top = 17
      Width = 97
      Height = 17
      Caption = 'Link Formats'
      TabOrder = 0
    end
  end
  object PanelTx: TPanel
    Left = 0
    Top = 49
    Width = 376
    Height = 292
    Align = alLeft
    TabOrder = 1
    object PageControlTx: TPageControl
      Left = 1
      Top = 19
      Width = 374
      Height = 272
      ActivePage = TabSheetTxAFP
      Align = alClient
      TabOrder = 0
      object TabSheetTxASCII: TTabSheet
        Caption = 'ASCII'
      end
      object TabSheetTxHex: TTabSheet
        Caption = 'Hex'
        ImageIndex = 1
      end
      object TabSheetTxAFP: TTabSheet
        Caption = 'AFP'
        ImageIndex = 2
        object PageControlTxAFP: TPageControl
          Left = 0
          Top = 0
          Width = 366
          Height = 244
          ActivePage = TabSheetTxAFPASCII
          Align = alClient
          TabOrder = 0
          object TabSheetRxAFPHex: TTabSheet
            Caption = 'Hex'
            object SigNETStringGridTxAFPHex: TSigNETStringGrid
              Left = 0
              Top = 0
              Width = 358
              Height = 216
              Align = alClient
              DefaultColWidth = 48
              DefaultRowHeight = 16
              TabOrder = 0
            end
          end
          object TabSheetTxAFPASCII: TTabSheet
            Caption = 'ASCII'
            ImageIndex = 1
            object SigNETStringGridTxAFPASCII: TSigNETStringGrid
              Left = 0
              Top = 0
              Width = 358
              Height = 216
              Align = alClient
              ColCount = 6
              DefaultColWidth = 48
              DefaultRowHeight = 16
              RowCount = 50
              TabOrder = 0
              ColWidths = (
                48
                48
                48
                48
                48
                90)
            end
          end
        end
      end
    end
    object PanelTransmissionCaption: TPanel
      Left = 1
      Top = 1
      Width = 374
      Height = 18
      Align = alTop
      Caption = 'Transmission'
      TabOrder = 1
    end
  end
  object PanelRcv: TPanel
    Left = 376
    Top = 49
    Width = 376
    Height = 292
    Align = alClient
    TabOrder = 2
    object PageControlRx: TPageControl
      Left = 1
      Top = 19
      Width = 374
      Height = 272
      ActivePage = TabSheetRxAFP
      Align = alClient
      TabOrder = 0
      object TabSheetRxASCII: TTabSheet
        Caption = 'ASCII'
      end
      object TabSheetRxHex: TTabSheet
        Caption = 'Hex'
        ImageIndex = 1
      end
      object TabSheetRxAFP: TTabSheet
        Caption = 'AFP'
        ImageIndex = 2
        object PageControlRxAFP: TPageControl
          Left = 0
          Top = 0
          Width = 366
          Height = 244
          ActivePage = TabSheet2
          Align = alClient
          TabOrder = 0
          object TabSheet1: TTabSheet
            Caption = 'Hex'
            object SigNETStringGridRxAFPHex: TSigNETStringGrid
              Left = 0
              Top = 0
              Width = 358
              Height = 216
              Align = alClient
              DefaultColWidth = 48
              DefaultRowHeight = 16
              TabOrder = 0
            end
          end
          object TabSheet2: TTabSheet
            Caption = 'ASCII'
            ImageIndex = 1
            object SigNETStringGridRxAFPASCII: TSigNETStringGrid
              Left = 0
              Top = 0
              Width = 358
              Height = 216
              Align = alClient
              ColCount = 6
              DefaultColWidth = 48
              DefaultRowHeight = 16
              RowCount = 50
              TabOrder = 0
              ColWidths = (
                48
                48
                48
                48
                48
                90)
            end
          end
        end
      end
    end
    object PanelReceptionCaption: TPanel
      Left = 1
      Top = 1
      Width = 374
      Height = 18
      Align = alTop
      Caption = 'Reception'
      TabOrder = 1
    end
  end
end
