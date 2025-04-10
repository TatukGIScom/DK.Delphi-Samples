object frmMain: TfrmMain
  Left = 200
  Top = 120
  Caption = 'Projections - TatukGIS DK11 Sample'
  ClientHeight = 463
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 583
    Height = 29
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    ExplicitWidth = 584
    object cbxSrcProjection: TComboBox
      Left = 0
      Top = 0
      Width = 193
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbxSrcProjectionChange
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 583
    Height = 434
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    CodePage = 1252
    IncrementalPaint = False
    SelectionTransparency = 100
    ExplicitWidth = 584
    ExplicitHeight = 435
  end
end
