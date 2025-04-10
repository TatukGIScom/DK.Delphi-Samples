object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Snapping - TatukGIS DK11 Sample'
  ClientHeight = 464
  ClientWidth = 582
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 582
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 0
    ExplicitWidth = 584
    object btnWithoutSnapping: TButton
      Left = 0
      Top = 0
      Width = 114
      Height = 22
      Hint = 'Start without snapping'
      Caption = 'Start w/o snapping'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnWithoutSnappingClick
    end
    object btnWithSnapping: TButton
      Left = 114
      Top = 0
      Width = 112
      Height = 22
      Caption = 'Start (with snapping)'
      TabOrder = 1
      OnClick = btnWithSnappingClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 582
    Height = 435
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    RestrictedDrag = False
    SelectionTransparency = 100
    ExplicitWidth = 584
  end
  object tmrWithoutSnapping: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrWithoutSnappingTimer
    Left = 16
    Top = 48
  end
  object tmrWithSnapping: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrWithSnappingTimer
    Left = 48
    Top = 48
  end
end
