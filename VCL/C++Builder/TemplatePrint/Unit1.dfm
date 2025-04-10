object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'TemplatePrint - TatukGIS DK11 Sample'
  ClientHeight = 463
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 145
    Top = 28
    Height = 416
    ExplicitHeight = 426
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 585
    Height = 28
    ButtonWidth = 35
    Images = ImageList1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnFullExtent: TToolButton
      Left = 0
      Top = 0
      Cursor = crHandPoint
      Hint = 'Full Extent'
      Caption = 'btnFullExtent'
      ImageIndex = 0
      OnClick = btnFullExtentClick
    end
    object ToolButton2: TToolButton
      Left = 35
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      Down = True
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnZoom: TToolButton
      Left = 43
      Top = 0
      Cursor = crHandPoint
      Hint = 'Zoom Mode'
      Caption = 'btnZoom'
      Grouped = True
      ImageIndex = 1
      Style = tbsCheck
      OnClick = btnZoomClick
    end
    object btnDrag: TToolButton
      Left = 78
      Top = 0
      Cursor = crHandPoint
      Hint = 'Drag Mode'
      Caption = 'btnDrag'
      Grouped = True
      ImageIndex = 2
      Style = tbsCheck
      OnClick = btnDragClick
    end
    object ToolButton1: TToolButton
      Left = 113
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object Button1: TButton
      Left = 121
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Print'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 444
    Width = 585
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Bevel = pbRaised
        Text = 'Scale :'
        Width = 50
      end
      item
        Text = 'Value'
        Width = 50
      end>
  end
  object GIS_ControlLegend1: TGIS_ControlLegend
    Left = 0
    Top = 28
    Width = 145
    Height = 416
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    DialogOptions.VectorWizardUniqueLimit = 256
    DialogOptions.VectorWizardUniqueSearchLimit = 16384
    Align = alLeft
    ParentColor = False
    TabStop = True
    TabOrder = 2
  end
  object GIS_ControlScale1: TGIS_ControlScale
    Left = 456
    Top = 40
    Width = 129
    Height = 25
    GIS_Viewer = GIS
    Visible = True
    Transparent = False
    UnitsEPSG = 0
    Color = clBtnFace
    TabOrder = 4
  end
  object GIS: TGIS_ViewerWnd
    Left = 148
    Top = 28
    Width = 437
    Height = 416
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 3
    SelectionTransparency = 100
    BorderStyle = bsNone
    AfterPaintEvent = GISAfterPaint
  end
  object GIS_ControlScale2: TGIS_ControlScale
    Left = 464
    Top = 413
    Width = 113
    Height = 25
    GIS_Viewer = GIS
    Visible = True
    Transparent = True
    UnitsEPSG = 0
    Anchors = [akRight, akBottom]
    Color = clBtnFace
    TabOrder = 5
  end
  object GIS_ControlNorthArrow1: TGIS_ControlNorthArrow
    Left = 449
    Top = 34
    Width = 128
    Height = 128
    GIS_Viewer = GIS
    Visible = True
    Style = Rose2
    Transparent = True
    Anchors = [akTop, akRight]
    Color = clBtnFace
    TabOrder = 6
  end
  object GIS_ControlPrintPreviewSimple1: TGIS_ControlPrintPreviewSimple
    Caption = 'Print Preview'
    GIS_Viewer = GIS
    Left = 368
    Top = 40
  end
  object ImageList1: TImageList
    Left = 328
    Top = 32
    Bitmap = {
      494C0101030004000C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B5E7FF008CADFF00ADADAD00000000000000000000000000000000000000
      00000000000084000000FF000000FF000000FF00000084000000840000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000CE310000CE310000CE310000CE310000CE310000CE310000CE3100000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000B5E7
      FF004ABDFF004A73FF007B7B7B00949494000000000000000000000000000000
      00000000000084000000948C2100FF004200FF004200FF004200FF0042008C00
      1800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000630000009C
      3100009C3100FF313100FF313100FF313100FF313100FF313100003100000031
      0000CE3100000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008CD6FF004ABD
      FF004A73FF007B7B7B0094949400525252000000000000000000000000000000
      000000000000000000006BA58400FFFFFF00FFFFFF00FF840000FF8400004218
      5200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000009C310031CE310031CE
      310031CE3100009C310000310000FF633100FF313100FF313100FF313100FF31
      3100FF3131000031000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008CD6FF004ABDFF004A73
      FF007B7B7B0094949400636363007B7B7B000000000000000000000000000000
      0000000000007B8C7B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6005A6B
      5A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000063FF310063FF310031CE
      310031CE3100009C310000310000FF633100FF633100FF633100FF3131000031
      0000008400000031000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000B5E7FF004ABDFF004A73FF007B7B
      7B0094949400636363007B7B7B00000000000000000000000000000000000000
      000084738400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B5C6
      B5004A294A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031CE3100CEFFCE0063FF310063FF
      310031CE3100009C3100009C3100FF9C0000FF9C000000310000003100000084
      0000008400000084000000633100000000000000000000000000CECECE00C6C6
      C600F7CEA500F7CEA500F7CEA500CECECE00CECECE006B8CFF007B7B7B009494
      9400636363007B7B7B0000000000000000000000000000000000000000000000
      0000B5BDB500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7
      EF005A6B5A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CEFFCE00CEFFCE00CEFFCE0063FF
      3100009C310000630000FF9C0000FF9C0000FF9C000000633100319C3100009C
      31000084000000840000006331000000000000000000C6C6C600FFD6D600FFF7
      D600FFF7D600FFF7D600FFF7D600F7CEA5009494940094949400848484006363
      63007B7B7B00000000000000000000000000000000000000000000000000845A
      8400EFFFEF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF009CB59C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00CEFFCE00CEFFCE0063FF
      3100FFCE3100FFCE3100FF9C0000FF9C0000FF9C000000633100319C3100319C
      310000840000008400000084000000000000CECECE00E7E7E700FFFFFF00FFF7
      D600FFE7B500FFE7B500FFE7B500FFF7D600F7CEA5007B7B7B00848484009494
      94000000000000000000000000000000000000000000000000000000000073A5
      7300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00CEE7CE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFCE00CEFFCE00CEFFCE000063
      0000FFCE3100FFCE3100FFCE3100FFCE31000063310063CE3100CEFFCE00319C
      3100319C3100008400000084000000000000B5B5B500FFFFD600F7F7F700FFE7
      B500FFE7B500FFF7D600FFFFD600FFF7D600FFF7D600A5A5A500A5A5A5000000
      000000000000000000000000000000000000000000000000000039423900FFFF
      FF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00DEEFDE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFCE0031CE3100FFFF
      3100FFFF3100FFCE3100FFCE3100FFCE3100FFCE310000633100FF6331000084
      0000319C3100319C31000084000000000000FFAD8C00FFFFD600FFE7B500FFF7
      D600FFFFD600FFFFD600FFFFD600FFFFD600FFFFD600FFAD8C006B6B6B000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000010001000FFFFFF00F7F7F700FFFFFF00F7F7F700F7F7F700A5A5
      A500E7F7E7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F7CEA500FFFFFF00FFFF3100FFFF
      310000633100FFCE3100FFCE3100FFFF310000633100FFCE310000310000FF63
      3100CEFFCE0063CE3100009C310000000000F7CEA500FFE7B500FFE7B500FFF7
      D600FFFFD600FFFFD600FFFFFF00FFFFD600FFFFD600F7CEA500525252000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000008000800FFFFFF008C8C8C00F7F7F7006B6B6B00EFEFEF004242
      4200EFFFEF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F7CEA500FFFFFF00FFFF31000063
      3100009C3100FF9C0000FFCE3100FFCE3100FFCE3100FFCE310031CE31000031
      0000FF633100008400000084000000000000F7CEA500FFF7D600FFE7B500FFFF
      D600FFFFD600FFFFFF00FFFFFF00FFFFFF00FFFFD600B5B5B500525252000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000008000800FFFFFF0073737300FFFFFF0000000000F7F7F7005252
      5200EFFFEF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0063FF310063FF
      3100009C3100009C3100FF9C0000FFCE3100FFCE3100FFCE3100FFCE3100FF63
      3100FF633100FF633100000000000000000094949400F7CEA500FFF7D600FFF7
      D600FFFFD600FFFFD600FFFFFF00FFFFFF00FFF7D6007B7B7B00636363000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000008000800FFFFFF0073737300FFFFFF0052525200F7F7F7005252
      5200E7FFE7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CEFFCE00CEFF
      CE0031CE310031CE3100009C3100FF9C000000633100FF633100FF9C0000FF9C
      0000FF6331000000000000000000000000000000000094949400F7CEA500FFF7
      D600FFFFD600FFFFD600FFFFD600FFF7D6008484840052525200949494000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF007B7B7B00FFFFFF0052525200F7F7F7003131
      3100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000CEFF
      CE00CEFFCE0063FF310031CE310031CE3100009C3100009C310000633100FF63
      3100FF63310000000000000000000000000000000000000000007B7B7B009494
      9400FFAD8C00B5B5B500A5A5A500636363005252520094949400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000006BAD6B00636B6300FFFFFF004A634A00FFFFFF002118
      2100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000031CE310031CE3100FFFFFF0063FF310063FF310031CE3100009C31000000
      0000000000000000000000000000000000000000000000000000000000009494
      94006B6B6B0052525200525252006B6B6B009494940000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000310831003142310000000000214221000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FC3FFFF1F80F0000E00FFFE0F80F0000
      C007FFC0FC0F00008003FF80F80F00008001FF01F00700000001C003F0070000
      00008007E00300000000000FE00300000000001FC00300000000001FE8030000
      0001001FF80300000001001FF80300008001001FF8030000C003801FF8070000
      E007C03FFC0F0000F01FE07FFE5F000000000000000000000000000000000000
      000000000000}
  end
end
