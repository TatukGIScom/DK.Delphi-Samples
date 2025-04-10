object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Snap - TatukGIS DK11 Sample'
  ClientHeight = 473
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 592
    Height = 444
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
    TabOrder = 0
    KeepScale = False
    IncrementalPaint = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    ButtonHeight = 25
    Caption = 'ToolBar1'
    TabOrder = 1
    object btnWithoutSnapping: TButton
      Left = 0
      Top = 0
      Width = 129
      Height = 25
      Caption = 'Start w/o snapping'
      TabOrder = 0
      OnClick = btnWithoutSnappingClick
    end
    object btnWithSnapping: TButton
      Left = 129
      Top = 0
      Width = 144
      Height = 25
      Caption = 'Start (with snapping)'
      TabOrder = 1
      OnClick = btnWithSnappingClick
    end
  end
  object tmrWithSnapping: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrWithSnappingTimer
    Left = 128
    Top = 32
  end
  object tmrWithoutSnapping: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrWithoutSnappingTimer
    Top = 32
  end
end
