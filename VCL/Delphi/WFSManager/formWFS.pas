//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide WFS Layer support.
}
unit formWFS;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Tabs,
  Vcl.ComCtrls,
  Vcl.Menus,

  GisFileWFS,
  GisFunctions,
  GisTypes,
  GisClasses;

type
  TfrmWFS = class(TForm)
    Label1: TLabel;
    cbURL: TComboBox;
    tvLayers: TTreeView;
    GroupBox1: TGroupBox;
    btnLoadService: TButton;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    eParams: TEdit;
    Label3: TLabel;
    cbDataFormats: TComboBox;
    cbReverseXY: TCheckBox;
    cbMaxFeatures: TCheckBox;
    seMaxFeatures: TEdit;
    cbBBoxFIlter: TCheckBox;
    btnAddLayer: TButton;
    Label4: TLabel;
    cbCRS: TComboBox;
    memLayerInfo: TMemo;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    btnCancel: TButton;
    cbVersion: TComboBox;
    Label5: TLabel;
    eYMin: TEdit;
    eXMax: TEdit;
    eXMin: TEdit;
    eYMax: TEdit;
    lblXmin: TLabel;
    lblXMax: TLabel;
    lblYMax: TLabel;
    lblYMin: TLabel;
    cbStartIndex: TCheckBox;
    seStartIndex: TEdit;
    chkClipVisibleExtent: TCheckBox;
    pm1: TPopupMenu;
    Locateonmap1: TMenuItem;
    btnOpenURL: TButton;
    OpenMetadata1: TMenuItem;
    procedure btnLoadServiceClick(Sender: TObject);
    procedure btnAddLayerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbBBoxFIlterClick(Sender: TObject);
    procedure cbStartIndexClick(Sender: TObject);
    procedure cbMaxFeaturesClick(Sender: TObject);
    procedure tvLayersChange(Sender: TObject; Node: TTreeNode);
    procedure chkClipVisibleExtentClick(Sender: TObject);
    procedure Locateonmap1Click(Sender: TObject);
    procedure OpenlastURL1Click(Sender: TObject);
    procedure btnOpenURLClick(Sender: TObject);
    procedure OpenMetadata1Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
      wfs : TGIS_FileWFS ;
      function getSelectedFeature : TGIS_WFSFeature ;
      function getBBoxExtent( const _fea : TGIS_WFSFeature ) : TGIS_Extent ;
  public
    { Public declarations }
  end;

var
  frmWFS: TfrmWFS;

implementation

uses
  Winapi.ShellApi,
  formMain,
  GisRtl,
  GisLayerWFS,
  GisCsSystems,
  GisCsFactory,
  GisResource ;

{$R *.dfm}

procedure TfrmWFS.btnAddLayerClick(Sender: TObject);
var
  fea     : TGIS_WFSFeature ;
  wfsPath : String ;
begin
  wfsPath := '&SERVICE=WFS' ;

  btnAddLayer.Caption := 'Wait...';
  btnAddLayer.Enabled := false;

  if eParams.Text <> '' then
    wfsPath := wfsPath + '&' + eParams.Text ;

  if cbVersion.Text <> '' then
    wfsPath := wfsPath + '&VERSION=' + cbVersion.Text ;

  fea := getSelectedFeature ;
  if Assigned( fea ) then
    wfsPath := wfsPath + '&TYPENAME=' + fea.Name ;

  if cbCRS.Text <> '' then
    wfsPath := wfsPath + '&SRSNAME=' + cbCRS.Text ;

  if cbDataFormats.Text <> '' then
    wfsPath := wfsPath + '&OUTPUTFORMAT=' + cbDataFormats.Text ;

  if cbMaxFeatures.Checked then
    wfsPath := wfsPath + '&MAXFEATURES=' + seMaxFeatures.Text ;

  if cbStartIndex.Checked then
    wfsPath := wfsPath + '&STARTINDEX=' + seStartIndex.Text ;

  if cbBBoxFIlter.Checked then begin
    if cbReverseXY.Checked then
      wfsPath := wfsPath +
                   Format( '&BBOX=%s,%s,%s,%s',
                           [DotFloatToStr(StrToFloat(eYMin.Text)),
                            DotFloatToStr(StrToFloat(eXMin.Text)),
                            DotFloatToStr(StrToFloat(eYMax.Text)),
                            DotFloatToStr(StrToFloat(eXMax.Text))]
                          )
    else
      wfsPath := wfsPath +
                   Format( '&BBOX=%s,%s,%s,%s',
                           [DotFloatToStr(StrToFloat(eXMin.Text)),
                            DotFloatToStr(StrToFloat(eYMin.Text)),
                            DotFloatToStr(StrToFloat(eXMax.Text)),
                            DotFloatToStr(StrToFloat(eYMax.Text))]
                          ) ;
  end ;

  if cbReverseXY.Checked then
    wfsPath := wfsPath + '&AxisOrder=' + GIS_INI_AXIS_ORDER_NE ;

  frmMain.AppendCoverage( wfs.MakeUrl( wfsPath, cbURL.Text ) ) ;

  btnAddLayer.Enabled := true;
  btnAddLayer.Caption := 'Add layer';
