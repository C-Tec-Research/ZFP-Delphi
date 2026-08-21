inherited FormTextButtonProps: TFormTextButtonProps
  Caption = 'Text Button Properties'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited LabelTop: TLabel
    Top = 64
  end
  inherited Label1: TLabel
    Top = 96
  end
  inherited Label2: TLabel
    Top = 128
  end
  inherited Label3: TLabel
    Top = 160
  end
  object Label4: TLabel [4]
    Left = 88
    Top = 24
    Width = 21
    Height = 13
    Caption = 'Text'
  end
  inherited ButtonOK: TButton
    TabOrder = 5
  end
  inherited Button2: TButton
    TabOrder = 6
  end
  inherited Button3: TButton
    TabOrder = 7
  end
  inherited SpinEditTop: TSpinEdit
    Top = 56
    TabOrder = 1
  end
  inherited SpinEditLeft: TSpinEdit
    Top = 88
    TabOrder = 2
  end
  inherited SpinEditHeight: TSpinEdit
    Top = 120
    TabOrder = 3
  end
  inherited SpinEditWidth: TSpinEdit
    Top = 152
    TabOrder = 4
  end
  object EditText: TEdit
    Left = 144
    Top = 24
    Width = 217
    Height = 21
    TabOrder = 0
    Text = 'EditText'
    OnChange = EditTextChange
  end
end
