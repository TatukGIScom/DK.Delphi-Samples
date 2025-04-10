object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Shape transform - TatukGIS DK11 Sample'
  ClientHeight = 574
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblSelected: TLabel
    Left = 0
    Top = 0
    Width = 704
    Height = 16
    Align = alTop
    Alignment = taCenter
    Caption = 'Select'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 35
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 41
    Width = 704
    Height = 533
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    SelectionTransparency = 50
    BorderStyle = bsNone
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
    OnMouseWheelUp = GISMouseWheelUp
    OnMouseWheelDown = GISMouseWheelDown
  end
  object pgc1: TPageControl
    Left = 0
    Top = 16
    Width = 704
    Height = 25
    ActivePage = ts2
    Align = alTop
    MultiLine = True
    Style = tsFlatButtons
    TabOrder = 1
    OnChanging = pgc1Changing
    object ts1: TTabSheet
      Caption = 'Rotate'
    end
    object ts2: TTabSheet
      Caption = 'Scale'
      ImageIndex = 1
    end
    object ts3: TTabSheet
      Caption = 'Move'
      ImageIndex = 2
    end
  end
end
