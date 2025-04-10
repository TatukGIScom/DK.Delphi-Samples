object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Split by Arc - TatukGIS DK11 Sample'
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 454
    Width = 592
    Height = 19
    Panels = <
      item
        Text = 'Click mouse to add line points.'
        Width = 200
      end>
  end
  object paLeft: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 454
    Align = alLeft
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 1
    object btnLine: TButton
      Left = 8
      Top = 24
      Width = 129
      Height = 25
      Caption = 'New Line/ Create line'
      TabOrder = 0
      OnClick = btnLineClick
    end
    object btnSplit: TButton
      Left = 8
      Top = 64
      Width = 129
      Height = 25
      Caption = 'Split shape'
      Enabled = False
      TabOrder = 1
      OnClick = btnSplitClick
    end
    object gboxResult: TGroupBox
      Left = 8
      Top = 104
      Width = 169
      Height = 49
      Caption = 'Shapes after split : '
      Color = clBtnFace
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 2
      object lbInfo: TLabel
        Left = 8
        Top = 24
        Width = 9
        Height = 13
        Caption = '...'
      end
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 185
    Top = 0
    Width = 407
    Height = 454
    Cursor = 19
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    SelectionTransparency = 100
    OnMouseDown = GISMouseDown
    OnMouseUp = GISMouseUp
  end
end
