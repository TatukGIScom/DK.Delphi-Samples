object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Geocoding & Routing - TatukGIS DK11 Sample'
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
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 0
    Width = 404
    Height = 473
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 100
  end
  object GIS_ControlScale1: TGIS_ControlScale
    Left = 8
    Top = 8
    Width = 241
    Height = 25
    GIS_Viewer = GIS
    Visible = True
    Transparent = True
    UnitsEPSG = 904201
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 404
    Top = 0
    Width = 188
    Height = 473
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object memRoute: TMemo
      Left = 0
      Top = 273
      Width = 188
      Height = 200
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 188
      Height = 273
      Align = alTop
      Caption = 'Routing parameters'
      TabOrder = 0
      object lblSmallRoads: TLabel
        Left = 24
        Top = 24
        Width = 82
        Height = 13
        Caption = 'Prefer &local roads'
        FocusControl = trkSmallRoads
      end
      object lblHighways: TLabel
        Left = 24
        Top = 72
        Width = 70
        Height = 13
        Caption = 'Prefer &highway'
        FocusControl = trkHighways
      end
      object lblAddrFrom: TLabel
        Left = 24
        Top = 120
        Width = 23
        Height = 13
        Caption = '&From'
        FocusControl = edtAddrFrom
      end
      object lblAddrTo: TLabel
        Left = 24
        Top = 176
        Width = 13
        Height = 13
        Caption = '&To'
        FocusControl = edtAddrTo
      end
      object trkSmallRoads: TTrackBar
        Left = 16
        Top = 40
        Width = 161
        Height = 25
        Min = 1
        Position = 1
        TabOrder = 0
      end
      object trkHighways: TTrackBar
        Left = 16
        Top = 88
        Width = 161
        Height = 25
        Min = 1
        Position = 5
        TabOrder = 1
      end
      object edtAddrFrom: TEdit
        Left = 24
        Top = 134
        Width = 145
        Height = 21
        Hint = '"Chrys"_, "Chrysoline", "Chry & Capri"'
        TabOrder = 2
        Text = 'Chrys 1345'
      end
      object btnResolve: TButton
        Left = 94
        Top = 160
        Width = 75
        Height = 23
        Caption = 'Find &Address'
        TabOrder = 3
        OnClick = btnResolveClick
      end
      object edtAddrTo: TEdit
        Left = 24
        Top = 190
        Width = 145
        Height = 21
        Hint = '"Wash", "Washington Dr" or "Wash & 8th"'
        TabOrder = 4
        Text = 'washi'
      end
      object btnRoute: TButton
        Left = 94
        Top = 214
        Width = 75
        Height = 23
        Caption = 'Find &Route'
        TabOrder = 5
        OnClick = btnRouteClick
      end
      object chkbxOnline: TCheckBox
        Left = 24
        Top = 243
        Width = 113
        Height = 17
        Caption = 'Use online services'
        TabOrder = 6
        OnClick = chkbxOnlineClick
      end
    end
  end
end
