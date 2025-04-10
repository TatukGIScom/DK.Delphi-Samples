object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Tracking test - TatukGIS DK11 Sample'
  ClientHeight = 473
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object chkUseLock: TCheckBox
      Left = 8
      Top = 0
      Width = 89
      Height = 22
      Caption = 'Use Lock'
      TabOrder = 1
    end
    object btnAnimate: TButton
      Left = 97
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Animate'
      TabOrder = 0
      OnClick = btnAnimateClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 592
    Height = 425
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    IncrementalPaint = False
    SelectionTransparency = 100
  end
end
