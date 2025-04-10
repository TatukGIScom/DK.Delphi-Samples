object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'CGM Viewer - TatukGIS DK11 Sample'
  ClientHeight = 464
  ClientWidth = 583
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 445
    Width = 583
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitWidth = 584
  end
  object GIS: TGIS_ViewerWnd
    Left = 161
    Top = 29
    Width = 422
    Height = 416
    Cursor = 16
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    IncrementalPaint = False
    SelectionTransparency = 100
    ExplicitWidth = 423
  end
  object Panel1: TPanel
    Left = 0
    Top = 29
    Width = 161
    Height = 416
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object DirectoryListBox1: TDirectoryListBox
      Left = 0
      Top = 0
      Width = 161
      Height = 105
      Align = alTop
      TabOrder = 0
      OnChange = DirectoryListBox1Change
    end
    object FileList: TFileListBox
      Left = 0
      Top = 105
      Width = 161
      Height = 311
      Cursor = crHandPoint
      Align = alClient
      ItemHeight = 13
      Mask = '*.cgm'
      TabOrder = 1
      OnClick = FileListClick
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 583
    Height = 29
    ButtonWidth = 97
    Caption = 'ToolBar1'
    Color = clWhite
    ParentColor = False
    TabOrder = 3
    ExplicitWidth = 584
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 281
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object Button1: TButton
      Left = 281
      Top = 0
      Width = 120
      Height = 22
      Cursor = crHandPoint
      Caption = 'Rotate symbol'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
