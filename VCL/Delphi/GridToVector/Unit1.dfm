object frmGridToVector: TfrmGridToVector
  Left = 0
  Top = 0
  Caption = 'GridToVector - TatukGIS DK11 Sample'
  ClientHeight = 661
  ClientWidth = 884
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 661
    Align = alLeft
    TabOrder = 0
    object gbxData: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 192
      Height = 85
      Align = alTop
      Caption = 'Load data'
      TabOrder = 0
      object btnDem: TButton
        AlignWithMargins = True
        Left = 5
        Top = 49
        Width = 182
        Height = 25
        Align = alTop
        Caption = 'DEM'
        TabOrder = 0
        OnClick = btnDemClick
      end
      object btnLandCover: TButton
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 182
        Height = 25
        Align = alTop
        Caption = 'Land Cover'
        TabOrder = 1
        OnClick = btnLandCoverClick
      end
    end
    object gbxGridToPolygon: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 171
      Width = 192
      Height = 80
      Align = alTop
      Caption = 'Grid to polygon'
      TabOrder = 1
      object chkSplit: TCheckBox
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 182
        Height = 23
        Align = alTop
        Caption = 'Split shapes'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object btnGridToPolygon: TButton
        AlignWithMargins = True
        Left = 5
        Top = 47
        Width = 182
        Height = 25
        Align = alTop
        Caption = 'Generate'
        TabOrder = 1
        OnClick = btnGridToPolygonClick
      end
    end
    object gbxSelected: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 343
      Width = 192
      Height = 314
      Align = alClient
      Caption = 'Shape info'
      TabOrder = 2
      object GIS_ControlAttributes: TGIS_ControlAttributes
        AlignWithMargins = True
        Left = 5
        Top = 18
        Width = 182
        Height = 291
        Align = alClient
        TabOrder = 0
        DesignSize = (
          182
          291)
      end
    end
    object gbxGridToPoint: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 257
      Width = 192
      Height = 80
      Align = alTop
      Caption = 'Grid to point'
      TabOrder = 3
      object lblPointSpacing: TLabel
        Left = 13
        Top = 23
        Width = 67
        Height = 13
        Caption = 'Point spacing:'
      end
      object btnGridToPoints: TButton
        AlignWithMargins = True
        Left = 5
        Top = 50
        Width = 182
        Height = 25
        Align = alBottom
        Caption = 'Generate'
        TabOrder = 0
        OnClick = btnGridToPointsClick
      end
      object edtPointSpacing: TEdit
        Left = 107
        Top = 20
        Width = 85
        Height = 21
        Alignment = taRightJustify
        TabOrder = 1
        Text = '1000'
      end
    end
    object gbsCommonParameters: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 95
      Width = 192
      Height = 70
      Align = alTop
      Caption = 'Common parameters'
      TabOrder = 4
      object lblTolerance: TLabel
        Left = 5
        Top = 23
        Width = 51
        Height = 13
        Caption = 'Tolerance:'
      end
      object chkIgnoreNoData: TCheckBox
        AlignWithMargins = True
        Left = 5
        Top = 42
        Width = 182
        Height = 23
        Align = alBottom
        Caption = 'Ignore NoData'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edtTolerance: TEdit
        Left = 104
        Top = 20
        Width = 85
        Height = 21
        Alignment = taRightJustify
        TabOrder = 1
        Text = '1'
      end
    end
  end
  object Panel1: TPanel
    Left = 200
    Top = 0
    Width = 684
    Height = 661
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object GIS: TGIS_ViewerWnd
      Left = 1
      Top = 1
      Width = 682
      Height = 642
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
      BorderStyle = bsNone
      OnMouseDown = GISMouseDown
      OnMouseWheelUp = GISMouseWheelUp
      OnMouseWheelDown = GISMouseWheelDown
    end
    object progress: TProgressBar
      Left = 1
      Top = 643
      Width = 682
      Height = 17
      Align = alBottom
      TabOrder = 1
    end
  end
end
