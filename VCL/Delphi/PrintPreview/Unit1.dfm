object Form1: TForm1
  Left = 200
  Top = 120
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PrintPreview - TatukGIS DK11 Sample'
  ClientHeight = 488
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
  object lbPrintTitle: TLabel
    Left = 415
    Top = 40
    Width = 43
    Height = 13
    Alignment = taRightJustify
    Caption = 'Print title:'
  end
  object lbPrintSubtitle: TLabel
    Left = 414
    Top = 112
    Width = 60
    Height = 13
    Alignment = taRightJustify
    Caption = 'Print subtitle:'
  end
  object GIS: TGIS_ViewerWnd
    Left = 192
    Top = 40
    Width = 217
    Height = 169
    Cursor = 15
    CursorForDrag = crDefault
    CursorForEdit = crDefault
    CursorForSelect = crDefault
    CursorForUserDefined = crDefault
    CursorForZoom = crDefault
    CursorForZoomEx = crDefault
    CursorForCameraPosition = crDefault
    CursorForCameraRotation = crDefault
    CursorForCameraXYZ = crDefault
    CursorForCameraXY = crDefault
    CursorForCameraZoom = crDefault
    CursorForSunPosition = crDefault
    CursorFor3DSelect = crDefault
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
  object GIS_ControlLegend1: TGIS_ControlLegend
    Left = 8
    Top = 40
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 592
    Height = 29
    ButtonHeight = 25
    Caption = 'ToolBar1'
    TabOrder = 2
    object Button2: TButton
      Left = 0
      Top = 0
      Width = 193
      Height = 25
      Caption = 'TGIS_ControlPrintPreviewSimple'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 193
      Top = 0
      Width = 193
      Height = 25
      Caption = 'TGIS_ControlPrintPreview'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object edPrintTitle: TEdit
    Left = 416
    Top = 56
    Width = 169
    Height = 21
    TabOrder = 3
    Text = 'Title'
    OnChange = edPrintTitleChange
  end
  object edPrintSubTitle: TEdit
    Left = 416
    Top = 128
    Width = 169
    Height = 21
    TabOrder = 4
    Text = 'Subtitle'
    OnChange = edPrintSubTitleChange
  end
  object btTitleFont: TButton
    Left = 416
    Top = 80
    Width = 67
    Height = 21
    Hint = 'define title font'
    Caption = 'Font'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btTitleFontClick
  end
  object btSubTitleFont: TButton
    Left = 416
    Top = 160
    Width = 67
    Height = 21
    Hint = 'define subtitle font'
    Caption = 'Font'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    OnClick = btSubTitleFontClick
  end
  object chkStandardPrint: TCheckBox
    Left = 416
    Top = 192
    Width = 105
    Height = 17
    Caption = 'Standard print'
    TabOrder = 6
    OnClick = chkStandardPrintClick
  end
  object GIS_ControlPrintPreview1: TGIS_ControlPrintPreview
    Left = 8
    Top = 215
    Width = 576
    Height = 257
    GIS_Viewer = GIS
    BevelOuter = bvNone
    Color = clGray
    TabOrder = 8
  end
  object dlgFontT: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdApplyButton]
    OnApply = dlgFontTApply
    Left = 488
    Top = 80
  end
  object dlgFontST: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    OnApply = dlgFontSTApply
    Left = 488
    Top = 152
  end
  object GIS_ControlPrintPreviewSimple1: TGIS_ControlPrintPreviewSimple
    Caption = 'Print Preview'
    GIS_Viewer = GIS
    Left = 16
    Top = 176
  end
end
