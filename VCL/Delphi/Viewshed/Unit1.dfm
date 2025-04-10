object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Viewshed - TatukGIS DK11 Sample'
  ClientHeight = 496
  ClientWidth = 713
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    713
    496)
  PixelsPerInch = 96
  TextHeight = 13
  object lblObserverElevation: TLabel
    Left = 8
    Top = 255
    Width = 136
    Height = 13
    Caption = 'Observer Elevation (meters)'
  end
  object lblHint: TLabel
    Left = 159
    Top = 8
    Width = 546
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Click on the map to add an observer.'
  end
  object GIS: TGIS_ViewerWnd
    Left = 160
    Top = 27
    Width = 545
    Height = 444
    Cursor = 20
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
    Mode = UserDefined
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    BeforePaintRendererEvent = GISBeforePaintRendererEvent
    AfterPaintRendererEvent = GISAfterPaintRendererEvent
  end
  object gbMapMode: TGroupBox
    Left = 8
    Top = 71
    Width = 145
    Height = 73
    Caption = 'Map Mode'
    TabOrder = 1
    object rbtnZoom: TRadioButton
      Left = 11
      Top = 19
      Width = 126
      Height = 17
      Caption = 'Zoom'
      TabOrder = 0
      OnClick = rbtnZoomClick
    end
    object rbtnAddObserver: TRadioButton
      Left = 11
      Top = 42
      Width = 126
      Height = 17
      Caption = 'Add Observer'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbtnAddObserverClick
    end
  end
  object btnFullExtent: TButton
    Left = 8
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Full Extent'
    TabOrder = 2
    OnClick = btnFullExtentClick
  end
  object btnReset: TButton
    Left = 8
    Top = 39
    Width = 145
    Height = 25
    Caption = 'Reset'
    TabOrder = 3
    OnClick = btnResetClick
  end
  object gbVisibleLayer: TGroupBox
    Left = 8
    Top = 150
    Width = 146
    Height = 99
    Caption = 'Visible Layer'
    TabOrder = 4
    object rbtnViewshedBinary: TRadioButton
      Left = 11
      Top = 24
      Width = 125
      Height = 17
      Caption = 'Viewshed (binary)'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbtnViewshedBinaryClick
    end
    object rbtnAGL: TRadioButton
      Left = 11
      Top = 70
      Width = 125
      Height = 17
      Caption = 'Above-Ground-Level'
      TabOrder = 1
      OnClick = rbtnAGLClick
    end
    object rbtnViewshedFreq: TRadioButton
      Left = 11
      Top = 47
      Width = 126
      Height = 17
      Caption = 'Viewshed (frequency)'
      TabOrder = 2
      OnClick = rbtnViewshedFreqClick
    end
  end
  object edtObserverElevation: TEdit
    Left = 8
    Top = 274
    Width = 146
    Height = 21
    TabOrder = 5
    Text = '30'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 477
    Width = 713
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object Button1: TButton
    Left = 40
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 7
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer2Timer
    Left = 352
    Top = 256
  end
end
