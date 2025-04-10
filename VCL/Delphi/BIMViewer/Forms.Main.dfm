object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'BIM Viewer'
  ClientHeight = 523
  ClientWidth = 849
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 144
  TextHeight = 19
  object Splitter2: TSplitter
    Left = 325
    Top = 0
    Width = 12
    Height = 495
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 325
    Height = 495
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 1
      Top = 219
      Width = 323
      Height = 1
      Cursor = crVSplit
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
    end
    object tvSpatialModel: TTreeView
      Left = 1
      Top = 19
      Width = 323
      Height = 200
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
      Indent = 29
      ReadOnly = True
      TabOrder = 0
      OnClick = tvSpatialModelClick
      OnDblClick = tvSpatialModelDblClick
      OnMouseUp = tvSpatialModelMouseUp
    end
    object lvAttributes: TListView
      Left = 1
      Top = 220
      Width = 323
      Height = 274
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Name'
        end
        item
          AutoSize = True
          Caption = 'Value'
        end>
      FlatScrollBars = True
      GroupView = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
    end
    object HeaderControl1: THeaderControl
      Left = 1
      Top = 1
      Width = 323
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Sections = <
        item
          ImageIndex = -1
          MaxWidth = 7500
          Text = 'Type'
          Width = 100
        end
        item
          ImageIndex = -1
          MaxWidth = 7500
          Text = 'Name'
          Width = 117
        end>
      Style = hsFlat
    end
    object chkGroup: TCheckBox
      Left = 218
      Top = 1
      Width = 51
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Group'
      TabOrder = 3
      OnClick = chkGroupClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 495
    Width = 849
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Panels = <>
    SimplePanel = True
  end
  object GIS: TGIS_ViewerWnd
    Left = 337
    Top = 0
    Width = 442
    Height = 495
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
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
    KeepScale = True
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Color = clWhite
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
    OnMouseWheelUp = GISMouseWheelUp
    OnMouseWheelDown = GISMouseWheelDown
    BusyEvent = GISBusyEvent
  end
  object pnl3D: TPanel
    Left = 779
    Top = 0
    Width = 70
    Height = 495
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    Caption = 'pnl3D'
    TabOrder = 3
    Visible = False
    object GIS_Control3D1: TGIS_Control3D
      Left = 1
      Top = 1
      Width = 68
      Height = 493
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      AutoSize = False
      Mode = CameraPosition
      Options = [ShowNavigation, ShowCoordinates, ShowReferencePoint, ShowLights, ShowFrameModes, ShowScalings, ShowFloods, ShowWalls]
      GIS_Viewer = GIS
      ParentBiDiMode = False
      BiDiMode = bdLeftToRight
      Align = alClient
      BevelOuter = bvLowered
      Color = clBtnFace
      TabOrder = 0
    end
  end
  object MainMenu1: TMainMenu
    Left = 704
    Top = 208
    object File1: TMenuItem
      Caption = 'File'
      object actFileOpen: TMenuItem
        Caption = 'Open'
        OnClick = actFileOpenClick
      end
      object Opendefault1: TMenuItem
        Caption = 'Open default'
        OnClick = Opendefault1Click
      end
      object Close1: TMenuItem
        Caption = 'Exit'
        OnClick = Close1Click
      end
    end
    object Mode1: TMenuItem
      Caption = 'Mode'
      object Mode2: TMenuItem
        Caption = 'Select'
        OnClick = Mode2Click
      end
      object Zoom1: TMenuItem
        Caption = 'Zoom'
        OnClick = Zoom1Click
      end
      object Zoom2: TMenuItem
        Caption = 'Drag'
        OnClick = Zoom2Click
      end
      object Rotate1: TMenuItem
        Caption = 'Rotate'
        OnClick = Rotate1Click
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object N2D1: TMenuItem
        Caption = '2D'
        Checked = True
        RadioItem = True
        OnClick = N2D1Click
      end
      object N3D1: TMenuItem
        Caption = '3D'
        RadioItem = True
        OnClick = N3D1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Fullextent1: TMenuItem
        Caption = 'Full extent'
        OnClick = Fullextent1Click
      end
      object btnDemo: TMenuItem
        Caption = 'Demo'
        OnClick = btnDemoClick
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object Options2: TMenuItem
        Caption = 'Draw 2D'
        Checked = True
        OnClick = Options2Click
      end
      object N3DView1: TMenuItem
        Caption = '3D'
        object N3DView2: TMenuItem
          Caption = 'Show light'
          Checked = True
          OnClick = N3DView2Click
        end
        object Showbasemap1: TMenuItem
          Caption = 'Show basemap'
          OnClick = Showbasemap1Click
        end
        object Showbasemap2: TMenuItem
          Caption = 'Show wireframe'
          OnClick = Showbasemap2Click
        end
        object Showedges1: TMenuItem
          Caption = 'Show edges'
          OnClick = Showedges1Click
        end
        object advNav: TMenuItem
          Caption = 'Advanced navigation'
          OnClick = advNavClick
        end
        object refreshLock: TMenuItem
          Caption = 'Refresh lock'
          OnClick = refreshLockClick
        end
        object btnVectorSimplification: TMenuItem
          Caption = 'Vector Simplification'
          OnClick = btnVectorSimplificationClick
        end
      end
    end
    object est1: TMenuItem
      Caption = 'Tests'
      object ExporttoSHP1: TMenuItem
        Caption = 'Export to SHP'
        OnClick = ExporttoSHP1Click
      end
      object ExporttoSqlite1: TMenuItem
        Caption = 'Export to Sqlite'
        OnClick = ExporttoSqlite1Click
      end
    end
  end
  object OpenFileDialog: TOpenDialog
    Filter = 'wexBIM|*.wexBIM|IFC|*.ifc|All files|*.shp;*.ttkls;*.ttkwp'
    InitialDir = 'E:\Data\IFC'
    Left = 896
    Top = 176
  end
  object tmrDemo: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrDemoTimer
    Left = 708
    Top = 108
  end
end
