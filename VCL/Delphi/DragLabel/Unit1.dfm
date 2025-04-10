object Form1: TForm1
  Left = 200
  Top = 120
  BiDiMode = bdLeftToRight
  Caption = 'DragLabel - TatukGIS DK11 Sample'
  ClientHeight = 473
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = HEBREW_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    ButtonHeight = 23
    Caption = 'ToolBar1'
    TabOrder = 1
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 23
      Caption = 'Animate'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 592
    Height = 425
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
    TabOrder = 2
    IncrementalPaint = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
  end
end
