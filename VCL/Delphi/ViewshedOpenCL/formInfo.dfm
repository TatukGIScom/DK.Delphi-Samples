object frmInfo: TfrmInfo
  Left = 0
  Top = 0
  Caption = 'frmInfo'
  ClientHeight = 305
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    457
    305)
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 374
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 8
    TabOrder = 0
  end
  object mmInfo: TMemo
    Left = 8
    Top = 8
    Width = 441
    Height = 258
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'mmInfo')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = False
  end
end
