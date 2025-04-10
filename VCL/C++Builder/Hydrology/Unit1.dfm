object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Hydrology Tutorial'
  ClientHeight = 729
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblInfo: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 12
    Width = 1002
    Height = 25
    Margins.Top = 12
    Margins.Bottom = 12
    Align = alTop
    Alignment = taCenter
    Caption = 
      'This sample application is a step-by-step tutorial on how to per' +
      'form common hydrological analyzes.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 934
  end
  object GIS: TGIS_ViewerWnd
    Left = 150
    Top = 49
    Width = 658
    Height = 663
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
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Color = clWhite
    BorderStyle = bsNone
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 49
    Width = 150
    Height = 663
    Align = alLeft
    TabOrder = 1
    object btnStreamOrderStrahler: TButton
      Left = 1
      Top = 176
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Stream Order (Strahler)'
      Enabled = False
      TabOrder = 0
      OnClick = btnStreamOrderStrahlerClick
    end
    object btnSink: TButton
      Left = 1
      Top = 1
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Identify DEM problems'
      TabOrder = 1
      OnClick = btnSinkClick
    end
    object btnFillSinks: TButton
      Left = 1
      Top = 26
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Fill sinks'
      Enabled = False
      TabOrder = 2
      OnClick = btnFillSinksClick
    end
    object btnFlowDirection: TButton
      Left = 1
      Top = 51
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Flow Direction'
      Enabled = False
      TabOrder = 3
      OnClick = btnFlowDirectionClick
    end
    object btnVectorize: TButton
      Left = 1
      Top = 201
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Convert to vector'
      Enabled = False
      TabOrder = 4
      OnClick = btnVectorizeClick
    end
    object btnFlowAccumulation: TButton
      Left = 1
      Top = 76
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Flow Accumulation'
      Enabled = False
      TabOrder = 5
      OnClick = btnFlowAccumulationClick
    end
    object btnWatershed: TButton
      Left = 1
      Top = 126
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Watershed'
      Enabled = False
      TabOrder = 6
      OnClick = btnWatershedClick
    end
    object btnBasin: TButton
      Left = 1
      Top = 151
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Basin'
      Enabled = False
      TabOrder = 7
      OnClick = btnBasinClick
    end
    object btnAddOutlets: TButton
      Left = 1
      Top = 101
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'Add outlets for Watershed'
      Enabled = False
      TabOrder = 8
      OnClick = btnAddOutletsClick
    end
    object btn3D: TButton
      Left = 1
      Top = 226
      Width = 148
      Height = 25
      Align = alTop
      Caption = 'View in 3D'
      Enabled = False
      TabOrder = 9
      OnClick = btn3DClick
    end
  end
  object GIS_Legend: TGIS_ControlLegend
    Left = 808
    Top = 49
    Width = 200
    Height = 663
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
    Align = alRight
    TabOrder = 2
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerVertical]
  end
  object pbBusy: TProgressBar
    Left = 0
    Top = 712
    Width = 1008
    Height = 17
    Align = alBottom
    TabOrder = 3
  end
end
