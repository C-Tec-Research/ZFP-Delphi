object FormEditorsEditor: TFormEditorsEditor
  Left = 0
  Top = 0
  Caption = 'Editors'
  ClientHeight = 432
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 371
    Width = 643
    Height = 61
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 328
    object BitBtnOK: TBitBtn
      Left = 224
      Top = 16
      Width = 75
      Height = 25
      DoubleBuffered = True
      Kind = bkOK
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object BitBtnCancel: TBitBtn
      Left = 344
      Top = 16
      Width = 75
      Height = 25
      DoubleBuffered = True
      Kind = bkCancel
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 643
    Height = 78
    Align = alTop
    TabOrder = 0
    object Label3: TLabel
      Left = 67
      Top = 16
      Width = 72
      Height = 13
      Caption = 'Property Name'
    end
    object Label4: TLabel
      Left = 67
      Top = 41
      Width = 69
      Height = 13
      Caption = 'Fixed Columns'
    end
    object EditPropertyName: TEdit
      Left = 191
      Top = 11
      Width = 338
      Height = 21
      ReadOnly = True
      TabOrder = 0
      Text = 'EditPropertyName'
    end
    object EditFixedColumns: TEdit
      Left = 191
      Top = 38
      Width = 87
      Height = 21
      ReadOnly = True
      TabOrder = 1
      Text = 'EditFixedColumns'
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 78
    Width = 643
    Height = 293
    Align = alClient
    TabOrder = 1
    ExplicitTop = 41
    ExplicitHeight = 287
    object TabControlEditors: TTabControl
      Left = 1
      Top = 1
      Width = 641
      Height = 291
      Align = alClient
      TabOrder = 0
      OnChange = TabControlEditorsChange
      object Label1: TLabel
        Left = 80
        Top = 94
        Width = 55
        Height = 13
        Caption = 'Editor Style'
      end
      object Label2: TLabel
        Left = 80
        Top = 67
        Width = 79
        Height = 13
        Caption = 'Autosize Column'
      end
      object LabelItems: TLabel
        Left = 80
        Top = 120
        Width = 27
        Height = 13
        Caption = 'Items'
      end
      object LabelFixedCol: TLabel
        Left = 190
        Top = 42
        Width = 87
        Height = 16
        Caption = 'Fixed Column!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
      end
      object ComboBoxEditorStyle: TComboBox
        Left = 168
        Top = 91
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        ItemIndex = 0
        TabOrder = 0
        Text = 'esNone'
        OnChange = ComboBoxEditorStyleChange
        Items.Strings = (
          'esNone'
          'esMaskEdit'
          'esDropDown'
          'esDropDownList'
          'esImageList'
          'esSpinEdit')
      end
      object ComboBoxAutosizeColumn: TComboBox
        Left = 168
        Top = 64
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        ItemIndex = 0
        TabOrder = 1
        Text = 'Parent'
        OnChange = ComboBoxAutosizeColumnChange
        Items.Strings = (
          'Parent'
          'False'
          'True')
      end
      object MemoItems: TMemo
        Left = 176
        Top = 118
        Width = 145
        Height = 89
        Lines.Strings = (
          'MemoItems')
        TabOrder = 2
      end
      object ComboBoxImageList: TComboBox
        Left = 176
        Top = 117
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        ItemIndex = 0
        TabOrder = 3
        Text = '(none)'
        OnChange = ComboBoxEditorStyleChange
        Items.Strings = (
          '(none)')
      end
    end
  end
end
