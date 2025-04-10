object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Shapes Relations - TatukGIS DK11 Sample'
  ClientHeight = 464
  ClientWidth = 584
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
    Width = 584
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 
      'Use left and right mouse button to select two shapes for relatio' +
      'ns.'
  end
  object paLeft: TPanel
    Left = 0
    Top = 0
    Width = 169
    Height = 445
    Align = alLeft
    TabOrder = 1
    object gbShapes: TGroupBox
      Left = 8
      Top = 8
      Width = 153
      Height = 73
      Caption = ' Shapes  '
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 24
        Width = 61
        Height = 13
        Caption = 'Shape A : '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ShapeA: TLabel
        Left = 72
        Top = 24
        Width = 65
        Height = 13
        Caption = 'Unselected'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object Label3: TLabel
        Left = 8
        Top = 48
        Width = 57
        Height = 13
        Caption = 'Shape B :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ShapeB: TLabel
        Left = 72
        Top = 48
        Width = 65
        Height = 13
        Caption = 'Unselected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 96
      Width = 153
      Height = 233
      Caption = ' Relations between A and B '
      TabOrder = 1
      object Relations: TMemo
        Left = 8
        Top = 16
        Width = 137
        Height = 209
        TabOrder = 0
      end
    end
    object btnCheck: TButton
      Left = 48
      Top = 336
      Width = 75
      Height = 25
      Caption = 'Check'
      TabOrder = 2
      OnClick = btnCheckClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 169
    Top = 0
    Width = 415
    Height = 445
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    SelectionOutlineOnly = True
    SelectionTransparency = 100
    BorderStyle = bsNone
    OnMouseDown = GISMouseDown
  end
end
