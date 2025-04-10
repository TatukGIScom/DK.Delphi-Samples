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
  object btnAdd: TButton
    Left = 598
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 1
    OnClick = btnAddClick
  end
  object cbServers: TComboBox
    Left = 7
    Top = 24
    Width = 586
    Height = 21
    TabOrder = 2
    Items.Strings = (
      
        'http://apps.fs.fed.us/arcx/rest/services/wo_nfs_gstc/GSTC_Travel' +
        'Access_03/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryO' +
        'nly/MapServer/wmts'
      
        'http://basemap.nationalmap.gov/arcgis/rest/services/USGSShadedRe' +
        'liefOnly/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://garden.gis.vt.edu/arcgis/rest/services/VBMP2011/VBMP2011_' +
        'Infrared_WGS/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://geodata.nationaalgeoregister.nl/tiles/service/wmts/bgtsta' +
        'ndaard?VERSION=1.0.0&request=GetCapabilities'
      
        'http://geodata.nationaalgeoregister.nl/tiles/service/wmts/brtach' +
        'tergrondkaart?REQUEST=getcapabilities&amp;VERSION=1.0.0'
      
        'http://geoportal.cuzk.cz/WMTS_ORTOFOTO_900913/WMTService.aspx?se' +
        'rvice=WMTS&request=GetCapabilities'
      
        'http://geoservices.unige.ch/arcgis/rest/services/europe/eu_fond_' +
        'gris/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://gis.co.wadena.mn.us/arcgis/rest/services/WADENAPICTOMETRY' +
        '/MapServer/WMTS'
      
        'http://gis.ecan.govt.nz/arcgis/rest/services/Imagery/MapServer/W' +
        'MTS/1.0.0/WMTSCapabilities.xml'
      
        'http://gis.oregonmetro.gov/services/wmts/1.0.0/WMTSGetCapabiliti' +
        'es.xml'
      
        'http://gisdata.orc.govt.nz/arcgis/rest/services/Imagery/OtagoReg' +
        'ionalAerials/MapServer/WMTS'
      
        'http://hazards.fema.gov/gis/nfhl/rest/services/MapSearch/MapSear' +
        'ch_DFIRM_Tiles/MapServer/WMTS'
      
        'http://kortforsyningen.kms.dk/orto_foraar?SERVICE=WMTS&request=G' +
        'etCapabilities'
      
        'http://kortforsyningen.kms.dk/orto_foraar?VERSION=1.0.0&LAYER=or' +
        'to_foraar&request=GetCapabilities&SERVICE=WMTS&login=qgistest&pa' +
        'ssword=qgistestpw'
      
        'http://maps.columbus.gov/arcgis/rest/services/Imagery/Imagery201' +
        '3/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://maps.edc.uri.edu/arcgis/rest/services/Atlas_elevation/Hil' +
        'lshade/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://maps.evansvillegis.com/arcgis_server/rest/services/PLANIM' +
        'ETRIC/CONTOURS_TILES/MapServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://maps.warwickshire.gov.uk/gs/gwc/service/wmts?REQUEST=GetC' +
        'apabilities'
      
        'http://maps.wien.gv.at/wmts/1.0.0/WMTSCapabilities.xml?request=G' +
        'etCapabilities'
      
        'http://mapy.gis-expert.pl/arcgis/rest/services/Nieruchomosci/Lub' +
        'lin_nieruchomosci_komunikacja_miejska/MapServer/WMTS'
      
        'http://mapy.gis-expert.pl/arcgis/rest/services/Nieruchomosci/Lub' +
        'lin_nieruchomosci_rekreacja/MapServer/WMTS'
      
        'http://nis.cubewerx.com/cubewerx/cubeserv?CONFIG=OIM_MB_-_Orthop' +
        'hoto-WMTS&service=wmts&request=getcapabilities'
      
        'http://opencache.statkart.no/gatekeeper/gk/gk.open_wmts?Version=' +
        '1.0.0&service=wmts&request=getcapabilities'
      
        'http://s1-mdc.cloud.eaglegis.co.nz/arcgis/rest/services/Cache/To' +
        'pographicMaps/MapServer/WMTS'
      
        'http://sdi.provinz.bz.it/geoserver/gwc/service/wmts?REQUEST=getc' +
        'apabilities'
      
        'http://services.opengeoserver.org/wmts/1.0.0/WMTSCapabilities.xm' +
        'l'
      'http://storms.ngs.noaa.gov/storms/sandy/imagery/wmts'
      
        'http://suite.opengeo.org/geoserver/gwc/service/wmts/?request=Get' +
        'Capabilities'
      'http://tileserver.maptiler.com/wmts'
      
        'http://tryitlive.arcgis.com/arcgis/rest/services/ImageryHybrid/M' +
        'apServer/WMTS/1.0.0/WMTSCapabilities.xml'
      
        'http://webgis.arpa.piemonte.it/ags101free/rest/services/topograf' +
        'ia_dati_di_base/Sfumo_Europa_WM/MapServer/WMTS'
      'http://www.basemap.at/wmts/1.0.0/WMTSCapabilities.xml'
      'http://www.wien.gv.at/wmts/1.0.0/WMTSCapabilities.xml'
      
        'https://maps.umass.edu/arcgis/rest/services/planning/pubImgrCamp' +
        'usMasterPlanPhase3/MapServer/WMTS')
  end
  object btnConnect: TButton
    Left = 599
    Top = 22
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 3
    OnClick = btnConnectClick
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
