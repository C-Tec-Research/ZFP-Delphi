object FormDongleInterface: TFormDongleInterface
  Left = 0
  Top = 0
  Caption = 'FormDongleInterface'
  ClientHeight = 243
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object USBPanel: TUSBPanel
    Left = 144
    Top = 56
    Width = 185
    Height = 121
    Caption = 'USBPanel'
    TabOrder = 0
    VendorID = '0403'
    ProductID = 'DBC0'
    Manufacturer = 'C-Tec'
    ManufacturerID = 'CT'
    Description = 'USB HS Serial Connector'
    SerialNo = 'CT000001'
    ErrorStyle = esHideErrors
    USBVersion = '0200'
  end
end
