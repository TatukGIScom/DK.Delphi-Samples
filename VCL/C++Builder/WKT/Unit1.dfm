object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Well Known Text (WKT) - TatukGIS DK11 Sample'
  ClientHeight = 461
  ClientWidth = 583
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
    Width = 583
    Height = 346
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 100
    ExplicitWidth = 584
    ExplicitHeight = 349
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 442
    Width = 583
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Use list to change WKT type'
    ExplicitTop = 445
    ExplicitWidth = 584
  end
  object Memo1: TMemo
    Left = 0
    Top = 375
    Width = 583
    Height = 67
    Align = alBottom
    Lines.Strings = (
      '')
    ScrollBars = ssVertical
    TabOrder = 2
    OnChange = Memo1Change
    ExplicitTop = 378
    ExplicitWidth = 584
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 583
    Height = 29
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 3
    ExplicitWidth = 584
    DesignSize = (
      583
      29)
    object cbType: TComboBox
      Left = 0
      Top = 0
      Width = 145
      Height = 21
      Style = csDropDownList
      Anchors = [akRight, akBottom]
      TabOrder = 0
      OnChange = cbTypeChange
      Items.Strings = (
        'POINT'
        'MULTIPOINT'
        'LINESTRING'
        'MULTILINESTRING'
        'POLYGON')
    end
  end
end
