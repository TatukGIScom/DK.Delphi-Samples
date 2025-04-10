object frmHints: TfrmHints
  Left = 548
  Top = 106
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Map hints properties'
  ClientHeight = 182
  ClientWidth = 377
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
  object gbHintsData: TGroupBox
    Left = 0
    Top = 0
    Width = 377
    Height = 145
    Caption = ' Select display hint data : '
    TabOrder = 0
    object lbColor: TLabel
      Left = 296
      Top = 104
      Width = 54
      Height = 13
      Caption = 'Hint color : '
    end
    object cbLayers: TComboBox
      Left = 8
      Top = 24
      Width = 217
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbLayersChange
    end
    object lbFields: TListBox
      Left = 8
      Top = 48
      Width = 217
      Height = 89
      ItemHeight = 13
      TabOrder = 1
    end
    object paColor: TPanel
      Left = 296
      Top = 120
      Width = 73
      Height = 17
      TabOrder = 2
      OnClick = paColorClick
    end
  end
  object chkShow: TCheckBox
    Left = 8
    Top = 160
    Width = 97
    Height = 17
    Caption = 'Show map hints'
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 296
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 208
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 3
  end
  object dlgColor: TColorDialog
    Ctl3D = True
    Left = 240
    Top = 104
  end
end
