object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Tracking Test - TatukGIS DK11 Sample'
  ClientHeight = 463
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 583
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 0
    ExplicitWidth = 584
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 8
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object chkUseLock: TCheckBox
      Left = 16
      Top = 0
      Width = 97
      Height = 22
      Caption = 'Use Lock'
      TabOrder = 0
    end
    object btnAnimate: TButton
      Left = 113
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Animate !'
      TabOrder = 1
      OnClick = btnAnimateClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 583
    Height = 434
    Cursor = 18
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    SelectionTransparency = 100
    ExplicitWidth = 584
    ExplicitHeight = 435
  end
end
