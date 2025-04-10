object Form1: TForm1
  Left = 200
  Top = 120
  BorderStyle = bsToolWindow
  Caption = 'ClientServer:Server - TatukGIS DK11 Sample'
  ClientHeight = 178
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
  OnDestroy = FormDestroy
  DesignSize = (
    592
    178)
  PixelsPerInch = 96
  TextHeight = 13
  object memMessages: TMemo
    Left = 8
    Top = 8
    Width = 577
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Waiting for connection on 127.0.0.1:9099')
    ReadOnly = True
    TabOrder = 0
    WordWrap = False
  end
  object IdTCPServer: TIdTCPServer
    Active = True
    Bindings = <
      item
        IP = '127.0.0.1'
        Port = 9099
      end>
    DefaultPort = 0
    OnConnect = IdTCPServerConnect
    OnExecute = IdTCPServerExecute
    Left = 8
    Top = 20
  end
end
