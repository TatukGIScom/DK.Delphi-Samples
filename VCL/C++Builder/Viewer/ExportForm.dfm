object frmExportLayer: TfrmExportLayer
  Left = 299
  Top = 190
  Caption = 'frmExportLayer'
  ClientHeight = 266
  ClientWidth = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 11
    Top = 8
    Width = 121
    Height = 13
    Caption = 'Select l&ayer to import from'
    FocusControl = cmbLayersList
  end
  object Label2: TLabel
    Left = 11
    Top = 136
    Width = 85
    Height = 13
    Caption = 'Select s&hape type'
    FocusControl = cmbShapeType
  end
  object Label3: TLabel
    Left = 11
    Top = 176
    Width = 77
    Height = 13
    Caption = '&Query statement'
    FocusControl = edtQuery
  end
  object grpSelectExtent: TRadioGroup
    Left = 11
    Top = 56
    Width = 230
    Height = 73
    Caption = '&Select extent'
    Items.Strings = (
      '&Whole extent'
      '&Touched by visible extent'
      'Clippe&d by visible extent')
    TabOrder = 0
  end
  object cmbLayersList: TComboBox
    Left = 11
    Top = 24
    Width = 230
    Height = 21
    Style = csDropDownList
    TabOrder = 1
  end
  object cmbShapeType: TComboBox
    Left = 11
    Top = 152
    Width = 230
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      'Any supported shape'
      'Only Arcs (lines)'
      'Only Polygons (areas)'
      'Only Points (markers)'
      'Only Multipoints')
  end
  object btnCancel: TButton
    Left = 134
    Top = 224
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 46
    Top = 224
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object edtQuery: TEdit
    Left = 11
    Top = 192
    Width = 230
    Height = 21
    TabOrder = 5
  end
end
