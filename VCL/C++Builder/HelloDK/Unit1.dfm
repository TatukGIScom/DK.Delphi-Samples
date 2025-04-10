object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'TatukGIS Samples - Hello DK'
  ClientHeight = 495
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 734
    Height = 33
    ButtonHeight = 33
    Caption = 'Open project'
    List = True
    TabOrder = 0
    object btnOpen: TSpeedButton
      Left = 0
      Top = 0
      Width = 100
      Height = 33
      Align = alLeft
      Caption = 'Open project'
      OnClick = btnOpenClick
    end
    object btnZoom: TSpeedButton
      Left = 100
      Top = 0
      Width = 100
      Height = 33
      Align = alLeft
      Caption = 'Zooming'
      OnClick = btnZoomClick
    end
    object btnDrag: TSpeedButton
      Left = 200
      Top = 0
      Width = 100
      Height = 33
      Caption = 'Dragging'
      OnClick = btnDragClick
    end
    object btnSelect: TSpeedButton
      Left = 300
      Top = 0
      Width = 100
      Height = 33
      Align = alLeft
      Caption = 'Selecting'
      OnClick = btnSelectClick
    end
    object btnCreateShape: TSpeedButton
      Left = 400
      Top = 0
      Width = 100
      Height = 33
      Caption = 'Create shape'
      OnClick = btnCreateShapeClick
    end
    object btnRelation: TSpeedButton
      Left = 500
      Top = 0
      Width = 231
      Height = 33
      Caption = 'Find shapes in relation with created shape'
      OnClick = btnRelationClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 33
    Width = 734
    Height = 462
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
    ProgressiveUpdate = 2500
    BorderStyle = bsNone
    TapSimpleEvent = GISTapSimpleEvent
  end
end
