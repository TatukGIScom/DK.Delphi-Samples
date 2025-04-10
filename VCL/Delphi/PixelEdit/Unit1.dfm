object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Pixel Edit - TatukGIS DK11 Sample'
  ClientHeight = 465
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 169
    Top = 29
    Width = 466
    Height = 347
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
    TabOrder = 0
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    BorderStyle = bsNone
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 635
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 1
    object btnProfile: TButton
      Left = 0
      Top = 0
      Width = 120
      Height = 22
      Caption = 'Terrain profile'
      TabOrder = 0
      OnClick = btnProfileClick
    end
    object btnMinMax: TButton
      Left = 120
      Top = 0
      Width = 120
      Height = 22
      Caption = 'Grid Min/Max'
      TabOrder = 1
      OnClick = btnMinMaxClick
    end
    object btnAvargeColor: TButton
      Left = 240
      Top = 0
      Width = 120
      Height = 22
      Caption = 'Bitmap average color'
      TabOrder = 2
      OnClick = btnAvargeColorClick
    end
    object btnCreateBitmap: TButton
      Left = 360
      Top = 0
      Width = 120
      Height = 22
      Caption = 'Create new JPG'
      TabOrder = 3
      OnClick = btnCreateBitmapClick
    end
    object btnCreateGrid: TButton
      Left = 480
      Top = 0
      Width = 120
      Height = 22
      Caption = 'Create new GRD'
      TabOrder = 4
      OnClick = btnCreateGridClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 376
    Width = 635
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
    ExplicitTop = 382
  end
  object GIS_Legend: TGIS_ControlLegend
    Left = 0
    Top = 29
    Width = 169
    Height = 347
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    DialogOptions.VectorWizardUniqueLimit = 256
    DialogOptions.VectorWizardUniqueSearchLimit = 16384
    Align = alLeft
    ParentColor = False
    TabStop = True
    TabOrder = 3
  end
end
