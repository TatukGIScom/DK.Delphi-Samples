object frmWMTS: TfrmWMTS
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'WMTS Manager'
  ClientHeight = 106
  ClientWidth = 681
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lbl5: TLabel
    Left = 8
    Top = 51
    Width = 32
    Height = 13
    Caption = 'Layers'
  end
  object lbl4: TLabel
    Left = 8
    Top = 5
    Width = 37
    Height = 13
    Caption = 'Servers'
  end
  object cbLayers: TComboBox
    Left = 8
    Top = 70
    Width = 505
    Height = 21
    TabOrder = 0
  end
  object btn19: TButton
    Left = 598
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 1
    OnClick = btn19Click
  end
  object cbServers: TComboBox
    Left = 7
    Top = 24
    Width = 586
    Height = 21
    TabOrder = 2
    Items.Strings = (
      
        'http://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryO' +
        'nly/MapServer/wmts'
      
        'http://garden.gis.vt.edu/arcgis/rest/services/VBMP2011/VBMP2011_' +
        'Infrared_WGS/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://geodata.nationaalgeoregister.nl/tiles/service/wmts/bgtsta' +
        'ndaard?VERSION=1.0.0&request=GetCapabilities'
      
        'http://geodata.nationaalgeoregister.nl/tiles/service/wmts/brtach' +
        'tergrondkaart?REQUEST=getcapabilities&amp;VERSION=1.0.0'
      
        'http://gis.oregonmetro.gov/services/wmts/1.0.0/WMTSGetCapabiliti' +
        'es.xml'
      
        'http://kortforsyningen.kms.dk/orto_foraar?SERVICE=WMTS&request=G' +
        'etCapabilities'
      
        'http://kortforsyningen.kms.dk/orto_foraar?VERSION=1.0.0&LAYER=or' +
        'to_foraar&request=GetCapabilities&SERVICE=WMTS&login=qgistest&pa' +
        'ssword=qgistestpw'
      
        'http://maps.columbus.gov/arcgis/rest/services/Imagery/Imagery201' +
        '3/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'https://mapy.geoportal.gov.pl/wss/service/PZGIK/ORTO/WMTS/Standa' +
        'rdResolution'
      
        'http://maps.wien.gv.at/wmts/1.0.0/WMTSCapabilities.xml?request=G' +
        'etCapabilities'
      'http://tileserver.maptiler.com/wmts'
      'http://www.basemap.at/wmts/1.0.0/WMTSCapabilities.xml'
      'http://www.wien.gv.at/wmts/1.0.0/WMTSCapabilities.xml')
  end
  object btn18: TButton
    Left = 599
    Top = 22
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 3
    OnClick = btn18Click
  end
  object cbInvertAxis: TCheckBox
    Left = 519
    Top = 72
    Width = 80
    Height = 17
    Caption = 'Invert axis'
    TabOrder = 4
  end
end
