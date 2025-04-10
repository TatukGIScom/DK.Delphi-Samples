object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'RasterAlgebra - TatukGIS DK11 Sample'
  ClientHeight = 441
  ClientWidth = 625
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    625
    441)
  PixelsPerInch = 96
  TextHeight = 13
  object lblFormula: TLabel
    Left = 8
    Top = 61
    Width = 41
    Height = 13
    Caption = 'Result ='
  end
  object lblResultType: TLabel
    Left = 8
    Top = 39
    Width = 59
    Height = 13
    Caption = 'Result type:'
  end
  object lblSource: TLabel
    Left = 8
    Top = 13
    Width = 75
    Height = 13
    Caption = 'Choose source:'
  end
  object GIS: TGIS_ViewerWnd
    Left = 8
    Top = 108
    Width = 489
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
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    BorderStyle = bsNone
  end
  object edtFormula: TEdit
    Left = 89
    Top = 58
    Width = 447
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object btnExecute: TButton
    Left = 542
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Execute'
    TabOrder = 2
    OnClick = btnExecuteClick
  end
  object pbrProgress: TProgressBar
    Left = 8
    Top = 85
    Width = 609
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object rbtnResultPixel: TRadioButton
    Left = 89
    Top = 39
    Width = 40
    Height = 17
    Caption = 'Pixel'
    Checked = True
    TabOrder = 4
    TabStop = True
  end
  object rbtnResultGrid: TRadioButton
    Left = 135
    Top = 39
    Width = 41
    Height = 17
    Caption = 'Grid'
    TabOrder = 5
  end
  object GIS_Legend: TGIS_ControlLegend
    Left = 503
    Top = 108
    Width = 114
    Height = 325
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
    Anchors = [akTop, akRight, akBottom]
    Color = clBtnFace
    ParentColor = False
    TabStop = True
    TabOrder = 6
  end
  object btnOpenGrid: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open grid'
    TabOrder = 7
    OnClick = btnOpenGridClick
  end
  object btnOpenPixel: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open pixel'
    TabOrder = 8
    OnClick = btnOpenPixelClick
  end
  object btnOpenVector: TButton
    Left = 251
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open vector'
    TabOrder = 9
    OnClick = btnOpenVectorClick
  end
end
