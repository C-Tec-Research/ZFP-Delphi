inherited FormAreaButtonProps: TFormAreaButtonProps
  Caption = 'Area Button Properties'
  ClientHeight = 266
  ClientWidth = 396
  PixelsPerInch = 96
  TextHeight = 13
  inherited LabelTop: TLabel
    Left = 56
  end
  inherited Label1: TLabel
    Left = 56
  end
  inherited Label2: TLabel
    Left = 56
  end
  inherited Label3: TLabel
    Left = 56
  end
  inherited Label4: TLabel
    Left = 56
  end
  object Label5: TLabel [5]
    Left = 56
    Top = 184
    Width = 75
    Height = 13
    Caption = 'Area to activate'
  end
  inherited ButtonOK: TButton
    Top = 225
  end
  inherited Button2: TButton
    Top = 225
  end
  inherited Button3: TButton
    Top = 225
  end
  object ComboBoxArea: TComboBox
    Left = 144
    Top = 184
    Width = 217
    Height = 21
    ItemHeight = 13
    TabOrder = 8
    Text = 'ComboBoxArea'
    OnChange = ComboBoxAreaChange
  end
end
