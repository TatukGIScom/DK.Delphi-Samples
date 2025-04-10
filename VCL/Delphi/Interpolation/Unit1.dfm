object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Interpolation - TatukGIS DK11 Sample'
  ClientHeight = 401
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    577
    401)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMethod: TLabel
    Left = 8
    Top = 8
    Width = 36
    Height = 13
    Caption = 'Method'
  end
  object lblSemivariance: TLabel
    Left = 8
    Top = 152
    Width = 63
    Height = 13
    Caption = 'Semivariance'
    Visible = False
  end
  object GIS: TGIS_ViewerWnd
    Left = 135
    Top = 8
    Width = 434
    Height = 353
    Cursor = 18
    CursorForDrag = crDefault
    CursorForEdit = crDefault
    CursorForSelect = crDefault
    CursorForUserDefined = crDefault
    CursorForZoom = crDefault
    CursorForZoomEx = crDefault
    CursorForCameraPosition = crDefault
    CursorForCameraRotation = crDefault
    CursorForCameraXYZ = crDefault
    CursorForCameraXY = crDefault
    CursorForCameraZoom = crDefault
    CursorForSunPosition = crDefault
    CursorFor3DSelect = crDefault
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    BorderStyle = bsNone
  end
  object rbtnIDW: TRadioButton
    Left = 8
    Top = 27
    Width = 113
    Height = 17
    Caption = 'IDW Interpolation'
    Checked = True
    TabOrder = 1
    TabStop = True
  end
  object rbtnKriging: TRadioButton
    Left = 8
    Top = 50
    Width = 113
    Height = 17
    Caption = 'Kriging Interpolation'
    TabOrder = 2
  end
  object rbtnSplines: TRadioButton
    Left = 8
    Top = 73
    Width = 113
    Height = 17
    Caption = 'Splines Interpolation'
    TabOrder = 3
  end
  object rbtnHeatMap: TRadioButton
    Left = 8
    Top = 96
    Width = 113
    Height = 17
    Caption = 'Heat Map'
    TabOrder = 4
  end
  object btnGenerateGrid: TButton
    Left = 8
    Top = 367
    Width = 121
    Height = 27
    Anchors = [akLeft, akBottom]
    Caption = 'Generate'
    TabOrder = 5
    OnClick = btnGenerateGridClick
  end
  object pbProgress: TProgressBar
    Left = 135
    Top = 368
    Width = 434
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 6
  end
  object rbtnConcentrationMap: TRadioButton
    Left = 8
    Top = 119
    Width = 113
    Height = 17
    Caption = 'Concentration Map'
    TabOrder = 8
  end
  object cmbSemivariance: TComboBox
    Left = 10
    Top = 171
    Width = 119
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 7
    Text = 'Power Law'
    Visible = False
    Items.Strings = (
      'Power Law'
      'Exponential'
      'Gaussian'
      'Spherical'
      'Circular'
      'Linear')
  end
end
