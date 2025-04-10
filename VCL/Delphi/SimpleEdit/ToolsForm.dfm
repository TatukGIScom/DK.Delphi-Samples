object frmEditorTools: TfrmEditorTools
  Left = 262
  Top = 231
  BorderStyle = bsToolWindow
  Caption = 'Editor Tools'
  ClientHeight = 221
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  OnCreate = FormCreate
  DesignSize = (
    234
    221)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 6
    Width = 60
    Height = 13
    Caption = 'Select tool'
  end
  object lblStep: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 205
    Width = 228
    Height = 13
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 4
  end
  object pnlLockedParams: TGroupBox
    Left = 8
    Top = 59
    Width = 217
    Height = 91
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'Locked parameters'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 20
      Width = 49
      Height = 13
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Distance'
    end
    object Label2: TLabel
      Left = 115
      Top = 20
      Width = 32
      Height = 13
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      Caption = 'Angle'
    end
    object edtAngle: TEdit
      Left = 115
      Top = 37
      Width = 89
      Height = 21
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      TabOrder = 1
      OnChange = edtAngleChange
    end
    object edtDistance: TEdit
      Left = 16
      Top = 37
      Width = 89
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 0
      OnChange = edtDistanceChange
    end
    object cbRelativeAngle: TCheckBox
      Left = 120
      Top = 64
      Width = 81
      Height = 17
      Caption = 'Relative'
      TabOrder = 2
      OnClick = cbRelativeAngleClick
    end
  end
  object cbEditingTool: TComboBox
    Left = 8
    Top = 25
    Width = 218
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'Default editing'
    OnChange = cbEditingToolChange
    Items.Strings = (
      'Default editing'
      'Line'
      'Rectangle'
      'Rectangle 90'
      'Circle'
      'Circle 3P'
      'Arc'
      'Ellipse')
  end
  object cbTracing: TCheckBox
    Left = 7
    Top = 156
    Width = 128
    Height = 22
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabStop = False
    Caption = 'Snap Tracing'
    TabOrder = 2
    OnClick = cbTracingClick
  end
  object cbPolarTracking: TCheckBox
    Left = 24
    Top = 182
    Width = 111
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabStop = False
    Caption = 'Polar Tracking'
    TabOrder = 3
    OnClick = cbPolarTrackingClick
  end
  object sePolarIncAngle: TSpinEdit
    Left = 139
    Top = 177
    Width = 55
    Height = 22
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabStop = False
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 90
  end
end
