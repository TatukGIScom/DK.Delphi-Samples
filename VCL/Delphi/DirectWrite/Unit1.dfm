object Form1: TForm1
  Left = 200
  Top = 120
  ActiveControl = GIS
  Caption = 'Direct write - TatukGIS DK11 Sample'
  ClientHeight = 473
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 22
    Width = 592
    Height = 432
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
    Mode = Zoom
    BorderStyle = bsNone
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
  end
  object Toolbar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 22
    AutoSize = True
    Caption = 'Toolbar1'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object btnBuild: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Build layer'
      TabOrder = 3
      OnClick = btnBuildClick
    end
    object btnImportLayer: TButton
      Left = 75
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Import layer'
      Enabled = False
      TabOrder = 0
      OnClick = btnImportLayerClick
    end
    object btnMergeLayer: TButton
      Left = 175
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Merge layer'
      Enabled = False
      TabOrder = 1
      OnClick = btnMergeLayerClick
    end
    object btnDirectWrite: TButton
      Left = 275
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Direct write'
      Enabled = False
      TabOrder = 4
      OnClick = btnDirectWriteClick
    end
    object btnDirectMerge: TButton
      Left = 375
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Merge helper'
      Enabled = False
      TabOrder = 2
      OnClick = btnDirectMergeClick
    end
  end
end
