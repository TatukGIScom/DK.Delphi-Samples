object Form1: TForm1
  Left = 504
  Top = 107
  HelpContext = 410000
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 1
  Caption = 'Export to image'
  ClientHeight = 408
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object btnSave: TButton
    Left = 190
    Top = 375
    Width = 79
    Height = 25
    Action = actSave
    ModalResult = 1
    TabOrder = 2
  end
  object gbFile: TGroupBox
    Left = 8
    Top = 204
    Width = 465
    Height = 49
    Caption = '&File'
    TabOrder = 0
    object edtFile: TEdit
      Left = 14
      Top = 19
      Width = 409
      Height = 21
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object btnSelectFile: TButton
      Left = 429
      Top = 17
      Width = 25
      Height = 25
      Hint = 'Select image'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnSelectFileClick
    end
  end
  object gbCompression: TGroupBox
    Left = 8
    Top = 256
    Width = 465
    Height = 113
    Caption = '&Options'
    TabOrder = 1
    object lbFormat: TLabel
      Left = 11
      Top = 24
      Width = 35
      Height = 13
      Alignment = taRightJustify
      Caption = 'Format '
    end
    object Label1: TLabel
      Left = 11
      Top = 49
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = 'Extent'
    end
    object cbType: TComboBox
      Left = 50
      Top = 21
      Width = 97
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object rbExtentMap: TRadioButton
      Left = 50
      Top = 48
      Width = 56
      Height = 17
      Caption = 'Full'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbExtentVisible: TRadioButton
      Left = 50
      Top = 68
      Width = 81
      Height = 18
      Caption = 'Visible'
      TabOrder = 2
    end
    object gbSize: TGroupBox
      Left = 288
      Top = 8
      Width = 170
      Height = 97
      Caption = '&Resolution'
      TabOrder = 3
      object rbQbest: TRadioButton
        Left = 7
        Top = 24
        Width = 90
        Height = 17
        Caption = 'best quality'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbQdoc: TRadioButton
        Left = 7
        Top = 42
        Width = 90
        Height = 17
        Caption = 'for document'
        TabOrder = 1
      end
      object rbQweb: TRadioButton
        Left = 7
        Top = 61
        Width = 87
        Height = 17
        Caption = 'for Web'
        TabOrder = 2
      end
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = -1
    Width = 465
    Height = 202
    Caption = 'Viewer'
    TabOrder = 3
    object GIS: TGIS_ViewerWnd
      Left = 7
      Top = 16
      Width = 390
      Height = 178
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
      Ctl3D = True
      ParentColor = False
      ParentCtl3D = False
      TabOrder = 0
      KeepScale = False
      DelayedUpdate = 700
      ProgressiveUpdate = 2500
      SelectionTransparency = 100
      Color = clWhite
      BorderStyle = bsNone
    end
    object rbImage: TRadioButton
      Left = 402
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Image'
      TabOrder = 1
      OnClick = rbImageClick
    end
    object rbGrid: TRadioButton
      Left = 402
      Top = 47
      Width = 113
      Height = 17
      Caption = 'Grid'
      TabOrder = 2
      OnClick = rbGridClick
    end
  end
  object actlMain: TActionList
    Left = 280
    Top = 96
    object actSave: TAction
      Caption = 'Export'
      OnExecute = actSaveExecute
    end
  end
  object dlgSaveGrid: TSaveDialog
    DefaultExt = 'FLT'
    Filter = 
      'Arc/Info Binary Grid (*.flt)|*.FLT|Arc/Info ASCII Grid (*.grd)|*' +
      '.GRD|TatukGIS PixelStore (*.ttkps)|*.TTKPS'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Export to grid...'
    Left = 344
    Top = 144
  end
  object dlgSaveImage: TSaveDialog
    DefaultExt = 'jpg'
    Filter = 
      'JPEG File Interchange Format (*.jpg)|*.JPG|Portable Network Grap' +
      'hic (*.png)|*.PNG|Tag Image File Format (*.tif;*.tiff)|*.TIF;*.T' +
      'IFF|Window Bitmap (*.bmp)|*.BMP|TatukGIS PixelStore (*.ttkps)|*.' +
      'TTKPS'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofCreatePrompt, ofEnableSizing]
    Title = 'Export to image...'
    Left = 344
    Top = 95
  end
end
