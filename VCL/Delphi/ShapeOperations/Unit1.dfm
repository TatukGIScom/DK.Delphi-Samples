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
  DesignSize = (
    704
    574)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 688
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    object lblSelected: TLabel
      Left = 183
      Top = 10
      Width = 3
      Height = 13
    end
    object rbRotate: TRadioButton
      Left = 8
      Top = 8
      Width = 57
      Height = 17
      Caption = 'Rotate'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbRotateClick
    end
    object rbScale: TRadioButton
      Left = 71
      Top = 8
      Width = 50
      Height = 17
      Caption = 'Scale'
      TabOrder = 1
      OnClick = rbScaleClick
    end
    object rbMove: TRadioButton
      Left = 127
      Top = 8
      Width = 50
      Height = 17
      Caption = 'Move'
      TabOrder = 2
      OnClick = rbMoveClick
    end
  end
  object GIS: TGIS_ViewerWnd
    Left = 8
    Top = 47
    Width = 688
    Height = 519
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
    TabOrder = 1
    DelayedUpdate = 700
    ProgressiveUpdate = 2500
    BorderStyle = bsNone
    OnMouseMove = GISMouseMove
    OnMouseUp = GISMouseUp
  end
end
