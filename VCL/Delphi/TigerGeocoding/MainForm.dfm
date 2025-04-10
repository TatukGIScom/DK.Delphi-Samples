object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Tiger geocoding - TatukGIS DK11 Sample'
  ClientHeight = 489
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 351
    Height = 460
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
    BorderStyle = bsNone
  end
  object GIS_ControlScale1: TGIS_ControlScale
    Left = 8
    Top = 35
    Width = 225
    Height = 25
    GIS_Viewer = GIS
    Visible = False
    UnitsEPSG = 904202
    Color = clBtnFace
    TabOrder = 2
  end
  object Panel2: TPanel
    Left = 351
    Top = 29
    Width = 241
    Height = 460
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
    TabStop = True
    object sgrdMemo: TStringGrid
      Left = 0
      Top = 129
      Width = 241
      Height = 331
      Hint = 'Double click to display info'
      Align = alClient
      ColCount = 1
      DefaultColWidth = 240
      DefaultRowHeight = 15
      FixedCols = 0
      RowCount = 21
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -7
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine]
      ParentFont = False
      ParentShowHint = False
      ScrollBars = ssVertical
      ShowHint = False
      TabOrder = 1
      OnClick = sgrdMemoClick
      OnContextPopup = sgrdMemoContextPopup
      OnDblClick = sgrdMemoDblClick
      OnSelectCell = sgrdMemoSelectCell
    end
    object gbxFind: TGroupBox
      Left = 0
      Top = 0
      Width = 241
      Height = 129
      Align = alTop
      Caption = 'Find Address(es):'
      TabOrder = 0
      object edtAddress: TEdit
        Left = 20
        Top = 30
        Width = 205
        Height = 21
        Hint = 'See Help'
        TabOrder = 0
      end
      object btnFindFirst: TButton
        Left = 19
        Top = 89
        Width = 63
        Height = 23
        Caption = '&Find First'
        TabOrder = 1
        OnClick = btnFindFirstClick
      end
      object btnFindAll: TButton
        Left = 88
        Top = 89
        Width = 63
        Height = 23
        Caption = 'Find &All'
        TabOrder = 2
        OnClick = btnFindAllClick
      end
      object btnHelp: TButton
        Left = 183
        Top = 58
        Width = 41
        Height = 23
        Caption = '&Help'
        TabOrder = 3
        OnClick = btnHelpClick
      end
      object chkExtended: TCheckBox
        Left = 24
        Top = 58
        Width = 156
        Height = 17
        Hint = 'See Help'
        Caption = '&Exact street- and city names'
        TabOrder = 4
      end
      object btnMatches: TButton
        Left = 168
        Top = 89
        Width = 57
        Height = 23
        Caption = 'Matches'
        Enabled = False
        TabOrder = 5
        OnClick = btnMatchesClick
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    ButtonHeight = 23
    ButtonWidth = 89
    Caption = 'ToolBar1'
    TabOrder = 0
    DesignSize = (
      592
      29)
    object btnOpenDefault: TButton
      Left = 0
      Top = 0
      Width = 89
      Height = 23
      Caption = 'Open Default'
      TabOrder = 2
      OnClick = btnOpenDefaultClick
    end
    object btnOpen: TButton
      Left = 89
      Top = 0
      Width = 88
      Height = 23
      Hint = 'Open TIGER file'
      Caption = '&Open'
      TabOrder = 0
      OnClick = btnOpenClick
    end
    object ProgressBar1: TProgressBar
      Left = 177
      Top = 0
      Width = 297
      Height = 23
      Anchors = [akTop]
      Smooth = True
      TabOrder = 1
      Visible = False
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'TIGER files (*.RT1)|*.RT1'#39';'
    Left = 186
    Top = 2
  end
  object PopupMenu1: TPopupMenu
    Left = 358
    Top = 165
    object mnuCopy: TMenuItem
      Caption = 'Copy'
      OnClick = mnuCopyClick
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 390
    Top = 167
    object mnuCopyvalue: TMenuItem
      Caption = 'Copy value'
      OnClick = mnuCopyvalueClick
    end
  end
end
