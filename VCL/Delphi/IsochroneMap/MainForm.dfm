object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Isochrone Map - TatukGIS DK11 Sample'
  ClientHeight = 603
  ClientWidth = 798
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
    Top = 22
    Width = 610
    Height = 581
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
    SelectionTransparency = 100
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
  end
  object GIS_ControlScale1: TGIS_ControlScale
    Left = 8
    Top = 28
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
    Left = 610
    Top = 22
    Width = 188
    Height = 581
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 188
      Height = 249
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
        Width = 42
        Height = 13
        Caption = '&Distance'
        FocusControl = edtDistance
      end
      object lblAddrTo: TLabel
        Left = 24
        Top = 160
        Width = 30
        Height = 13
        Caption = '&Zones'
        FocusControl = edtZones
      end
      object lbl1: TLabel
        Left = 24
        Top = 211
        Width = 145
        Height = 32
        AutoSize = False
        Caption = 'Click on the map to set start point and generate isochrone'
        WordWrap = True
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
      object edtDistance: TEdit
        Left = 24
        Top = 134
        Width = 145
        Height = 21
        TabOrder = 2
        Text = '4000'
      end
      object edtZones: TEdit
        Left = 24
        Top = 174
        Width = 145
        Height = 21
        TabOrder = 3
        Text = '3'
      end
    end
    object GIS_ControlLegend1: TGIS_ControlLegend
      Left = 0
      Top = 249
      Width = 188
      Height = 332
      GIS_Viewer = GIS
      Mode = Layers
      Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
      ReverseOrder = False
      DialogOptions.VectorWizardUniqueLimit = 256
      DialogOptions.VectorWizardUniqueSearchLimit = 16384
      Align = alClient
      ParentColor = False
      TabStop = True
      TabOrder = 1
    end
  end
  object tlb1: TToolBar
    Left = 0
    Top = 0
    Width = 798
    Height = 22
    AutoSize = True
    Images = il1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object btnFullExtent: TToolButton
      Left = 0
      Top = 0
      Cursor = crHandPoint
      Hint = 'Full Extent'
      Caption = 'btnFullExtent'
      ImageIndex = 0
      OnClick = btnFullExtentClick
    end
    object btnZoomIn: TToolButton
      Left = 23
      Top = 0
      Cursor = crHandPoint
      Hint = 'Zoom In'
      Caption = 'btnZoomIn'
      ImageIndex = 1
      OnClick = btnZoomInClick
    end
    object btnZoomOut: TToolButton
      Left = 46
      Top = 0
      Cursor = crHandPoint
      Hint = 'Zoom Out'
      Caption = 'btnZoomOut'
      ImageIndex = 2
      OnClick = btnZoomOutClick
    end
  end
  object il1: TImageList
    Left = 104
    Top = 104
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005A08
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005A08
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009C0000009C0000009C0000005200000052000000520000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000BD71
      2100420000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000BD71
      2100420000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000EF59
      0000D6380000B5180000E7960000E7960000E796000039000000520000005200
      0000520000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CE792100DE96
      4A00B55900004200000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CE792100DE96
      4A00B55900004200000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF961800FF79
      0000FFFFF700FFF79400FFBE1800E796000052000000390000009C0000009C00
      0000520000005200000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6792100DE964A00B559
      0000420000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6792100DE964A00B559
      0000420000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFA63100FFFF
      FF00FFFFFF00FFFFFF00FFF79400FFDF5200630000009C0000009C0000009C00
      0000840000005200000000000000000000000000000000000000000000000000
      0000B5100000AD100000AD100000B5100000C6792100D6964200B55900004200
      0000000000000000000000000000000000000000000000000000000000000000
      0000B5100000AD100000AD100000B5100000C6792100D6964200B55900004200
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFBE6300FFB65200FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFE700940000007B0000009C0000009C00
      00009C0000009C0000005200000000000000000000000000000000000000B510
      0000EFDFAD00EFEFCE00EFEFC600EFDFB50094200000B5590000420000000000
      000000000000000000000000000000000000000000000000000000000000B510
      0000EFDFAD00EFEFCE00EFEFC600EFDFB50094200000B5590000420000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFCF7B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00AD100000AD080000FF7900009C000000730000005200
      0000520000009C00000052000000000000000000000000000000BD100000F7EF
      C600F7F7DE00C6863900B5100000F7EFD600EFD7A50029000000000000000000
      0000000000000000000000000000000000000000000000000000BD100000F7EF
      C600F7F7DE00F7F7DE00F7EFD600F7EFD600EFD7A50029000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFDF9400FFFFFF00FFFF
      FF00FFFFFF00C6280000B5100000AD080000FFFFFF00FFFFFF00FFFFAD00EF96
      0000C661000052000000520000000000000000000000BD100000FFEFCE00FFFF
      EF00EFD7AD00BD712900B5100000F7EFCE00EFDFB500E7C79400290000000000
      00000000000000000000000000000000000000000000BD100000FFEFCE00FFFF
      EF00FFFFE700FFFFDE00FFF7D600F7EFCE00EFDFB500E7C79400290000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFEFA500FFFFFF00FFFF
      FF00FFFFFF00C6300000FF860800FF860000AD080000FFFFFF00FFFFB500F7B6
      0800C6610000C6610000520000000000000000000000C6100000DEA66300B510
      0000B5100000B5100000B5100000B5100000B5100000E7C79400290000000000
      00000000000000000000000000000000000000000000C6100000FFEFBD00B510
      0000B5100000B5100000B5100000B5100000B5100000E7C79400290000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFF7B500FFFFFF00FFFF
      FF00E7792900FFA63900FF8E1000FF860000FF860000AD080000FFFFD600EF96
      0000BD49000052000000520000000000000000000000CE382900F7D7B500E7C7
      A500DEBE8C00C6792900B5100000E7D7B500EFD7A500E7BE8C00290000000000
      00000000000000000000000000000000000000000000CE382900FFF7D600F7E7
      C600E7C7A500DEBE8C00DEBE8C00E7CFAD00DEBE8400E7BE8C00290000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFC600FFFFC600FFFF
      FF00F79E5A00FFC76300FFA63900FF962100FF961800B5180000FFFFBD00F79E
      1000C6590000520000009C0000000000000000000000D6595200FFFFE700FFF7
      E700E7BE9400BD691800B5100000F7DFB500EFCF9C00E7BE8400290000000000
      00000000000000000000000000000000000000000000D6595200FFFFE700FFF7
      E700FFFFEF00FFFFE700FFF7CE00F7DFB500EFCF9C00E7BE8400290000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFCE00FFFF
      FF00FFFFFF00F7964A00FFC76300FFAE4A00FFA63900FF9E2100B5100000FFB6
      390073000000A500000000000000000000000000000000000000D6514200FFF7
      DE00FFE7BD00F7CF9C00B5100000EFD7A500EFCF9C0029000000000000000000
      0000000000000000000000000000000000000000000000000000D6514200FFF7
      DE00FFEFCE00FFEFBD00FFE7B500EFD7A500EFCF9C0029000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFCE00FFFF
      CE00FFC78C00F7B66B00E7964200FFB65A00FFB65200FFFFD600BD180000FFCF
      630084000000BD1800000000000000000000000000000000000000000000C620
      1000FFF7D600FFDFA500F7D7A500EFC794002900000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C620
      1000FFF7D600FFDFA500F7D7A500EFC794002900000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFCF
      9C00FFFFC600FFE7A500FFDF9400FFCF7B00E7691800D6510000C6280000FF86
      0000F76100000000000000000000000000000000000000000000000000000000
      0000BD1000003100000031000000290000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BD1000003100000031000000290000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFEFAD00FFE79C00FFD78400E7792900FFB65200FFA631000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFEFFFEF0000F81FFFE7FFE70000
      E007FFC3FFC30000C003FF87FF870000C003F00FF00F00008001E01FE01F0000
      8001C03FC03F00008001801F801F00008001801F801F00008001801F801F0000
      8001801F801F0000C003C03FC03F0000C003E07FE07F0000E007F0FFF0FF0000
      F81FFFFFFFFF0000FFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
end
