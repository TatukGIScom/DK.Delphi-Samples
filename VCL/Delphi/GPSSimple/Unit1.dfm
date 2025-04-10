object frmMain: TfrmMain
  Left = 200
  Top = 120
  BorderStyle = bsDialog
  Caption = 'GPS Inteface - TatukGIS DK11 Sample'
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
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 33
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    object cbxCom: TComboBox
      Left = 0
      Top = 0
      Width = 67
      Height = 21
      Hint = 'Select com port'
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbxComChange
      Items.Strings = (
        'Com 1'
        'Com 2'
        'Com 3'
        'Com 4'
        'Com 5'
        'Com 6'
        'Com 7'
        'Com 8'
        'Com 9'
        'Com 10')
    end
    object cbxBaud: TComboBox
      Left = 67
      Top = 0
      Width = 72
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
    Width = 241
    Height = 440
    Com = 1
    BaudRate = 4800
    PositionEvent = GPSPosition
    Align = alLeft
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 241
    Top = 33
    Width = 351
    Height = 440
    Align = alClient
    TabOrder = 2
  end
end
