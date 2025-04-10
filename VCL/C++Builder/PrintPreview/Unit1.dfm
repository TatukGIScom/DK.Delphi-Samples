object Form1: TForm1
  Left = 200
  Top = 120
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PrintPreview  - TatukGIS DK11 Sample'
  ClientHeight = 470
  ClientWidth = 591
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
  object lbPrintTitle: TLabel
    Left = 418
    Top = 40
    Width = 46
    Height = 13
    Alignment = taRightJustify
    Caption = 'Print title :'
  end
  object lbPrintSubTitle: TLabel
    Left = 417
    Top = 120
    Width = 63
    Height = 13
    Alignment = taRightJustify
    Caption = 'Print subtitle :'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 591
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 0
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 185
      Height = 22
      Caption = 'TGIS_ControlPrintPreviewSimple'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 185
      Top = 0
      Width = 200
      Height = 22
      Caption = 'TGIS_ControlPrintPreview'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object GIS_ControlLegend1: TGIS_ControlLegend
    Left = 8
    Top = 32
    Width = 177
    Height = 169
    GIS_Viewer = GIS
    Mode = Layers
    Options = [AllowMove, AllowActive, AllowExpand, AllowParams, AllowSelect, ShowSubLayers, AllowParamsVisible]
    ReverseOrder = False
    DialogOptions.VectorWizardUniqueLimit = 256
    DialogOptions.VectorWizardUniqueSearchLimit = 16384
    ParentColor = False
    TabStop = True
    TabOrder = 1
  end
  object GIS: TGIS_ViewerWnd
    Left = 192
    Top = 32
    Width = 217
    Height = 169
    Cursor = 16
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 2
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
  object GIS_ControlPrintPreview1: TGIS_ControlPrintPreview
    Left = 8
    Top = 216
    Width = 569
    Height = 249
    GIS_Viewer = GIS
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 3
  end
  object chkStandardPrint: TCheckBox
    Left = 416
    Top = 192
    Width = 97
    Height = 17
    Caption = 'Standard print'
    TabOrder = 4
    OnClick = chkStandardPrintClick
  end
  object btnTitleFont: TButton
    Left = 416
    Top = 80
    Width = 75
    Height = 25
    Hint = 'Define title font'
    Caption = 'Font'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btnTitleFontClick
  end
  object btnSubTitleFont: TButton
    Left = 416
    Top = 160
    Width = 75
    Height = 25
    Hint = 'Define subtitle font'
    Caption = 'Font'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = btnSubTitleFontClick
  end
  object edPrintTitle: TEdit
    Left = 416
    Top = 56
    Width = 153
    Height = 21
    TabOrder = 7
    Text = 'Title'
    OnChange = edPrintTitleChange
  end
  object edPrintSubTitle: TEdit
    Left = 416
    Top = 136
    Width = 153
    Height = 21
    TabOrder = 8
    Text = 'Subtitle'
    OnChange = edPrintSubTitleChange
  end
  object GIS_ControlPrintPreviewSimple1: TGIS_ControlPrintPreviewSimple
    Caption = 'Print Preview'
    GIS_Viewer = GIS
    Left = 152
    Top = 168
  end
  object dlgFontT: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdApplyButton]
    OnApply = dlgFontTApply
    Left = 496
    Top = 80
  end
  object dlgFontST: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdApplyButton]
    OnApply = dlgFontSTApply
    Left = 496
    Top = 160
  end
end