end;

procedure TfrmWFS.btnCancelClick(Sender: TObject);
begin
  Close ;
end;

procedure TfrmWFS.btnLoadServiceClick(Sender: TObject);
var
  str   : String ;
  i     : Integer ;
  root  : TTreeNode ;
  node  : TTreeNode ;
  fea   : TGIS_WFSFeature ;
begin
  str := cbURL.Text ;
  if str = '' then exit ;

  tvLayers.Items.Clear ;
  memLayerInfo.Lines.Clear ;
  wfs.Load( str ) ;

  if not IsStringEmpty( wfs.Error ) then
    raise EGIS_Exception.Create( _rsrc( GIS_RS_ERR_SERVER_ERROR ), wfs.Error, 0 ) ;

  if wfs.FeaturesCount = 0 then exit ;

  tvLayers.Items.BeginUpdate ;
  try
    root := tvLayers.Items.Add( nil, wfs.Path ) ;
    for i := 0 to wfs.FeaturesCount-1 do begin
      fea := wfs.Feature[i] ;
      node := tvLayers.Items.AddChild( root, fea.Name ) ;
      node.Data := wfs.Feature[i] ;
    end ;
    root.Expanded := True ;
    tvLayers.Select( root ) ;
  finally
    tvLayers.Items.EndUpdate ;
  end ;

  cbDataFormats.Items.BeginUpdate ;
  cbDataFormats.Items.Clear ;
  cbDataFormats.Items.AddStrings( wfs.DataFormats ) ;
  cbDataFormats.Items.EndUpdate ;

  cbCRS.Items.BeginUpdate ;
  cbCRS.Items.Clear ;
  cbCRS.Items.EndUpdate ;

  eXMin.Text := '' ;
  eXMax.Text := '' ;
  eYMin.Text := '' ;
  eYMax.Text := '' ;
end;

procedure TfrmWFS.btnOpenURLClick(Sender: TObject);
var
  lwfs : TGIS_LayerWFS ;
begin
  lwfs := TGIS_LayerWFS.Create ;
  lwfs.Path := cbURL.Text ;
  frmMain.GIS.Add( lwfs ) ;
  frmMain.GIS.FullExtent ;
end;

procedure TfrmWFS.cbBBoxFIlterClick(Sender: TObject);
begin
  eXMin.Enabled   := cbBBoxFIlter.Checked ;
  eXMax.Enabled   := cbBBoxFIlter.Checked ;
  eYMin.Enabled   := cbBBoxFIlter.Checked ;
  eYMax.Enabled   := cbBBoxFIlter.Checked ;

  lblXMin.Enabled := cbBBoxFIlter.Checked ;
  lblXMax.Enabled := cbBBoxFIlter.Checked ;
  lblYMin.Enabled := cbBBoxFIlter.Checked ;
  lblYMax.Enabled := cbBBoxFIlter.Checked ;

  chkClipVisibleExtent.Enabled := cbBBoxFIlter.Checked ;
  chkClipVisibleExtentClick(Self);
end;

procedure TfrmWFS.cbMaxFeaturesClick(Sender: TObject);
begin
  seMaxFeatures.Enabled := cbMaxFeatures.Checked ;
end;

procedure TfrmWFS.cbStartIndexClick(Sender: TObject);
begin
  seStartIndex.Enabled := cbStartIndex.Checked ;
end;

procedure TfrmWFS.chkClipVisibleExtentClick(Sender: TObject);
var
  ext  : TGIS_Extent ;
begin
  if frmMain.GIS.IsEmpty then exit ;

  ext := getBBoxExtent( getSelectedFeature ) ;

  if not GisIsNoWorld( ext ) then begin
    eXMin.Text := DotFloatToStr( ext.XMin ) ;
    eXMax.Text := DotFloatToStr( ext.XMax ) ;
    eYMin.Text := DotFloatToStr( ext.YMin ) ;
    eYMax.Text := DotFloatToStr( ext.YMax ) ;
  end
  else begin
    eXMin.Text := '' ;
    eXMax.Text := '' ;
    eYMin.Text := '' ;
    eYMax.Text := '' ;
  end ;
end;

procedure TfrmWFS.FormDestroy(Sender: TObject);
begin
  if Assigned( wfs ) then
    wfs.Free ;
end;

procedure TfrmWFS.FormShow(Sender: TObject);
begin
  if not Assigned( wfs ) then
    wfs := TGIS_FileWFS.Create( nil, nil ) ;
end;

function TfrmWFS.getBBoxExtent( const _fea : TGIS_WFSFeature ) : TGIS_Extent ;
var
  lcs  : TGIS_CSCoordinateSystem ;
  wgs  : TGIS_CSCoordinateSystem ;
