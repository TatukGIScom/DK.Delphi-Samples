object Form1: TForm1
  Left = 200
  Top = 120
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'ConvertOSM - TatukGIS DK11 Sample'
  ClientHeight = 424
  ClientWidth = 318
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
  object grpTTKLS: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 57
    Caption = 'OSM file path'
    TabOrder = 0
    object btnOSM: TButton
      Left = 256
      Top = 24
      Width = 27
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnOSMClick
    end
    object edtOSMPath: TEdit
      Left = 8
      Top = 24
      Width = 241
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
  end
  object grp1: TGroupBox
    Left = 8
    Top = 64
    Width = 289
    Height = 57
    Caption = 'Export directory'
    TabOrder = 1
    object btnSelectFolder: TButton
      Left = 256
      Top = 24
      Width = 27
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnSelectFolderClick
    end
    object edExportDir: TEdit
      Left = 8
      Top = 24
      Width = 241
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
  end
  object grp2: TGroupBox
    Left = 8
    Top = 120
    Width = 289
    Height = 105
    Caption = 'Export options'
    TabOrder = 2
    object cbep: TCheckBox
      Left = 11
      Top = 24
      Width = 97
      Height = 17
      Caption = 'export points'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbel: TCheckBox
      Left = 11
      Top = 48
      Width = 97
      Height = 17
      Caption = 'export lines'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cbepp: TCheckBox
      Left = 11
      Top = 72
      Width = 97
      Height = 17
      Caption = 'export polygons'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object rgLayerFormat: TRadioGroup
      Left = 128
      Top = 16
      Width = 145
      Height = 73
      Caption = 'Layer format'
      ItemIndex = 0
      Items.Strings = (
        'SHP'
        'SQL Native (Access)'
        'SQL Native (Sqlite)')
      TabOrder = 3
    end
  end
  object btnConvert: TButton
    Left = 120
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Convert'
    TabOrder = 3
    OnClick = btnConvertClick
  end
  object mmolog: TMemo
    Left = 8
    Top = 264
    Width = 289
    Height = 121
    TabOrder = 4
  end
  object stat1: TStatusBar
    Left = 0
    Top = 405
    Width = 318
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object dlgOpenOSM: TOpenDialog
    DefaultExt = 'osm'
    Filter = '*.osm'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 264
    Top = 216
  end
end
