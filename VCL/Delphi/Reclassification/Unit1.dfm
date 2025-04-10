object frmReclassification: TfrmReclassification
  Left = 0
  Top = 0
  Caption = 'Reclassification'
  ClientHeight = 761
  ClientWidth = 984
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object GIS: TGIS_ViewerWnd
    Left = 256
    Top = 0
    Width = 528
    Height = 744
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
    Left = 784
    Top = 0
    Width = 200
    Height = 744
    GIS_Viewer = GIS
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
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
    Top = 744
    Width = 984
    Height = 17
    Align = alBottom
    TabOrder = 2
  end
  object grpbReclassification: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 250
    Height = 738
    Align = alLeft
    Caption = 'Raster Reclassification'
    TabOrder = 3
    object lblReclassTable: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 238
      Width = 234
      Height = 105
      Margins.Left = 6
      Margins.Top = 24
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alTop
      Caption = 
        'In Reclassification Table you can define:'#13'- Value reclassificati' +
        'on definition (Old value -> New value)'#13'- Range reclassification ' +
        'definition (values from [Start..End] -> New value)'#13'- Value for N' +
        'ODATA, by typing  "nodata" -> New value'
      WordWrap = True
      ExplicitWidth = 231
    end
    object lblNoData: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 634
      Width = 234
      Height = 30
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 6
      Margins.Bottom = 12
      Align = alBottom
      Caption = 
        'Cell values outside the defined ranges will be filled with NODAT' +
        'A value.'
      WordWrap = True
      ExplicitWidth = 223
    end
    object lblAltitudeZones: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 103
      Width = 234
      Height = 105
      Margins.Left = 6
      Margins.Top = 24
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alTop
      Caption = 
        'As an alternative to the Reclassification Table, reclassificatio' +
        'n can be run based on altitude map zones defined in the pixel la' +
        'yer Params property.'#13'Additionally, this method copies colors fro' +
        'm zones and automatically transfers them to the output layer.'
      Visible = False
      WordWrap = True
      ExplicitWidth = 232
    end
    object sgrdReclassTable: TStringGrid
      AlignWithMargins = True
      Left = 8
      Top = 355
      Width = 234
      Height = 206
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alTop
      ColCount = 3
      DefaultColWidth = 75
      FixedCols = 0
      RowCount = 8
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object chkNodata: TCheckBox
      AlignWithMargins = True
      Left = 8
      Top = 611
      Width = 234
      Height = 17
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alBottom
      Caption = 'Assign NODATA to missing values'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chkNodataClick
    end
    object btnReclassify: TButton
      AlignWithMargins = True
      Left = 8
      Top = 682
      Width = 234
      Height = 48
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alBottom
      Caption = 'Reclassify'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnReclassifyClick
    end
    object btnUseTable: TButton
      AlignWithMargins = True
      Left = 5
      Top = 20
      Width = 240
      Height = 25
      Align = alTop
      Caption = 'Use table'
      TabOrder = 3
      OnClick = btnUseTableClick
    end
    object btnUseAltitudeZones: TButton
      AlignWithMargins = True
      Left = 5
      Top = 51
      Width = 240
      Height = 25
      Align = alTop
      Caption = 'Use Altitude Zones'
      TabOrder = 4
      OnClick = btnUseAltitudeZonesClick
    end
  end
end
