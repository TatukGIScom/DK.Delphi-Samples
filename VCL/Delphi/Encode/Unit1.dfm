object Form1: TForm1
  Left = 200
  Top = 120
  ActiveControl = GIS
  Caption = 'Encode - TatukGIS DK11 Sample'
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
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 22
    Width = 592
    Height = 432
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 100
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
    object btnCloseAll: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Close All'
      TabOrder = 3
      OnClick = btnCloseAllClick
    end
    object btnOpenBase: TButton
      Left = 75
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Open Base'
      TabOrder = 0
      OnClick = btnOpenBaseClick
    end
    object btnEncode: TButton
      Left = 175
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Encode Layer'
      TabOrder = 1
      OnClick = btnEncodeClick
    end
    object btnOpenEncoded: TButton
      Left = 275
      Top = 0
      Width = 100
      Height = 22
      Caption = 'Open Encoded'
      TabOrder = 2
      OnClick = btnOpenEncodedClick
    end
  end
end
