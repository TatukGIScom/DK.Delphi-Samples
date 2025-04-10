object frmStatistics: TfrmStatistics
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Statistics - TatukGIS DK11 Sample'
  ClientHeight = 691
  ClientWidth = 1274
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbxResults: TGroupBox
    Left = 974
    Top = 0
    Width = 300
    Height = 691
    Align = alRight
    BiDiMode = bdLeftToRight
    Caption = 'Results'
    DoubleBuffered = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    object mmResults: TMemo
      Left = 2
      Top = 15
      Width = 296
      Height = 647
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object pnlResultsIO: TPanel
      Left = 2
      Top = 662
      Width = 296
      Height = 27
      Align = alBottom
      TabOrder = 1
      object btnLoadStat: TButton
        AlignWithMargins = True
        Left = 31
        Top = 1
        Width = 100
        Height = 25
        Margins.Left = 30
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alLeft
        Caption = 'Load *.ttkstats'
        TabOrder = 0
        OnClick = btnLoadStatClick
      end
      object btnSaveStat: TButton
        AlignWithMargins = True
        Left = 165
        Top = 1
        Width = 100
        Height = 25
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 30
        Margins.Bottom = 0
        Align = alRight
        Caption = 'Save *.ttkstats'
        TabOrder = 1
        OnClick = btnSaveStatClick
      end
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 190
    Height = 691
    Align = alLeft
    TabOrder = 1
    object gbxLayers: TGroupBox
      Left = 1
      Top = 1
      Width = 188
      Height = 120
      Align = alTop
      Caption = 'Select layer'
      TabOrder = 0
      object rbtnVector: TRadioButton
        Left = 16
        Top = 24
        Width = 60
        Height = 17
        Caption = 'Vector'
        TabOrder = 0
        OnClick = rbtnVectorClick
      end
      object rbtnGrid: TRadioButton
        Left = 16
        Top = 47
        Width = 60
        Height = 17
        Caption = 'Grid'
        TabOrder = 1
        OnClick = rbtnGridClick
      end
      object rbtnPixel: TRadioButton
        Left = 16
        Top = 70
        Width = 60
        Height = 17
        Caption = 'Pixel'
        TabOrder = 2
        OnClick = rbtnPixelClick
      end
      object rbtnCustom: TRadioButton
        Left = 16
        Top = 93
        Width = 60
        Height = 17
        Caption = 'Custom'
        TabOrder = 3
        OnClick = rbtnCustomClick
      end
      object btnOpen: TButton
        Left = 74
        Top = 89
        Width = 79
        Height = 25
        Caption = 'Open file...'
        DisabledImageIndex = 1
        Enabled = False
        ImageAlignment = iaCenter
        ImageIndex = 0
        TabOrder = 4
        OnClick = btnOpenClick
      end
    end
    object gbxStatistics: TGroupBox
      Left = 1
      Top = 121
      Width = 188
      Height = 259
      Align = alTop
      Caption = 'Select statistics'
      TabOrder = 1
      object chlbxStatistics: TCheckListBox
        Left = 2
        Top = 42
        Width = 184
        Height = 215
        Align = alClient
        ItemHeight = 13
        Items.Strings = (
          'Average'
          'Count'
          'CountMissings'
          'Majority'
          'Max'
          'Median'
          'Min'
          'Minority'
          'Percentile'
          'Range'
          'StandardDeviation'
          'Sample'
          'Sum'
          'Variance'
          'Variety'
          'Unique')
        TabOrder = 0
      end
      object pnlStatisticsButtons: TPanel
        Left = 2
        Top = 15
        Width = 184
        Height = 27
        Align = alTop
        TabOrder = 1
        object btnBasic: TButton
          Left = 1
          Top = 1
          Width = 59
          Height = 25
          Align = alLeft
          Caption = 'Basic'
          TabOrder = 0
          OnClick = btnBasicClick
        end
        object btnStandard: TButton
          Left = 60
          Top = 1
          Width = 64
          Height = 25
          Align = alClient
          Caption = 'Standard'
          TabOrder = 1
          OnClick = btnStandardClick
        end
        object btnAll: TButton
          Left = 124
          Top = 1
          Width = 59
          Height = 25
          Align = alRight
          Caption = 'All'
          TabOrder = 2
          OnClick = btnAllClick
        end
      end
    end
    object gbxDefinitions: TGroupBox
      Left = 1
      Top = 380
      Width = 188
      Height = 251
      Align = alClient
      Caption = 'Statistics definitions'
      TabOrder = 2
      object chlbxDefinitions: TCheckListBox
        Left = 2
        Top = 42
        Width = 184
        Height = 207
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
      object pnlDefinitionsButtons: TPanel
        Left = 2
        Top = 15
        Width = 184
        Height = 27
        Align = alTop
        TabOrder = 1
        object btnSelect: TButton
          Left = 1
          Top = 1
          Width = 89
          Height = 25
          Align = alLeft
          Caption = 'Select all'
          TabOrder = 0
          OnClick = btnSelectClick
        end
        object btnDeselect: TButton
          Left = 94
          Top = 1
          Width = 89
          Height = 25
          Align = alRight
          Caption = 'Deselect all'
          TabOrder = 1
          OnClick = btnDeselectClick
        end
      end
    end
    object btnCalculate: TButton
      Left = 1
      Top = 665
      Width = 188
      Height = 25
      Align = alBottom
      Caption = 'Calculate statistics'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = btnCalculateClick
    end
    object cbxFastStatistics: TCheckBox
      Left = 1
      Top = 648
      Width = 188
      Height = 17
      Align = alBottom
      Caption = 'Fast statistics'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object cbxUseBesselCorrection: TCheckBox
      Left = 1
      Top = 631
      Width = 188
      Height = 17
      Align = alBottom
      Caption = 'Use Bessel'#39's correction'
      TabOrder = 5
    end
  end
  object pnlMain: TPanel
    Left = 190
    Top = 0
    Width = 784
    Height = 691
    Align = alClient
    TabOrder = 2
    object progress: TProgressBar
      Left = 1
      Top = 673
      Width = 782
      Height = 17
      Align = alBottom
      TabOrder = 0
    end
    object GIS: TGIS_ViewerWnd
      Left = 1
      Top = 1
      Width = 782
      Height = 672
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
      BorderStyle = bsNone
      BusyEvent = doBusyEvent
    end
  end
  object openDialog: TOpenDialog
    Left = 208
    Top = 8
  end
end
