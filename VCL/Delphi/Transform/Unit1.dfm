object Form1: TForm1
  Left = 200
  Top = 120
  ActiveControl = GIS
  Caption = 'Transform - TatukGIS DK11 Sample'
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
    Left = 97
    Top = 0
    Width = 495
    Height = 454
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 100
    Color = clBtnFace
    BorderStyle = bsNone
    OnMouseMove = GISMouseMove
    ExplicitLeft = 0
    ExplicitTop = 22
    ExplicitWidth = 592
    ExplicitHeight = 432
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 97
    Height = 454
    Align = alLeft
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitHeight = 280
    object btnTransform: TButton
      Left = 8
      Top = 8
      Width = 83
      Height = 25
      Caption = 'Transform'
      TabOrder = 0
      OnClick = btnTransformClick
    end
    object btnCut: TButton
      Left = 8
      Top = 39
      Width = 83
      Height = 25
      Caption = 'Cuting polygon'
      TabOrder = 1
      OnClick = btnCutClick
    end
    object btnSave: TButton
      Left = 8
      Top = 72
      Width = 83
      Height = 25
      Caption = 'Save to file'
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnLoad: TButton
      Left = 8
      Top = 104
      Width = 83
      Height = 25
      Caption = 'Read from file'
      TabOrder = 3
      OnClick = btnLoadClick
    end
  end
end
