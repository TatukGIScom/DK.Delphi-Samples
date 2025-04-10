object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 403
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 660
    Height = 29
    ButtonHeight = 26
    Caption = 'ToolBar1'
    TabOrder = 0
    object btnCutting: TButton
      Left = 0
      Top = 0
      Width = 81
      Height = 26
      Caption = 'Do cutting'
      TabOrder = 0
      OnClick = btnCuttingClick
    end
    object btnZoom: TButton
      Left = 81
      Top = 0
      Width = 75
      Height = 26
      Caption = 'Zoom'
      TabOrder = 1
      OnClick = btnZoomClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 539
    Height = 374
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    BorderStyle = bsNone
    ExplicitWidth = 533
  end
  object GIS_ControlLegend1: TGIS_ControlLegend
    Left = 539
    Top = 29
    Width = 121
    Height = 374
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    DialogOptions.VectorWizardUniqueLimit = 256
    DialogOptions.VectorWizardUniqueSearchLimit = 16384
    Align = alRight
    ParentColor = False
    TabStop = True
    TabOrder = 2
  end
end
