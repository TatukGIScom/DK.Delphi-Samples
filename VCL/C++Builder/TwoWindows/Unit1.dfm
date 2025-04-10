object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Two Windows - TatukGIS DK11 Sample'
  ClientHeight = 463
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 249
    Top = 25
    Width = 8
    Height = 438
    ExplicitTop = 29
    ExplicitHeight = 444
  end
  object GIS_ViewerWnd1: TGIS_ViewerWnd
    Left = 0
    Top = 25
    Width = 249
    Height = 438
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
    Align = alLeft
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    Color = clWhite
    BorderStyle = bsNone
    VisibleExtentChangeEvent = GIS_ViewerWnd1VisibleExtentChangeEvent
  end
  object GIS_ViewerWnd2: TGIS_ViewerWnd
    Left = 257
    Top = 25
    Width = 327
    Height = 438
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
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    Color = clWhite
    BorderStyle = bsNone
    VisibleExtentChangeEvent = GIS_ViewerWnd2VisibleExtentChangeEvent
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 584
    Height = 25
    AutoSize = True
    ButtonHeight = 25
    Caption = 'ToolBar1'
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object Button1: TButton
      Left = 8
      Top = 0
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 0
      OnClick = Button1Click
    end
    object ToolButton2: TToolButton
      Left = 83
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object CheckBox1: TCheckBox
      Left = 91
      Top = 0
      Width = 97
      Height = 25
      Caption = 'Keep Zoom'
      TabOrder = 1
    end
  end
end
