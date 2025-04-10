object Form1: TForm1
  Left = 200
  Top = 120
  BorderIcons = [biSystemMenu]
  Caption = 'GPS Interface - TatukGIS DK11 Sample'
  ClientHeight = 464
  ClientWidth = 584
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
    Width = 584
    Height = 33
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    DesignSize = (
      584
      33)
    object cbxCom: TComboBox
      Left = 0
      Top = 0
      Width = 89
      Height = 21
      Style = csDropDownList
      Anchors = [akTop]
      TabOrder = 0
      OnChange = cbxComChange
      Items.Strings = (
        'Com 1'
        'Com 2'
        'Com 3'
        'Com 4'
        'Com 4'
        'Com 5'
        'Com 6'
        'Com 7'
        'Com 8'
        'Com 9'
        'Com 10')
    end
    object cbxBaud: TComboBox
      Left = 89
      Top = 0
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbxBaudChange
      Items.Strings = (
        '1200'
        '2400'
        '4800'
        '9600'
        '19200')
    end
  end
  object GPS: TGIS_GpsNmea
    Left = 0
    Top = 33
    Width = 233
    Height = 431
    Com = 1
    BaudRate = 4800
    Align = alLeft
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 233
    Top = 33
    Width = 351
    Height = 431
    Align = alClient
    TabOrder = 2
  end
end
