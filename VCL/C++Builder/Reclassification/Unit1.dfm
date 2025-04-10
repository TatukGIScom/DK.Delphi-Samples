object frmReclassification: TfrmReclassification
  Left = 501
  Top = 273
  Margins.Left = 6
  Margins.Top = 6
  Margins.Right = 6
  Margins.Bottom = 6
  Caption = 'Reclassification - TatukGIS DK11 Sample'
  ClientHeight = 845
  ClientWidth = 1003
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 192
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 195
    Top = 0
    Width = 663
    Height = 833
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
    TabOrder = 0
    KeepScale = False
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Color = clWhite
    BorderStyle = bsNone
  end
  object GISLegend: TGIS_ControlLegend
    Left = 858
    Top = 0
    Width = 145
    Height = 833
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    GIS_Viewer = GIS
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ParentBiDiMode = False
    BiDiMode = bdLeftToRight
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabOrder = 1
    Touch.InteractiveGestures = []
    Touch.InteractiveGestureOptions = []
  end
  object progress: TProgressBar
    Left = 0
    Top = 833
    Width = 1003
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 2
  end
  object grpbReclassification: TGroupBox
    AlignWithMargins = True
    Left = 2
    Top = 2
    Width = 191
    Height = 829
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    Caption = 'Raster Reclassification'
    TabOrder = 3
    object lblReclassTable: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 199
      Width = 181
      Height = 117
      Margins.Top = 12
      Align = alTop
      Caption = 
        'In Reclassification Table you can define:'#13'- Value reclassificati' +
        'on definition (Old value -> New value)'#13'- Range reclassification ' +
        'definition (values from [Start..End] -> New value)'#13'- Value for N' +
        'ODATA, by typing  "nodata" -> New value'
      WordWrap = True
      ExplicitLeft = 4
      ExplicitTop = 198
      ExplicitWidth = 160
    end
    object lblNoData: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 493
      Width = 181
      Height = 39
      Margins.Top = 2
      Align = alTop
      Caption = 
        'Cell values outside the defined ranges will be filled with NODAT' +
        'A value.'
      WordWrap = True
      ExplicitLeft = 4
      ExplicitTop = 479
      ExplicitWidth = 161
    end
    object lblAltitudeZones: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 80
      Width = 181
      Height = 104
      Margins.Top = 12
      Align = alTop
      Caption = 
        'As an alternative to the Reclassification Table, reclassificatio' +
        'n can be run based on altitude map zones defined in the pixel la' +
        'yer Params property.'#13'Additionally, this method copies colors fro' +
        'm zones and automatically transfers them to the output layer.'
      Visible = False
      WordWrap = True
      ExplicitLeft = 4
      ExplicitTop = 79
      ExplicitWidth = 182
    end
    object sgrdReclassTable: TStringGrid
      AlignWithMargins = True
      Left = 5
      Top = 322
      Width = 181
      Height = 130
      Align = alTop
      ColCount = 3
      DefaultColWidth = 38
      DefaultRowHeight = 14
      FixedCols = 0
      RowCount = 10
      ScrollBars = ssVertical
      TabOrder = 0
      ColWidths = (
        19
        19
        19)
      RowHeights = (
        7
        7
        7
        7
        7
        7
        7
        7
        7
        7)
    end
    object chkNodata: TCheckBox
      AlignWithMargins = True
      Left = 5
      Top = 467
      Width = 181
      Height = 22
      Margins.Top = 12
      Margins.Bottom = 2
      Align = alTop
      Caption = 'Assign NODATA to missing values'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chkNodataClick
    end
    object btnReclassify: TButton
      AlignWithMargins = True
      Left = 5
      Top = 800
      Width = 181
      Height = 24
      Align = alBottom
      Caption = 'Reclassify'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnReclassifyClick
    end
    object btnUseTable: TButton
      AlignWithMargins = True
      Left = 4
      Top = 17
      Width = 183
      Height = 22
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
      Caption = 'Use table'
      TabOrder = 3
      OnClick = btnUseTableClick
    end
    object btnUseAltitudeZones: TButton
      AlignWithMargins = True
      Left = 4
      Top = 43
      Width = 183
      Height = 23
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
      Caption = 'Use Altitude Zones'
      TabOrder = 4
      OnClick = btnUseAltitudeZonesClick
    end
  end
end
