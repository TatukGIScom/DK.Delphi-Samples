object Form1: TForm1
  Left = 201
  Top = 116
  Caption = 'Well Known Text (WKT) - TatukGIS DK11 Sample'
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
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 592
    Height = 358
    Cursor = 18
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
    SimplePanel = True
    SimpleText = 'Use list to change WKT type'
  end
  object Memo1: TMemo
    Left = 0
    Top = 387
    Width = 592
    Height = 67
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 2
    OnChange = Memo1Change
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 3
    object cbType: TComboBox
      Left = 0
      Top = 0
      Width = 121
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbTypeChange
      Items.Strings = (
        'POINT'
        'MULTIPOINT'
        'LINESTRING'
        'MULTILINESTRING'
        'POLYGON'
        'POINT 3D'
        'MULTIPOINT 3D'
        'LINESTRING 3D'
        'MULTILINESTRING 3D'
        'POLYGON 3D'
        'GEOMETRYCOLLECTION')
    end
  end
end