begin
  Result := GisNoWorld ;

  if not Assigned( _fea ) then exit ;

  try
    if cbCRS.ItemIndex > -1 then
      lcs := TGIS_CSFactory.ByWKT( cbCRS.Text )
    else
      lcs := TGIS_CSFactory.ByWKT( _fea.DefaultSRS ) ;
  except
    lcs := CSUnknownCoordinateSystem ;
  end ;

  if not chkClipVisibleExtent.Checked then begin
    wgs := TGIS_CSFactory.ByEPSG( GIS_EPSG_WGS84 ) ;

    if not ( lcs is TGIS_CSUnknownCoordinateSystem ) then begin
      Result := lcs.ExtentFromCS( wgs, _fea.WGS84BBox ) ;
      if lcs.Error <> 0 then
        Result := GisNoWorld ;
    end;
  end
  else begin
    wgs := frmMain.GIS.CS ;

    if not ( lcs is TGIS_CSUnknownCoordinateSystem ) then begin
      Result := lcs.ExtentFromCS( wgs, frmMain.GIS.UnrotatedExtent( frmMain.GIS.VisibleExtent ) ) ;
      if lcs.Error <> 0 then
        Result := GisNoWorld ;
    end;
  end
end;

function TfrmWFS.getSelectedFeature : TGIS_WFSFeature;
begin
  if Assigned( tvLayers.Selected ) and ( tvLayers.Selected.Level > 0 ) then
    Result := TGIS_WFSFeature(tvLayers.Selected.Data)
  else
    Result := nil ;

end;

procedure TfrmWFS.Locateonmap1Click(Sender: TObject);
var
  fea : TGIS_WFSFeature ;
begin
  fea := getSelectedFeature ;
  if Assigned( fea ) then
    frmMain.GIS.VisibleExtent := fea.WGS84BBox ;
end;

procedure TfrmWFS.OpenlastURL1Click(Sender: TObject);
var
  fea : TGIS_WFSFeature ;
begin
  fea := getSelectedFeature ;
  if Assigned( fea ) then
    ShellExecute( 0, 'open', PWideChar( fea.LastUrl ), nil, nil, 0 ) ;
end;

procedure TfrmWFS.OpenMetadata1Click(Sender: TObject);
var
  fea : TGIS_WFSFeature ;
begin
  fea := getSelectedFeature ;
  if Assigned( fea ) then
    ShellExecute( 0, 'open', PWideChar( fea.MetadataUrl ), nil, nil, 0 ) ;
end;

procedure TfrmWFS.tvLayersChange(Sender: TObject; Node: TTreeNode);
var
  fea : TGIS_WFSFeature ;
  ext : TGIS_Extent ;
begin
  if Assigned( Node ) and ( Node.Level > 0 ) then begin
    fea := TGIS_WFSFeature(Node.Data) ;
    memLayerInfo.Lines.BeginUpdate ;
    memLayerInfo.Clear ;
    memLayerInfo.Lines.Add( 'Name : ' + fea.Name ) ;
    memLayerInfo.Lines.Add( 'Title : '+ fea.Title ) ;
    if fea.Description <> '' then
      memLayerInfo.Lines.Add( 'Description : ' + fea.Description ) ;
    if fea.Keywords <> '' then
      memLayerInfo.Lines.Add( 'Keywords : '  + fea.Keywords ) ;
    memLayerInfo.Lines.Add( 'Default SRS : '  + fea.DefaultSRS ) ;
    //memLayerInfo.Lines.Add( 'Other SRS : ' ) ;
    //memLayerInfo.Lines.AddStrings( fea.OtherSRS ) ;
    memLayerInfo.Lines.Add( 'WGS84 Bounding Box : ' ) ;
    memLayerInfo.Lines.Add( Format(' %f, %f, %f, %f',
                                   [fea.WGS84BBox.XMin, fea.WGS84BBox.YMin,
                                    fea.WGS84BBox.XMax, fea.WGS84BBox.YMax ] ) ) ;
    memLayerInfo.Lines.EndUpdate ;

    ext := getBBoxExtent( fea ) ;

    if not GisIsNoWorld( ext ) then begin
      eXMin.Text := DotFloatToStr( ext.XMin ) ;
      eXMax.Text := DotFloatToStr( ext.XMax ) ;
      eYMin.Text := DotFloatToStr( ext.YMin ) ;
      eYMax.Text := DotFloatToStr( ext.YMax ) ;
    end
    else begin
      eXMin.Text := '' ;
      eXMax.Text := '' ;
      eYMin.Text := '' ;
      eYMax.Text := '' ;
    end ;
    cbCRS.Text := '' ;
    cbCRS.Items.BeginUpdate ;
    cbCRS.Items.Clear ;
    cbCRS.Items.Add( fea.DefaultSRS ) ;
    cbCRS.Items.AddStrings( fea.OtherSRS ) ;
    cbCRS.Items.EndUpdate ;
  end
  else begin
    memLayerInfo.Lines.BeginUpdate ;
    memLayerInfo.Clear ;
    memLayerInfo.Lines.AddStrings( wfs.ServiceInfo ) ;
    memLayerInfo.Lines.EndUpdate ;
  end ;
end;

end.
