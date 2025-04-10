object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Online Services'
  ClientHeight = 640
  ClientWidth = 1113
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    1113
    640)
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 256
    Top = 0
    Width = 640
    Height = 640
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
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    Color = clWhite
    BorderStyle = bsNone
  end
  object GIS_Scale: TGIS_ControlScale
    Left = 742
    Top = 600
    Width = 154
    Height = 32
    GIS_Viewer = GIS
    Visible = True
    UnitsEPSG = 0
    Anchors = [akRight, akBottom]
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    TabOrder = 1
  end
  object grpbxGeocoding: TGroupBox
    Left = 8
    Top = 71
    Width = 242
    Height = 89
    Caption = 'Geocoding'
    TabOrder = 2
    object lblGeocodingLimit: TLabel
      Left = 11
      Top = 57
      Width = 21
      Height = 13
      Caption = 'Limit'
    end
    object lblGeocodingAddress: TLabel
      Left = 11
      Top = 27
      Width = 39
      Height = 13
      Caption = 'Address'
    end
    object edtGeocodingAddress: TEdit
      Left = 56
      Top = 24
      Width = 177
      Height = 21
      TabOrder = 0
      Text = 'Gdynia, Plac Kaszubski 8'
    end
    object btnGeocoding: TButton
      Left = 158
      Top = 51
      Width = 75
      Height = 25
      Caption = 'Find'
      TabOrder = 1
      OnClick = btnGeocodingClick
    end
    object cmbbxGeocodingLimit: TComboBox
      Left = 38
      Top = 53
      Width = 35
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = '5'
      Items.Strings = (
        '1'
        '5'
        '10')
    end
  end
  object grpbxRouting: TGroupBox
    Left = 8
    Top = 166
    Width = 242
    Height = 296
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Routing'
    TabOrder = 3
    DesignSize = (
      242
      296)
    object lblRoutingProfile: TLabel
      Left = 11
      Top = 24
      Width = 34
      Height = 13
      Caption = 'Profile:'
    end
    object btnRouting: TButton
      Left = 158
      Top = 258
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Find'
      TabOrder = 0
      OnClick = btnRoutingClick
      ExplicitTop = 261
    end
    object strgrdRouting: TStringGrid
      Left = 11
      Top = 46
      Width = 222
      Height = 206
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 2
      RowCount = 3
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing, goEditing]
      ScrollBars = ssNone
      TabOrder = 1
      ExplicitHeight = 209
      ColWidths = (
        64
        64)
      RowHeights = (
        24
        24
        24)
    end
    object btnRoutingAdd: TButton
      Left = 11
      Top = 258
      Width = 25
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '+'
      TabOrder = 2
      OnClick = btnRoutingAddClick
      ExplicitTop = 261
    end
    object btnRoutingDelete: TButton
      Left = 42
      Top = 258
      Width = 25
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '-'
      TabOrder = 3
      OnClick = btnRoutingDeleteClick
      ExplicitTop = 261
    end
    object rbtnRoutingProfileCar: TRadioButton
      Left = 56
      Top = 23
      Width = 41
      Height = 17
      Caption = 'Car'
      Checked = True
      TabOrder = 4
      TabStop = True
    end
    object rbtnRoutingProfileBike: TRadioButton
      Left = 103
      Top = 23
      Width = 42
      Height = 17
      Caption = 'Bike'
      TabOrder = 5
    end
    object rbtnRoutingProfileFoot: TRadioButton
      Left = 151
      Top = 23
      Width = 50
      Height = 17
      Caption = 'Foot'
      TabOrder = 6
    end
  end
  object grpbxMap: TGroupBox
    Left = 8
    Top = 8
    Width = 242
    Height = 57
    Caption = 'Map style'
    TabOrder = 4
    object cmbbxMap: TComboBox
      Left = 11
      Top = 22
      Width = 222
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 0
      Text = 'English'
      OnChange = cmbbxMapChange
      Items.Strings = (
        'International'
        'English'
        'International with hillshade'
        'English with hillshade')
    end
  end
  object grpbxRoutingDir: TGroupBox
    Left = 902
    Top = 8
    Width = 203
    Height = 624
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Routing directions'
    TabOrder = 5
    DesignSize = (
      203
      624)
    object lblRoutingDirDist: TLabel
      Left = 16
      Top = 22
      Width = 79
      Height = 13
      Caption = 'Total distance: ?'
    end
    object lblRoutingDirTime: TLabel
      Left = 16
      Top = 41
      Width = 59
      Height = 13
      Caption = 'Total time: ?'
    end
    object lblRoutingDirInfo: TLabel
      Left = 16
      Top = 61
      Width = 101
      Height = 13
      Caption = 'Double-click to zoom:'
    end
    object strgrdRoutingDir: TStringGrid
      Left = 12
      Top = 80
      Width = 180
      Height = 531
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 1
      DefaultColWidth = 384
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      TabOrder = 0
      OnDblClick = strgrdRoutingDirDblClick
      ColWidths = (
        384)
      RowHeights = (
        24)
    end
  end
  object grpbxIsochrone: TGroupBox
    Left = 8
    Top = 468
    Width = 242
    Height = 164
    Anchors = [akLeft, akBottom]
    Caption = 'Isochrone'
    TabOrder = 6
    object lblIsochroneTime: TLabel
      Left = 11
      Top = 49
      Width = 93
      Height = 13
      Caption = 'Time limit (seconds)'
    end
    object lblIsochroneBuckets: TLabel
      Left = 11
      Top = 76
      Width = 90
      Height = 13
      Caption = 'Number of buckets'
    end
    object lblIsochroneAddress: TLabel
      Left = 11
      Top = 103
      Width = 39
      Height = 13
      Caption = 'Address'
    end
    object lblIsochroneProfile: TLabel
      Left = 11
      Top = 24
      Width = 34
      Height = 13
      Caption = 'Profile:'
    end
    object btnIsochrone: TButton
      Left = 158
      Top = 127
      Width = 75
      Height = 25
      Caption = 'Find'
      TabOrder = 0
      OnClick = btnIsochroneClick
    end
    object edtIsochroneTime: TEdit
      Left = 110
      Top = 46
      Width = 123
      Height = 21
      TabOrder = 1
      Text = '600'
    end
    object cmbbxIsochroneBuckets: TComboBox
      Left = 110
      Top = 73
      Width = 123
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 2
      Text = '5'
      Items.Strings = (
        '1'
        '5'
        '10')
    end
    object edtIsochroneAddress: TEdit
      Left = 56
      Top = 100
      Width = 177
      Height = 21
      TabOrder = 3
      Text = 'Gdynia, Plac Kaszubski 8'
    end
    object rbtnIsochroneProfileCar: TRadioButton
      Left = 56
      Top = 23
      Width = 41
      Height = 17
      Caption = 'Car'
      Checked = True
      TabOrder = 4
      TabStop = True
    end
    object rbtnIsochroneProfileBike: TRadioButton
      Left = 103
      Top = 23
      Width = 42
      Height = 17
      Caption = 'Bike'
      TabOrder = 5
    end
    object rbtnIsochroneProfileFoot: TRadioButton
      Left = 151
      Top = 23
      Width = 50
      Height = 17
      Caption = 'Foot'
      TabOrder = 6
    end
  end
end
