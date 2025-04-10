object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Split by Arc - TatukGIS DK11 Sample'
  ClientHeight = 461
  ClientWidth = 583
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
  object paLeft: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 442
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 0
    ExplicitHeight = 445
    object btnLine: TButton
      Left = 8
      Top = 40
      Width = 121
      Height = 25
      Caption = 'New line / Create line'
      TabOrder = 0
      OnClick = btnLineClick
    end
    object btnSplit: TButton
      Left = 8
      Top = 80
      Width = 121
      Height = 25
      Caption = 'Split'
      Enabled = False
      TabOrder = 1
      OnClick = btnSplitClick
    end
    object gbAfterSplit: TGroupBox
      Left = 8
      Top = 120
      Width = 169
      Height = 57
      Caption = ' Shapes after split : '
      TabOrder = 2
      object lbInfo: TLabel
        Left = 12
        Top = 32
        Width = 9
        Height = 13
        Caption = '...'
      end
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 185
    Top = 0
    Width = 398
    Height = 442
    Cursor = 19
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    RestrictedDrag = False
    SelectionTransparency = 100
    OnMouseDown = GISMouseDown
    OnMouseUp = GISMouseUp
    ExplicitWidth = 399
    ExplicitHeight = 445
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 442
    Width = 583
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Click mouse to add line points.'
    ExplicitTop = 445
    ExplicitWidth = 584
  end
end
