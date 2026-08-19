object FormTest: TFormTest
  Left = 0
  Top = 0
  Caption = 'Ping Test'
  ClientHeight = 501
  ClientWidth = 611
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn2: TBitBtn
    Left = 246
    Top = 448
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object GroupBoxDevicesConnected: TGroupBox
    Left = 32
    Top = 16
    Width = 545
    Height = 169
    Caption = 'Devices Connected'
    TabOrder = 1
    object SpeedButtonCheckDevices: TSpeedButton
      Left = 134
      Top = 144
      Width = 267
      Height = 22
      Caption = 'Check For  Devices Connected'
      OnClick = SpeedButtonCheckDevicesClick
    end
    object LabelNoDevicesFound: TLabel
      Left = 80
      Top = 70
      Width = 98
      Height = 13
      Caption = 'No Devices Found'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object RadioGroupDevicesConnected: TRadioGroup
      Left = 32
      Top = 24
      Width = 481
      Height = 114
      TabOrder = 0
    end
  end
  object GroupBoxPing: TGroupBox
    Left = 32
    Top = 200
    Width = 545
    Height = 233
    Caption = 'Ping'
    TabOrder = 2
    object Label1: TLabel
      Left = 96
      Top = 53
      Width = 69
      Height = 13
      Caption = 'Tx Packet Size'
    end
    object Label2: TLabel
      Left = 80
      Top = 114
      Width = 79
      Height = 13
      Caption = 'Packets To Send'
    end
    object SpeedButtonPing: TSpeedButton
      Left = 192
      Top = 192
      Width = 121
      Height = 22
      Caption = 'Ping'
      OnClick = SpeedButtonPingClick
    end
    object Label3: TLabel
      Left = 96
      Top = 85
      Width = 70
      Height = 13
      Caption = 'Rx Packet Size'
    end
    object SigSpinEditTxPacketSize: TSigSpinEdit
      Left = 192
      Top = 48
      Width = 121
      Height = 22
      Increment = 100
      MaxValue = 50000
      MinValue = 1
      TabOrder = 0
      Value = 30
    end
    object SigSpinEditPacketsToSend: TSigSpinEdit
      Left = 192
      Top = 108
      Width = 121
      Height = 22
      Increment = 100
      MaxValue = 50000
      MinValue = 1
      TabOrder = 1
      Value = 500
      OnChange = SigSpinEditPacketsToSendChange
    end
    object ProgressBarPacketsSent: TProgressBar
      Left = 32
      Top = 153
      Width = 481
      Height = 17
      Max = 500
      Smooth = True
      TabOrder = 2
    end
    object SigSpinEditRxPacketSize: TSigSpinEdit
      Left = 192
      Top = 80
      Width = 121
      Height = 22
      Increment = 100
      MaxValue = 50000
      MinValue = 1
      TabOrder = 3
      Value = 500
    end
  end
  object TimerPing: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerPingTimer
    Left = 480
    Top = 448
  end
end
