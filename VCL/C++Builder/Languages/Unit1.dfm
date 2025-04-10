object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'Languages - TatukGIS DK11 Sample'
  ClientHeight = 459
  ClientWidth = 582
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
  object GIS: TGIS_ViewerWnd
    Left = 0
    Top = 29
    Width = 582
    Height = 430
    Cursor = 16
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
    Align = alClient
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    SelectionTransparency = 100
    BorderStyle = bsNone
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 582
    Height = 29
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 1
    object ComboBox1: TComboBox
      Left = 0
      Top = 0
      Width = 145
      Height = 21
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = ComboBox1Change
      Items.Strings = (
        'English'
        'Chinese'
        'Japanese'
        'Arabic'
        'Hebrew'
        'Greek')
    end
  end
end
