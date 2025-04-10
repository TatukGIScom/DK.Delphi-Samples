object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Hierarchy - TatukGIS DK11 Sample'
  ClientHeight = 657
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 832
    Height = 23
    Caption = 'ToolBar1'
    TabOrder = 0
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
  object GIS: TGIS_ViewerWnd
    Left = 201
    Top = 23
    Width = 631
    Height = 634
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    IncrementalPaint = False
    SelectionTransparency = 100
  end
  object GIS_ControlLegend: TGIS_ControlLegend
    Left = 0
    Top = 23
    Width = 201
    Height = 634
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    Align = alLeft
    ParentColor = False
    TabStop = True
    TabOrder = 2
  end
end
