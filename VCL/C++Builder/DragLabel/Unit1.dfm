object Form1: TForm1
  Left = 200
  Top = 120
  BiDiMode = bdLeftToRight
  Caption = 'Draggable Labels - TatukGIS DK11 Sample'
  ClientHeight = 463
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = HEBREW_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object StatusBar1: TStatusBar
    Left = 0
    Top = 444
    Width = 584
    Height = 19
    Panels = <>
    ExplicitTop = 445
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 584
    Height = 29
    ButtonHeight = 23
    Caption = 'ToolBar1'
    TabOrder = 1
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 23
      Caption = 'Animate'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 584
    Height = 415
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    IncrementalPaint = False
    RestrictedDrag = False
    SelectionTransparency = 100
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
    ExplicitHeight = 416
  end
end
