object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Topology - TatukGIS DK11 Sample'
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 23
    Width = 592
    Height = 431
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 100
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 23
    AutoSize = True
    ButtonHeight = 23
    Caption = 'ToolBar1'
    TabOrder = 1
    object btnAplusB: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 23
      Caption = 'A + B'
      TabOrder = 0
      OnClick = btnAplusBClick
    end
    object btnAmultB: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 23
      Caption = 'A * B'
      TabOrder = 1
      OnClick = btnAmultBClick
    end
    object btnAminusB: TButton
      Left = 150
      Top = 0
      Width = 75
      Height = 23
      Caption = 'A - B'
      TabOrder = 2
      OnClick = btnAminusBClick
    end
    object btnBminusA: TButton
      Left = 225
      Top = 0
      Width = 75
      Height = 23
      Caption = 'B - A'
      TabOrder = 3
      OnClick = btnBminusAClick
    end
    object btnAxorB: TButton
      Left = 300
      Top = 0
      Width = 75
      Height = 23
      Caption = 'A xor B'
      TabOrder = 4
      OnClick = btnAxorBClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
