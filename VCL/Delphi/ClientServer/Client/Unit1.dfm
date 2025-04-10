object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'ClientServer:Client - TatukGIS DK11 Sample'
  ClientHeight = 466
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
  DesignSize = (
    592
    466)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 9
    Top = 13
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object Label3: TLabel
    Left = 165
    Top = 13
    Width = 19
    Height = 13
    Caption = 'Port'
  end
  object Label4: TLabel
    Tag = 99
    Left = 9
    Top = 45
    Width = 52
    Height = 13
    Caption = 'Commands'
    Enabled = False
  end
  object Image1: TImage
    Left = 8
    Top = 168
    Width = 329
    Height = 201
  end
  object edtHost: TEdit
    Left = 38
    Top = 9
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edtPort: TEdit
    Left = 194
    Top = 9
    Width = 41
    Height = 21
    TabOrder = 1
    Text = '9099'
  end
  object btnConnect: TButton
    Left = 248
    Top = 5
    Width = 89
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object btnDisconnect: TButton
    Left = 343
    Top = 5
    Width = 89
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 3
    OnClick = btnDisconnectClick
  end
  object cboCommands: TComboBox
    Tag = 99
    Left = 73
    Top = 40
    Width = 168
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 4
    Text = 'Date'
    Items.Strings = (
      'Draw'
      'ZoomIn'
      'ZoomOut'
      'Quit')
  end
  object btnSendCommand: TButton
    Tag = 99
    Left = 248
    Top = 38
    Width = 89
    Height = 25
    Caption = 'Send command'
    Enabled = False
    TabOrder = 5
    OnClick = btnSendCommandClick
  end
  object memMessages: TMemo
    Left = 8
    Top = 72
    Width = 577
    Height = 89
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 6
    WordWrap = False
  end
  object IdTCPClient: TIdTCPClient
    OnDisconnected = IdTCPClientDisconnected
    OnConnected = IdTCPClientConnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = 0
    Left = 452
    Top = 4
  end
end
