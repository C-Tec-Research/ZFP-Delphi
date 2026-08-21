object FormCalendarSelect: TFormCalendarSelect
  Left = 0
  Top = 0
  Caption = 'Calendar'
  ClientHeight = 224
  ClientWidth = 232
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object CalendarMain: TCalendar
    Left = 24
    Top = 44
    Width = 185
    Height = 137
    StartOfWeek = 0
    TabOrder = 0
    OnChange = CalendarMainChange
  end
  object ComboBoxMonth: TComboBox
    Left = 24
    Top = 16
    Width = 99
    Height = 21
    Style = csDropDownList
    ItemHeight = 0
    ItemIndex = 11
    TabOrder = 1
    Text = 'December'
    OnChange = ComboBoxMonthChange
    Items.Strings = (
      'January'
      'February'
      'March'
      'April'
      'May'
      'June'
      'July'
      'August'
      'September'
      'October'
      'Novemer'
      'December')
  end
  object SigSpinEditYear: TSigSpinEdit
    Left = 160
    Top = 16
    Width = 49
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 2010
    OnChange = SigSpinEditYearChange
  end
  object BitBtnOK: TBitBtn
    Left = 32
    Top = 187
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkOK
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object BitBtnCancel: TBitBtn
    Left = 128
    Top = 187
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 4
  end
end
