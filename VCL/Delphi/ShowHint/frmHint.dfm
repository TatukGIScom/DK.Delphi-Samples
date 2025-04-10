object frmHints: TfrmHints
  Left = 508
  Top = 186
  ActiveControl = lbFields
  BorderStyle = bsDialog
  Caption = 'Hints properties'
  ClientHeight = 181
  ClientWidth = 370
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
  object gbSelectData: TGroupBox
    Left = 0
    Top = 0
    Width = 370
    Height = 145
    Align = alTop
    Caption = ' Select display hint data '
    TabOrder = 0
    object lbColor: TLabel
      Left = 304
      Top = 104
      Width = 51
      Height = 13
      Caption = 'Hint color :'
    end
    object cbLayers: TComboBox
      Left = 16
      Top = 32
      Width = 241
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbLayersChange
    end
    object lbFields: TListBox
      Left = 16
      Top = 56
      Width = 241
      Height = 81
      ItemHeight = 13
      TabOrder = 1
    end
    object paColor: TPanel
      Left = 304
      Top = 120
      Width = 57
      Height = 17
      ParentBackground = False
      TabOrder = 2
      OnClick = paColorClick
    end
  end
  object Button1: TButton
    Left = 208
    Top = 152
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 288
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object chkShow: TCheckBox
    Left = 8
    Top = 152
    Width = 97
    Height = 17
    Caption = 'Show map hints'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object dlgColor: TColorDialog
    CustomColors.Strings = (
      'ColorA=FFFFFFFF'
      'ColorB=FFFFFFFF'
      'ColorC=FFFFFFFF'
      'ColorD=FFFFFFFF'
      'ColorE=FFFFFFFF'
      'ColorF=FFFFFFFF'
      'ColorG=FFFFFFFF'
      'ColorH=FFFFFFFF'
      'ColorI=FFFFFFFF'
      'ColorJ=FFFFFFFF'
      'ColorK=FFFFFFFF'
      'ColorL=FFFFFFFF'
      'ColorM=FFFFFFFF'
      'ColorN=FFFFFFFF'
      'ColorO=FFFFFFFF'
      'ColorP=FFFFFFFF')
    Left = 168
    Top = 152
  end
end
