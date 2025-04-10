object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Select by shape - TatukGIS DK11 Sample'
  ClientHeight = 516
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
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 25
    Width = 408
    Height = 473
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
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 50
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
    PaintExtraEvent = GISPaintExtraEvent
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 497
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Use left mouse button to select'
  end
  object Memo1: TMemo
    Left = 408
    Top = 25
    Width = 184
    Height = 472
    Align = alRight
    ReadOnly = True
    TabOrder = 2
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 25
    Caption = 'ToolBar1'
    TabOrder = 3
    object btnRect: TSpeedButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'By rectangle'
    end
    object btnCircle: TSpeedButton
      Left = 75
      Top = 0
      Width = 56
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'By circle'
    end
  end
end
