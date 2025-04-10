object Form1: TForm1
  Left = 200
  Top = 120
  BorderIcons = [biSystemMenu]
  Caption = 'FieldRules - TatukGIS DK11 Sample'
  ClientHeight = 278
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GIS_ControlAttributes1: TGIS_ControlAttributes
    Left = 0
    Top = 0
    Width = 193
    Height = 278
    Align = alLeft
    BorderStyle = bsSingle
    TabOrder = 0
    DesignSize = (
      189
      274)
  end
  object btnAddField: TButton
    Left = 206
    Top = 15
    Width = 75
    Height = 25
    Caption = 'Add field'
    TabOrder = 1
    OnClick = btnAddFieldClick
  end
  object btnAddAlias: TButton
    Left = 206
    Top = 46
    Width = 75
    Height = 25
    Caption = 'Add alias'
    TabOrder = 2
    OnClick = btnAddAliasClick
  end
  object btnAddCheck: TButton
    Left = 206
    Top = 77
    Width = 75
    Height = 25
    Caption = 'Add check'
    TabOrder = 3
    OnClick = btnAddCheckClick
  end
  object btnAddList: TButton
    Left = 206
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Add list'
    TabOrder = 4
    OnClick = btnAddListClick
  end
  object btnAddValidate: TButton
    Left = 207
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Add validate'
    TabOrder = 5
    OnClick = btnAddValidateClick
  end
  object btnAddDefault: TButton
    Left = 207
    Top = 139
    Width = 75
    Height = 25
    Caption = 'Add default'
    TabOrder = 6
    OnClick = btnAddDefaultClick
  end
  object btnSaveRules: TButton
    Left = 208
    Top = 207
    Width = 75
    Height = 25
    Caption = 'Save rules'
    TabOrder = 7
    OnClick = btnSaveRulesClick
  end
  object btn2: TButton
    Left = 208
    Top = 238
    Width = 75
    Height = 25
    Caption = 'Read rules'
    TabOrder = 8
    OnClick = btn2Click
  end
end
