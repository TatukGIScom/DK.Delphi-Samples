object Form1: TForm1
  Left = 200
  Top = 120
  Caption = 'DynamicAggregation - TatukGIS DK11 Sample'
  ClientHeight = 473
  ClientWidth = 981
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    981
    473)
  PixelsPerInch = 96
  TextHeight = 13
  object GIS: TGIS_ViewerWnd
    Left = 199
    Top = 8
    Width = 774
    Height = 457
    Cursor = 18
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
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    Mode = Zoom
    BorderStyle = bsNone
  end
  object pMenu: TPanel
    Left = 8
    Top = 8
    Width = 185
    Height = 457
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 1
    object lblMethod: TLabel
      Left = 8
      Top = 8
      Width = 98
      Height = 13
      Caption = 'Aggregation method:'
    end
    object lblRadius: TLabel
      Left = 8
      Top = 54
      Width = 36
      Height = 13
      Caption = 'Radius:'
    end
    object lblThreshhold: TLabel
      Left = 9
      Top = 100
      Width = 56
      Height = 13
      Caption = 'Threshhold:'
    end
    object cbxMethod: TComboBox
      Left = 8
      Top = 27
      Width = 169
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbxMethodChange
    end
    object cbxRadius: TComboBox
      Left = 9
      Top = 73
      Width = 168
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbxRadiusChange
      Items.Strings = (
        '5 pt'
        '10 pt'
        '20 pt'
        '40 pt'
        '80 pt')
    end
    object cbxThreshhold: TComboBox
      Left = 8
      Top = 119
      Width = 168
      Height = 21
      Style = csDropDownList
      TabOrder = 2
      OnChange = cbxThreshholdChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '5'
        '10')
    end
  end
end
