object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Measure- TatukGIS DK11 Sample'
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
  DesignSize = (
    592
    516)
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
    Anchors = [akLeft, akTop, akRight, akBottom]
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
    EditorChangeEvent = GISEditorChangeEvent
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 497
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Use left mouse button to measure'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 25
    Caption = 'ToolBar1'
    TabOrder = 2
    object btnLine: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'By line'
      TabOrder = 2
      OnClick = btnLineClick
    end
    object btnPolygon: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 22
      Caption = 'By polygon'
      TabOrder = 1
      OnClick = btnPolygonClick
    end
    object btnClear: TButton
      Left = 150
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Clear'
      TabOrder = 0
      OnClick = btnClearClick
    end
  end
  object Panel1: TPanel
    Left = 407
    Top = 25
    Width = 185
    Height = 473
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 3
    object lblLength: TLabel
      Left = 7
      Top = 24
      Width = 36
      Height = 13
      Caption = 'Length:'
    end
    object lblArea: TLabel
      Left = 7
      Top = 70
      Width = 25
      Height = 13
      Caption = 'Area:'
    end
    object edtLength: TEdit
      Left = 7
      Top = 43
      Width = 170
      Height = 21
      TabOrder = 0
    end
    object edtArea: TEdit
      Left = 7
      Top = 89
      Width = 170
      Height = 21
      TabOrder = 1
    end
  end
end
