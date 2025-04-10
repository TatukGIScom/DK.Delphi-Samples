object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Select by rectangle - TatukGIS DK11 Sample'
  ClientHeight = 464
  ClientWidth = 586
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
    Top = 445
    Width = 586
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Use left mouse button to select'
  end
  object Memo1: TMemo
    Left = 401
    Top = 29
    Width = 185
    Height = 416
    Align = alRight
    ReadOnly = True
    TabOrder = 1
    ExplicitTop = 0
    ExplicitHeight = 445
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 401
    Height = 416
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    SelectionTransparency = 50
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
    PaintExtraEvent = GISPaintExtraEvent
    ExplicitTop = 0
    ExplicitHeight = 445
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 586
    Height = 29
    ButtonHeight = 26
    Caption = 'ToolBar1'
    TabOrder = 3
    object btnRect: TSpeedButton
      Left = 0
      Top = 0
      Width = 81
      Height = 26
      GroupIndex = 1
      Caption = 'By rectangle'
    end
    object btnCircle: TSpeedButton
      Left = 81
      Top = 0
      Width = 72
      Height = 26
      GroupIndex = 1
      Caption = 'By circle'
    end
  end
end
