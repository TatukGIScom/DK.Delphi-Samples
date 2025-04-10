object Form1: TForm1
  Left = 501
  Top = 273
  Caption = 'Hierarchy - TatukGIS DK11 Sample'
  ClientHeight = 465
  ClientWidth = 590
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
    Left = 201
    Top = 23
    Width = 389
    Height = 442
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    IncrementalPaint = False
    SelectionTransparency = 100
    ExplicitWidth = 391
    ExplicitHeight = 443
  end
  object GIS_ControlLegend: TGIS_ControlLegend
    Left = 0
    Top = 23
    Width = 201
    Height = 442
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    Align = alLeft
    ParentColor = False
    TabStop = True
    TabOrder = 1
    ExplicitHeight = 443
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 590
    Height = 23
    Caption = 'ToolBar1'
    TabOrder = 2
    ExplicitWidth = 592
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 89
      Height = 22
      Caption = 'Build hierarchy'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
