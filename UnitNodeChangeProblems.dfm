object FormNodeChangeProblems: TFormNodeChangeProblems
  Left = 0
  Top = 0
  Caption = 'Node Change Problems'
  ClientHeight = 359
  ClientWidth = 587
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 289
    Width = 587
    Height = 70
    Align = alBottom
    BevelOuter = bvLowered
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      587
      70)
    object BitBtnProceedAnyway: TBitBtn
      Left = 128
      Top = 32
      Width = 131
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Proceed Anyway'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 272
      Top = 32
      Width = 131
      Height = 25
      Anchors = [akLeft, akBottom]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
    object CheckBoxIgnoreSimilarProblems: TCheckBox
      Left = 128
      Top = 8
      Width = 185
      Height = 17
      Caption = 'Ignore Similar Problems'
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 587
    Height = 289
    Align = alClient
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      587
      289)
    object Label4: TLabel
      Left = 24
      Top = 18
      Width = 233
      Height = 13
      Caption = 'Warning - you are trying to change a Node Type'
    end
    object Label1: TLabel
      Left = 24
      Top = 48
      Width = 39
      Height = 13
      Caption = 'Address'
    end
    object Label2: TLabel
      Left = 160
      Top = 48
      Width = 64
      Height = 13
      Caption = 'Current Type'
    end
    object ImageNodeCurrentIcon: TImage
      Left = 424
      Top = 39
      Width = 32
      Height = 32
    end
    object Image1: TImage
      Left = 424
      Top = 83
      Width = 32
      Height = 32
    end
    object Label3: TLabel
      Left = 160
      Top = 92
      Width = 48
      Height = 13
      Caption = 'New Type'
    end
    object LabelFollowingProblemsDetected: TLabel
      Left = 24
      Top = 120
      Width = 199
      Height = 13
      Caption = 'but the following problems were detected'
    end
    object LabelFollowingProblemDetected: TLabel
      Left = 24
      Top = 133
      Width = 189
      Height = 13
      Caption = 'but the following problem was detected'
    end
    object EditAddress: TEdit
      Left = 88
      Top = 45
      Width = 49
      Height = 21
      TabStop = False
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
      Text = 'EditAddress'
    end
    object EditCurrentType: TEdit
      Left = 256
      Top = 45
      Width = 121
      Height = 21
      TabStop = False
      ParentColor = True
      ReadOnly = True
      TabOrder = 1
      Text = 'EditCurrentType'
    end
    object EditNewType: TEdit
      Left = 256
      Top = 89
      Width = 121
      Height = 21
      TabStop = False
      ParentColor = True
      ReadOnly = True
      TabOrder = 2
      Text = 'EditNewType'
    end
    object MemoProblemsDetected: TMemo
      Left = 22
      Top = 152
      Width = 537
      Height = 113
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Lines.Strings = (
        'MemoProblemsDetected')
      ParentColor = True
      ReadOnly = True
      TabOrder = 3
    end
  end
end
