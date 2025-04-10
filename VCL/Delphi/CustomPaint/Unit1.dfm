object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'CustomPaint - TatukGIS DK11 Sample'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    800
    600)
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 8
    Top = 39
    Width = 784
    Height = 553
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
    Color = clWhite
    BorderStyle = bsNone
    PaintExtraEvent = GISPaintExtraEvent
  end
  object cbRenderer: TComboBox
    Left = 8
    Top = 10
    Width = 177
    Height = 21
    Style = csDropDownList
    TabOrder = 1
    OnChange = cbRendererChange
  end
end
