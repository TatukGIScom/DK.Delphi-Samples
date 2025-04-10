object frmMain: TfrmMain
  Left = 200
  Top = 120
  Caption = 'GPS Tracker (NMEA) - TatukGIS DK11 Sample'
  ClientHeight = 382
  ClientWidth = 770
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 770
    Height = 33
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    object ToolButton6: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 5
      Style = tbsSeparator
    end
    object btnSave: TSpeedButton
      Left = 8
      Top = 0
      Width = 23
      Height = 21
      Action = actSave
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF00C0C0C00000FFFF00FF000000C0C0C000FFFF0000FFFFFF00DADADADADADA
        DADAAD0000000000000DD03300000088030AA03300000088030DD03300000088
        030AA03300000000030DD03333333333330AA03300000000330DD03088888888
        030AA03088888888030DD03088888888030AA03088888888030DD03088888888
        000AA03088888888080DD00000000000000AADADADADADADADAD}
      Layout = blGlyphTop
    end
    object ToolButton1: TToolButton
      Left = 31
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 6
      Style = tbsSeparator
    end
    object btnRecord: TSpeedButton
      Left = 39
      Top = 0
      Width = 23
      Height = 21
      Action = actRecord
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000010000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
        0000377777777777777703030303030303037F7F7F7F7F7F7F7F000000000000
        00007777777777777777933393303933337073F37F37F73F3377393393303393
        379037FF7F37F37FF777379793303379793037777337F3777737339933303339
        93303377F3F7F3F77F3733993930393993303377F737F7377FF7399993303399
        999037777337F377777793993330333393307377FF37F3337FF7333993303333
        993033377F37F33377F7333993303333993033377337F3337737333333303333
        33303FFFFFF7FFFFFFF700000000000000007777777777777777030303030303
        03037F7F7F7F7F7F7F7F00000000000000007777777777777777}
      NumGlyphs = 2
    end
    object ToolButton4: TToolButton
      Left = 62
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object cbxCom: TComboBox
      Left = 70
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
      Left = 137
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
  object GIS: TGIS_ViewerWnd
    Left = 265
    Top = 33
    Width = 505
    Height = 349
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    SelectionTransparency = 100
    OnMouseMove = GISMouseMove
  end
  object Panel1: TPanel
    Left = 0
    Top = 33
    Width = 265
    Height = 349
    Align = alLeft
    TabOrder = 2
    object GPS: TGIS_GpsNmea
      Left = 1
      Top = 42
      Width = 263
      Height = 176
      Com = 1
      BaudRate = 4800
      PositionEvent = GPSPosition
      Align = alTop
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edtPoint: TEdit
      Left = 16
      Top = 224
      Width = 185
      Height = 21
      Hint = 'Type point name here and click Add'
      Enabled = False
      TabOrder = 1
      Text = 'Type name here'
    end
    object btnAdd: TButton
      Left = 72
      Top = 256
      Width = 75
      Height = 25
      Action = actAdd
      Caption = '&Add'
      Enabled = False
      TabOrder = 2
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 263
      Height = 41
      Align = alTop
      TabOrder = 3
    end
  end
  object actList: TActionList
    OnUpdate = actListUpdate
    Left = 176
    Top = 288
    object actAdd: TAction
      Hint = 'Add a new named point'
      ShortCut = 16449
      OnExecute = actAddExecute
    end
    object actRecord: TAction
      Hint = 'Turn on/off route recording'
      ShortCut = 16466
      OnExecute = actRecordExecute
    end
    object actSave: TAction
      Hint = 'Save the data'
      ShortCut = 16467
      OnExecute = actSaveExecute
    end
  end
end
