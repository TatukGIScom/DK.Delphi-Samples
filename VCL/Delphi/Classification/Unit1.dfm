object frmClassification: TfrmClassification
  Left = 0
  Top = 0
  Caption = 'Classification - TatukGIS DK11 Sample'
  ClientHeight = 761
  ClientWidth = 1284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 300
    Top = 70
    Width = 984
    Height = 691
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
  object GIS_Legend: TGIS_ControlLegend
    Left = 0
    Top = 70
    Width = 300
    Height = 691
    GIS_Viewer = GIS
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    TabOrder = 1
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerVertical]
  end
  object pnlClassification: TPanel
    Left = 0
    Top = 0
    Width = 1284
    Height = 35
    Align = alTop
    TabOrder = 2
    object lblField: TLabel
      AlignWithMargins = True
      Left = 91
      Top = 11
      Width = 26
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Field:'
      ExplicitHeight = 13
    end
    object lblMethod: TLabel
      AlignWithMargins = True
      Left = 282
      Top = 11
      Width = 40
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Method:'
      ExplicitHeight = 13
    end
    object lblClasses: TLabel
      AlignWithMargins = True
      Left = 797
      Top = 11
      Width = 40
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Classes:'
      Visible = False
      ExplicitHeight = 13
    end
    object lblRender: TLabel
      AlignWithMargins = True
      Left = 653
      Top = 11
      Width = 54
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Render by:'
      ExplicitHeight = 13
    end
    object lblInterval: TLabel
      AlignWithMargins = True
      Left = 902
      Top = 11
      Width = 42
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Interval:'
      Visible = False
      ExplicitHeight = 13
    end
    object lblManual: TLabel
      AlignWithMargins = True
      Left = 1118
      Top = 11
      Width = 38
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Manual:'
      Visible = False
      ExplicitHeight = 13
    end
    object cmbFields: TComboBox
      AlignWithMargins = True
      Left = 120
      Top = 7
      Width = 150
      Height = 21
      Hint = 'Select field to classify'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      TabOrder = 0
      OnChange = cmbFieldsChange
    end
    object cmbMethods: TComboBox
      AlignWithMargins = True
      Left = 325
      Top = 7
      Width = 150
      Height = 21
      Hint = 'Chose classifictaion method'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Select...'
      OnChange = cmbMethodsChange
      Items.Strings = (
        'Select...'
        'Defined Interval'
        'Equal Interval'
        'Geometrical Interval'
        'Manual'
        'Natural Breaks'
        'K-Means'
        'K-Means Spatial'
        'Quantile'
        'Quartile'
        'Standard Deviation'
        'Standard Deviation with Central'
        'Unique')
    end
    object cmbClasses: TComboBox
      AlignWithMargins = True
      Left = 840
      Top = 7
      Width = 50
      Height = 21
      Hint = 'Choose number of classes'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      ItemIndex = 4
      TabOrder = 2
      Text = '5'
      Visible = False
      OnChange = cmbClassesChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9')
    end
    object cmbRenderType: TComboBox
      AlignWithMargins = True
      Left = 710
      Top = 7
      Width = 75
      Height = 21
      Hint = 'Choose render type'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 3
      Text = 'Color'
      OnChange = cmbRenderTypeChange
      Items.Strings = (
        'Size / Width'
        'Color'
        'Outline width'
        'Outline color')
    end
    object edtInterval: TEdit
      AlignWithMargins = True
      Left = 947
      Top = 8
      Width = 75
      Height = 20
      Hint = 'Enter interval size'
      Margins.Top = 7
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Alignment = taRightJustify
      TabOrder = 4
      Text = '100'
      Visible = False
      OnChange = validateEdit
      ExplicitHeight = 21
    end
    object cmbStdInterval: TComboBox
      AlignWithMargins = True
      Left = 1031
      Top = 7
      Width = 75
      Height = 21
      Hint = 'Choose std. dev. multiple'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 5
      Text = '1 STDEV'
      Visible = False
      OnChange = cmbStdIntervalChange
      Items.Strings = (
        '1 STDEV'
        '1/2 STDEV'
        '1/3 STDEV'
        '1/4 STDEV')
    end
    object btnOpen: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 75
      Height = 27
      Margins.Right = 6
      Align = alLeft
      Caption = 'Open...'
      TabOrder = 6
      OnClick = btnOpenClick
    end
    object edtManualBreaks: TEdit
      AlignWithMargins = True
      Left = 1159
      Top = 8
      Width = 75
      Height = 20
      Hint = 'Enter interval size'
      Margins.Top = 7
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alLeft
      Alignment = taRightJustify
      TabOrder = 7
      Text = '0,10.5,20,50'
      Visible = False
      OnChange = validateEdit
      ExplicitHeight = 21
    end
    object btnAddManualBreak: TButton
      AlignWithMargins = True
      Left = 1237
      Top = 7
      Width = 50
      Height = 22
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Add'
      TabOrder = 8
      Visible = False
      OnClick = btnAddManualBreakClick
    end
    object cbxForceStatisticsCalculation: TCheckBox
      AlignWithMargins = True
      Left = 484
      Top = 7
      Width = 157
      Height = 21
      Hint = 'Check to create classification fields'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Caption = 'Force Statistics Calculation'
      Checked = True
      State = cbChecked
      TabOrder = 9
      OnClick = cbxForceStatisticsCalculationClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 1284
    Height = 35
    Align = alTop
    TabOrder = 3
    object lblStartColor: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 11
      Width = 54
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Start color:'
      ExplicitHeight = 13
    end
    object lblEndColor: TLabel
      AlignWithMargins = True
      Left = 97
      Top = 11
      Width = 48
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'End color:'
      ExplicitHeight = 13
    end
    object lblStartSize: TLabel
      AlignWithMargins = True
      Left = 181
      Top = 11
      Width = 49
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Start size:'
      ExplicitHeight = 13
    end
    object lblEndSize: TLabel
      AlignWithMargins = True
      Left = 295
      Top = 11
      Width = 43
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'End size:'
      ExplicitHeight = 13
    end
    object Label1: TLabel
      AlignWithMargins = True
      Left = 403
      Top = 11
      Width = 66
      Height = 20
      Margins.Left = 6
      Margins.Top = 10
      Margins.Right = 0
      Align = alLeft
      Caption = 'Class ID field:'
      ExplicitHeight = 13
    end
    object pnlStartColor: TPanel
      AlignWithMargins = True
      Left = 64
      Top = 7
      Width = 21
      Height = 21
      Hint = 'Click to change start color'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Color = 15595753
      ParentBackground = False
      TabOrder = 0
      OnClick = pnlStartColorClick
    end
    object pnlEndColor: TPanel
      AlignWithMargins = True
      Left = 148
      Top = 7
      Width = 21
      Height = 21
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Color = clGreen
      ParentBackground = False
      TabOrder = 1
      OnClick = pnlEndColorClick
    end
    object edtStartSize: TEdit
      AlignWithMargins = True
      Left = 233
      Top = 8
      Width = 50
      Height = 20
      Margins.Top = 7
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Alignment = taRightJustify
      TabOrder = 2
      Text = '1'
      OnChange = validateEdit
      ExplicitHeight = 21
    end
    object edtEndSize: TEdit
      AlignWithMargins = True
      Left = 341
      Top = 8
      Width = 50
      Height = 20
      Hint = 'Enter width start size'
      Margins.Top = 7
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Alignment = taRightJustify
      TabOrder = 3
      Text = '100'
      OnChange = validateEdit
      ExplicitHeight = 21
    end
    object cbxLegend: TCheckBox
      AlignWithMargins = True
      Left = 581
      Top = 7
      Width = 100
      Height = 21
      Hint = 'Check to create classification fields'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Caption = 'Show in legend'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = cbxLegendClick
    end
    object edtClassIdField: TEdit
      AlignWithMargins = True
      Left = 472
      Top = 8
      Width = 100
      Height = 20
      Hint = 'Enter field name for populating class id.'
      Margins.Top = 7
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Alignment = taRightJustify
      TabOrder = 5
      OnChange = validateEdit
      ExplicitHeight = 21
    end
    object cbxColorRamp: TCheckBox
      AlignWithMargins = True
      Left = 826
      Top = 7
      Width = 95
      Height = 21
      Hint = 'Check to create classification fields'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Caption = 'Use ColorRamp'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = cbxColorRampClick
    end
    object cmbColorRamps: TComboBox
      AlignWithMargins = True
      Left = 930
      Top = 7
      Width = 150
      Height = 21
      Hint = 'Chose classifictaion method'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Style = csDropDownList
      TabOrder = 7
      OnChange = cmbColorRampsChange
      Items.Strings = (
        'Select ...'
        'Defined Interval'
        'Equal Interval'
        'Geometrical Interval'
        'Natural Breaks (Jenks)'
        'Quantile'
        'Standard Deviation'
        '---'
        'Percentile?'
        'Box?')
    end
    object cbxColorRampName: TCheckBox
      AlignWithMargins = True
      Left = 690
      Top = 7
      Width = 127
      Height = 21
      Hint = 'Check to create classification fields'
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alLeft
      Caption = 'Use ColorRampName'
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = cbxColorRampNameClick
    end
  end
  object dlgColor: TColorDialog
    Left = 8
    Top = 80
  end
  object dlgFileOpen: TOpenDialog
    Left = 56
    Top = 80
  end
end
