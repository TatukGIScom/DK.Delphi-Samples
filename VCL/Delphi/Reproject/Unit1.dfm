object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Reproject - TatukGIS DK11 Sample'
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
    Top = 21
    Width = 592
    Height = 452
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
    Height = 21
    AutoSize = True
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object cbxSrcProjection: TComboBox
      Left = 8
      Top = 0
      Width = 201
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbxSrcProjectionChange
    end
    object ToolButton3: TToolButton
      Left = 209
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object Button1: TButton
      Left = 217
      Top = 0
      Width = 75
      Height = 21
      Caption = 'Reproject'
      TabOrder = 0
      OnClick = Button2Click
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'shp'
    Filter = 'SHP File|*.shp'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 8
    Top = 32
  end
end
