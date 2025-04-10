object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'DataSet - TatukGIS DK11 Sample'
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
  object Splitter1: TSplitter
    Left = 233
    Top = 0
    Width = 5
    Height = 473
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 0
    Width = 233
    Height = 473
    Cursor = 18
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 50
    BorderStyle = bsNone
  end
  object DBGrid1: TDBGrid
    Left = 238
    Top = 0
    Width = 354
    Height = 473
    Align = alClient
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DataSource1: TDataSource
    DataSet = GIS_DataSet1
    Left = 80
    Top = 168
  end
  object GIS_DataSet1: TGIS_DataSet
    AfterScroll = GIS_DataSet1AfterScroll
    Left = 112
    Top = 128
  end
end
