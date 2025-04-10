object Form1: TForm1
  Left = 501
  Top = 273
  Caption = 'Fields - TatukGIS DK11 Sample'
  ClientHeight = 615
  ClientWidth = 797
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 476
    Width = 797
    Height = 120
    Align = alBottom
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object GIS: TGIS_ViewerWnd
    Left = 129
    Top = 29
    Width = 668
    Height = 447
    Cursor = 16
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
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    AutoStyle = False
    KeepScale = False
    IncrementalPaint = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
  object GIS_ControlLegend: TGIS_ControlLegend
    Left = 0
    Top = 29
    Width = 129
    Height = 447
    GIS_Viewer = GIS
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    SelectionColor = 16771276
    SelectionFontColor = clBlack
    ParentBiDiMode = False
    BiDiMode = bdLeftToRight
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabStop = True
    TabOrder = 2
    Touch.InteractiveGestures = []
    Touch.InteractiveGestureOptions = []
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 596
    Width = 797
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Open a layer properties form to change parameters'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 797
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 4
    object CreateLayerButton: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Create Layer'
      TabOrder = 0
      OnClick = CreateLayerButtonClick
    end
    object ToolButton1: TToolButton
      Left = 75
      Top = 0
      Width = 94
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
  end
  object chkUseSymbols: TCheckBox
    Left = 81
    Top = 0
    Width = 80
    Height = 22
    Caption = 'Use symbols'
    TabOrder = 5
  end
  object GIS_DataSet1: TGIS_DataSet
    AfterPost = GIS_DataSet1AfterPost
    Left = 208
    Top = 80
  end
  object DataSource1: TDataSource
    DataSet = GIS_DataSet1
    Left = 272
    Top = 80
  end
end
