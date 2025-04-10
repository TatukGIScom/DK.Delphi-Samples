object FormInfo: TFormInfo
  Left = 783
  Top = 268
  Width = 208
  Height = 241
  Anchors = [akLeft, akTop, akRight, akBottom]
  BorderStyle = bsSizeToolWin
  Caption = 'Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sgrdInfo: TStringGrid
    Left = 0
    Top = 0
    Width = 200
    Height = 207
    Align = alClient
    ColCount = 2
    DefaultColWidth = 80
    DefaultRowHeight = 13
    FixedCols = 0
    RowCount = 31
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -3
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    ColWidths = (
      80
      291)
  end
end
