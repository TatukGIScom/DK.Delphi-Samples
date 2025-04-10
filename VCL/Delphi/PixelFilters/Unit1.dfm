object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'PixelFilters - TatukGIS DK11 Sample'
  ClientHeight = 340
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    651
    340)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 25
    Height = 13
    Caption = 'Filter:'
  end
  object lblStructuring: TLabel
    Left = 8
    Top = 171
    Width = 100
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Structuring Elements:'
    Visible = False
  end
  object lblMaskSizeValue: TLabel
    Left = 143
    Top = 149
    Width = 17
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akBottom]
    Caption = '3x3'
    Visible = False
  end
  object lblMaskSize: TLabel
    Left = 8
    Top = 125
    Width = 49
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Mask Size'
    Visible = False
  end
  object lblMask: TLabel
    Left = 8
    Top = 125
    Width = 26
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Mask'
    Visible = False
  end
  object cbStructure: TComboBox
    Left = 8
    Top = 190
    Width = 183
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    TabOrder = 0
    Visible = False
    Items.Strings = (
      'Square'
      'Diamond'
      'Disk'
      'Horizontal Line'
      'Vertical Line'
      'Left Diagonal Line'
      'Right Diagonal Line')
  end
  object btnExecute: TButton
    Left = 8
    Top = 217
    Width = 81
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Execute'
    TabOrder = 1
    OnClick = btnExecuteClick
  end
  object GIS: TGIS_ViewerWnd
    Left = 197
    Top = 8
    Width = 445
    Height = 325
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
    TabOrder = 2
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    BorderStyle = bsNone
  end
  object cbMask: TComboBox
    Left = 8
    Top = 144
    Width = 183
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Visible = False
    Items.Strings = (
      'Low-Pass 3x3'
      'Low-Pass 5x5'
      'Low-Pass 7x7'
      'High-Pass 3x3'
      'High-Pass 5x5'
      'High-Pass 7x7'
      'Gaussian 3x3'
      'Gaussian 5x5'
      'Gaussian 7x7'
      'Laplacian 3x3'
      'Laplacian 5x5'
      'GradientNorth'
      'GradientEast'
      'GradientSouth'
      'GradientWest'
      'GradientNorthwest'
      'GradientNortheast'
      'GradientSouthwest'
      'GradientSoutheast'
      'PointDetector'
      'LineDetectorHorizontal'
      'LineDetectorVertical'
      'LineDetectorLeftDiagonal'
      'LineDetectorRightDiagonal')
  end
  object sbMaskSize: TScrollBar
    Left = 8
    Top = 144
    Width = 129
    Height = 17
    Anchors = [akLeft, akBottom]
    Max = 12
    Min = 1
    PageSize = 1
    Position = 1
    TabOrder = 4
    Visible = False
    OnChange = sbMaskSizeChange
  end
  object GIS_Legend: TGIS_ControlLegend
    Left = 8
    Top = 248
    Width = 183
    Height = 62
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    DialogOptions.VectorWizardUniqueLimit = 256
    DialogOptions.VectorWizardUniqueSearchLimit = 16384
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    CompactView = False
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object pbProgress: TProgressBar
    Left = 8
    Top = 316
    Width = 183
    Height = 17
    Anchors = [akLeft, akBottom]
    TabOrder = 6
  end
  object lbFilter: TListBox
    Left = 8
    Top = 22
    Width = 183
    Height = 97
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'Threshold'
      'Salt-And-Pepper Noise'
      'Gaussian Noise'
      'Convolution'
      'Sobel Magnitude'
      'Range'
      'Midpoint'
      'Minimum'
      'Maximum'
      'Arithmetic Mean'
      'Alpha-Trimmed Mean'
      'Contra-Harmonic Mean'
      'Geometric Mean'
      'Harmonic Mean'
      'Wieghted Mean'
      'Yp Mean'
      'Majority'
      'Minority'
      'Median'
      'Wieghted Median'
      'Sum'
      'Standard Deviation'
      'Unique Count'
      'Erosion'
      'Dilatation'
      'Opening'
      'Closing'
      'Top-Hat'
      'Bottom-Hat')
    TabOrder = 7
    OnClick = onFilterChange
  end
  object btnReset: TButton
    Left = 103
    Top = 217
    Width = 88
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Reset'
    TabOrder = 8
    OnClick = btnResetClick
  end
end
