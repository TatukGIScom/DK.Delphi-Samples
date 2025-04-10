object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'InMamory - TatukGIS DK11 Sample'
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
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 1
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Create Layer'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Add Points'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 150
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Add Lines'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 225
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Animate'
      TabOrder = 3
      OnClick = Button4Click
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
    KeepScale = False
    IncrementalPaint = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
end
