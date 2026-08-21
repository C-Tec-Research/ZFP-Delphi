inherited FormMovingImageButtomProperties: TFormMovingImageButtomProperties
  Left = 79
  Top = 194
  Caption = 'Moving Image Button Properties'
  ClientHeight = 530
  ClientWidth = 997
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited LabelTop: TLabel
    Left = 24
    Top = 32
  end
  inherited Label1: TLabel
    Left = 24
    Top = 64
  end
  inherited Label2: TLabel
    Left = 24
    Top = 96
  end
  inherited Label3: TLabel
    Left = 24
    Top = 128
  end
  inherited ButtonOK: TButton
    Left = 68
    Top = 289
  end
  inherited Button2: TButton
    Left = 68
    Top = 329
  end
  inherited Button3: TButton
    Left = 68
    Top = 369
  end
  inherited SpinEditTop: TSpinEdit
    Left = 96
    Top = 24
  end
  inherited SpinEditLeft: TSpinEdit
    Left = 96
    Top = 56
  end
  inherited SpinEditHeight: TSpinEdit
    Left = 96
    Top = 88
  end
  inherited SpinEditWidth: TSpinEdit
    Left = 96
    Top = 120
  end
  object TabControlImageTables: TTabControl
    Left = 184
    Top = 16
    Width = 794
    Height = 497
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 7
    DesignSize = (
      794
      497)
    object Label5: TLabel
      Left = 16
      Top = 56
      Width = 51
      Height = 13
      Caption = 'Image Top'
    end
    object Label6: TLabel
      Left = 16
      Top = 88
      Width = 50
      Height = 13
      Caption = 'Image Left'
    end
    object Label7: TLabel
      Left = 16
      Top = 120
      Width = 63
      Height = 13
      Caption = 'Image Height'
    end
    object Label8: TLabel
      Left = 16
      Top = 152
      Width = 60
      Height = 13
      Caption = 'Image Width'
    end
    object Label4: TLabel
      Left = 168
      Top = 32
      Width = 57
      Height = 13
      Caption = 'Max Images'
    end
    object SigNETStringGridImages: TSigNETStringGrid
      Left = 160
      Top = 48
      Width = 630
      Height = 445
      Anchors = [akLeft, akTop, akRight, akBottom]
      DefaultColWidth = 100
      DefaultRowHeight = 100
      TabOrder = 0
    end
    object SpinEditImageTop: TSpinEdit
      Left = 88
      Top = 48
      Width = 65
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object SpinEditImageLeft: TSpinEdit
      Left = 88
      Top = 80
      Width = 65
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
      OnChange = SpinEditTopChange
    end
    object SpinEditImageHeight: TSpinEdit
      Left = 88
      Top = 112
      Width = 65
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 100
      OnChange = SpinEditImageHeightChange
    end
    object SpinEditImageWidth: TSpinEdit
      Left = 88
      Top = 144
      Width = 65
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 100
      OnChange = SpinEditImageWidthChange
    end
    object SpinEditMaxImages: TSpinEdit
      Left = 240
      Top = 24
      Width = 65
      Height = 22
      MaxValue = 16
      MinValue = 1
      TabOrder = 5
      Value = 5
      OnChange = SpinEditMaxImagesChange
    end
  end
end
