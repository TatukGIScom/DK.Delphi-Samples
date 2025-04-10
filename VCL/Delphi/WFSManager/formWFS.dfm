object frmWFS: TfrmWFS
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'WFS Manager'
  ClientHeight = 539
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    588
    539)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 26
    Height = 13
    Caption = 'URL :'
  end
  object cbURL: TComboBox
    Left = 40
    Top = 8
    Width = 465
    Height = 21
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    Text = 
      'http://geodata.nationaalgeoregister.nl/aan/wfs?version=1.0.0&req' +
      'uest=GetCapabilities'
    TextHint = 
      'http://geodata.nationaalgeoregister.nl/aan/wfs?version=1.0.0&req' +
      'uest=GetCapabilities'
    Items.Strings = (
      
        'http://demo.mapserver.org/cgi-bin/wfs?SERVICE=WFS&VERSION=1.0.0&' +
        'REQUEST=GetCapabilities')
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 35
    Width = 571
    Height = 222
    Caption = 'Layers'
    TabOrder = 1
    object tvLayers: TTreeView
      Left = 8
      Top = 16
      Width = 273
      Height = 195
      HideSelection = False
      Indent = 19
      ParentShowHint = False
      PopupMenu = pm1
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
      OnChange = tvLayersChange
    end
    object memLayerInfo: TMemo
      Left = 287
      Top = 16
      Width = 274
      Height = 195
      Color = clMenu
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object btnLoadService: TButton
    Left = 511
    Top = 6
    Width = 68
    Height = 25
    Caption = 'Get layers'
    TabOrder = 2
    OnClick = btnLoadServiceClick
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 263
    Width = 572
    Height = 234
    Caption = 'Options'
    TabOrder = 3
    object Label2: TLabel
      Left = 15
      Top = 24
      Width = 55
      Height = 13
      Caption = 'Parameters'
    end
    object Label4: TLabel
      Left = 336
      Top = 56
      Width = 91
      Height = 13
      Caption = 'Coordinate System'
    end
    object Label5: TLabel
      Left = 440
      Top = 24
      Width = 35
      Height = 13
      Caption = 'Version'
    end
    object eParams: TEdit
      Left = 76
      Top = 19
      Width = 357
      Height = 21
      Hint = 'Additional parameters to query'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object cbCRS: TComboBox
      Left = 335
      Top = 75
      Width = 216
      Height = 21
      TabOrder = 1
    end
    object GroupBox3: TGroupBox
      Left = 15
      Top = 46
      Width = 314
      Height = 59
      Caption = 'GML Settings'
      TabOrder = 2
      object Label3: TLabel
        Left = 12
        Top = 26
        Width = 69
        Height = 13
        Caption = 'Output format'
      end
      object cbReverseXY: TCheckBox
        Left = 221
        Top = 24
        Width = 87
        Height = 17
        Hint = 
          'Check the '#8220'Reverse X/Y'#8221' box to force reading the coordinates in ' +
          'reverse order. This is mostly used for data using the EPSG 4326 ' +
          'projection as urn:ogc:def:crs:EPSG::4326 where the order of coor' +
          'dinates is latitude then longitude.'
        Caption = 'Reverse X/Y'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object cbDataFormats: TComboBox
        Left = 87
        Top = 21
        Width = 128
        Height = 21
        Hint = 
          'The Geography Markup Language version can be either GML2 or GML3' +
          '.'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
    end
    object GroupBox4: TGroupBox
      Left = 15
      Top = 111
      Width = 536
      Height = 106
      Caption = 'Filtering'
      TabOrder = 3
      object lblXmin: TLabel
        Left = 370
        Top = 37
        Width = 22
        Height = 13
        Caption = 'XMin'
        Enabled = False
      end
      object lblXMax: TLabel
        Left = 490
        Top = 37
        Width = 26
        Height = 13
        Caption = 'XMax'
        Enabled = False
      end
      object lblYMax: TLabel
        Left = 426
        Top = 61
        Width = 26
        Height = 13
        Caption = 'YMax'
        Enabled = False
      end
      object lblYMin: TLabel
        Left = 430
        Top = 17
        Width = 22
        Height = 13
        Caption = 'YMin'
        Enabled = False
      end
      object cbMaxFeatures: TCheckBox
        Left = 9
        Top = 44
        Width = 121
        Height = 17
        Hint = 'Maximum limit on the number of features returned.'
        Caption = 'Maximum Features'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = cbMaxFeaturesClick
      end
      object seMaxFeatures: TEdit
        Left = 128
        Top = 42
        Width = 65
        Height = 21
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Text = '100'
      end
      object cbBBoxFIlter: TCheckBox
        Left = 221
        Top = 22
        Width = 113
        Height = 17
        Hint = 'Spatial bounding-box filter.'
        Caption = 'Bounding-Box Filter'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = cbBBoxFIlterClick
      end
      object eYMin: TEdit
        Left = 412
        Top = 30
        Width = 60
        Height = 21
        Enabled = False
        TabOrder = 3
      end
      object eXMax: TEdit
        Left = 472
        Top = 52
        Width = 60
        Height = 21
        Enabled = False
        TabOrder = 4
      end
      object eXMin: TEdit
        Left = 353
        Top = 52
        Width = 60
        Height = 21
        Enabled = False
        TabOrder = 5
      end
      object eYMax: TEdit
        Left = 412
        Top = 75
        Width = 60
        Height = 21
        Enabled = False
        TabOrder = 6
      end
      object cbStartIndex: TCheckBox
        Left = 9
        Top = 18
        Width = 97
        Height = 17
        Hint = 'Start index of the features returned.'
        Caption = 'Start Index'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        OnClick = cbStartIndexClick
      end
      object seStartIndex: TEdit
        Left = 128
        Top = 16
        Width = 65
        Height = 21
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
        Text = '1'
      end
      object chkClipVisibleExtent: TCheckBox
        Left = 231
        Top = 53
        Width = 120
        Height = 17
        Caption = 'Clip by visible extent'
        Enabled = False
        TabOrder = 9
        OnClick = chkClipVisibleExtentClick
      end
    end
    object cbVersion: TComboBox
      Left = 480
      Top = 19
      Width = 73
      Height = 21
      TabOrder = 4
      Items.Strings = (
        '1.0.0'
        '1.1.0'
        '2.0.0')
    end
  end
  object btnAddLayer: TButton
    Left = 214
    Top = 506
    Width = 75
    Height = 25
    Anchors = [akLeft, akRight]
    Caption = 'Add layer'
    TabOrder = 4
    OnClick = btnAddLayerClick
  end
  object btnCancel: TButton
    Left = 295
    Top = 506
    Width = 75
    Height = 25
    Anchors = [akLeft, akRight]
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object btnOpenURL: TButton
    Left = 8
    Top = 506
    Width = 75
    Height = 25
    Hint = 'Open a layer using direct URL path '
    Caption = 'Open URL'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = btnOpenURLClick
  end
  object pm1: TPopupMenu
    Left = 496
    Top = 504
    object Locateonmap1: TMenuItem
      Caption = 'Locate on map'
      OnClick = Locateonmap1Click
    end
    object OpenMetadata1: TMenuItem
      Caption = 'Open Metadata'
      OnClick = OpenMetadata1Click
    end
  end
end
