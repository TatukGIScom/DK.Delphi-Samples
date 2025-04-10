object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 444
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    585
    444)
  PixelsPerInch = 96
  TextHeight = 13
  object btnLine: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'By line'
    TabOrder = 0
    OnClick = btnLineClick
  end
  object btnPolygon: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'By polygon'
    TabOrder = 1
    OnClick = btnPolygonClick
  end
  object btnClear: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = btnClearClick
  end
  object Panel1: TPanel
    Left = 400
    Top = 39
    Width = 185
    Height = 386
    Anchors = [akTop, akRight, akBottom]
    TabOrder = 3
    object lblLength: TLabel
      Left = 7
      Top = 16
      Width = 33
      Height = 13
      Caption = 'Length'
    end
    object lblArea: TLabel
      Left = 7
      Top = 62
      Width = 23
      Height = 13
      Caption = 'Area'
    end
    object edtLength: TEdit
      Left = 7
      Top = 35
      Width = 170
      Height = 21
      TabOrder = 0
    end
    object edtArea: TEdit
      Left = 7
      Top = 81
      Width = 170
      Height = 21
      TabOrder = 1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 425
    Width = 585
    Height = 19
    Panels = <
      item
        Text = 'Use left mouse button to measure'
        Width = 50
      end>
    ExplicitLeft = 144
    ExplicitTop = 416
    ExplicitWidth = 0
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 39
    Width = 401
    Height = 386
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
    TabOrder = 5
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    EditorChangeEvent = GISEditorChangeEvent
  end
end
