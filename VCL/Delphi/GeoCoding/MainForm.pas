//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform Geocoding & Routing.
}

unit MainForm;

interface

uses
  System.Classes,
  System.SysUtils,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,

  //GisLicense,
  GisTypes,
  GisCsBase,
  GisEditor,
  GisGeocoding,
  GisLayerVector,
  GisLayerSHP,
  GisLayerADF,
  GisParams,
  GisShortestPath,
  GisTopology,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlScale,
  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_ControlScale1: TGIS_ControlScale;
    Panel2: TPanel;
    memRoute: TMemo;
    GroupBox1: TGroupBox;
    trkSmallRoads: TTrackBar;
    trkHighways: TTrackBar;
    lblSmallRoads: TLabel;
    lblHighways: TLabel;
    edtAddrFrom: TEdit;
    btnResolve: TButton;
    edtAddrTo: TEdit;
    btnRoute: TButton;
    lblAddrFrom: TLabel;
    lblAddrTo: TLabel;
    chkbxOnline: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnResolveClick(Sender: TObject);
    procedure btnRouteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkbxOnlineClick(Sender: TObject);
  private
    { Private declarations }
    layerSrc : TGIS_LayerVector ;
    layerRoute : TGIS_LayerVector ;
    rtrObj : TGIS_ShortestPath ;
    geoObj : TGIS_Geocoding ;
    costFactor : Double ;
    procedure doLinkType(     _sender   : TObject ;
                              _shape    : TGIS_ShapeArc ;
                          var _type     : Integer
                        ) ;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.doLinkType(    _sender   : TObject ;
                                 _shape    : TGIS_ShapeArc ;
                             var _type     : Integer
                           ) ;
begin
  if _shape.GetField( 'MTFCC' ) >= 'S1400' then
    // local roads
    _type := 1
  else
    _type := 0 ;
end ;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\Projects\California.ttkproject' ) ;
  layerSrc := TGIS_LayerVector( GIS.Get( 'streets' ) ) ;

  if not Assigned( layerSrc ) then exit ;
  if not ( layerSrc is TGIS_LayerVector ) then exit ;

  GIS.VisibleExtent := layerSrc.ProjectedExtent ;

  // create route layer
  layerRoute := TGIS_LayerVector.Create ;
  layerRoute.UseConfig := False ;
  layerRoute.Params.Line.Color := TGIS_Color.Red ;
  layerRoute.Params.Line.Width := -2 ;
  layerRoute.Params.Marker.OutlineWidth := 1 ;
  layerRoute.Name := 'RouteDisplay' ;
  layerRoute.CS := GIS.CS ;
  GIS.Add( layerRoute ) ;

  // create geocoding object, set fields for routing
  geoObj := TGIS_Geocoding.Create( layerSrc ) ;
  geoObj.offset := 0.0001  ;
  geoObj.RoadName := 'FULLNAME';
  geoObj.LFrom    := 'LFROMADD';
  geoObj.LTo      := 'LTOADD';
  geoObj.RFrom    := 'RFROMADD';
  geoObj.RTo      := 'RTOADD';

  costFactor := 1 ;

  // create path object and load source layer data
  rtrObj := TGIS_ShortestPath.Create( GIS ) ;
  rtrObj.LinkTypeEvent := doLinkType ;
  rtrObj.LoadTheData( layerSrc ) ;
  rtrObj.RoadName := 'FULLNAME';

  GIS.Unlock;
  GIS_ControlScale1.Units := CSUnitsList.ByEPSG( 9035 ) ; // mile
end;

procedure TForm1.btnResolveClick(Sender: TObject);
var
  i   : Integer ;
  r   : Integer ;
  shp : TGIS_Shape ;
begin
  if not Assigned( geoObj ) then exit ;

  layerRoute.RevertShapes ;

  // locate shapes meeting query
  r := geoObj.Parse( edtAddrFrom.Text ) -1 ;
  if r <= 0 then edtAddrFrom.Text := edtAddrFrom.Text + ' ???' ;

  for i:=0 to r do
  begin
    edtAddrFrom.Text := geoObj.Query[i] ;
    Application.ProcessMessages ;

    // add found shape to route layer (red color)
    shp := layerSrc.GetShape( geoObj.Uid[i] ) ;
    layerRoute.AddShape( shp ) ;

    if i = 0 then layerRoute.Extent := shp.ProjectedExtent ;

    shp := layerSrc.GetShape( geoObj.UidEx[i] ) ;
    if Assigned( shp ) then
      layerRoute.AddShape( shp ) ;

    // mark address as green squere
    shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Extent );
    shp.AddPart ;
    shp.AddPoint( layerRoute.CS.FromCS( layerSrc.CS, geoObj.Point[i] ) ) ;
    shp.Params.Marker.Color := TGIS_Color.Green ;
    shp.Unlock ;
  end ;
  GIS.Lock ;
  GIS.VisibleExtent := layerRoute.ProjectedExtent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;
end;


procedure TForm1.btnRouteClick(Sender: TObject);
var
  i      : Integer    ;
  shp    : TGIS_Shape ;
  res    : Integer    ;
  pt_a   : TGIS_Point ;
  pt_b   : TGIS_Point ;
  ang    : String     ;
  oldnam : String     ;
begin
  // calculate wages
  rtrObj.CostModifiers[0] := 1 - 1/11 * trkHighways.Position ;
  rtrObj.CostModifiers[1] := 1 - 1/11 * trkSmallRoads.Position ;

  // locate shapes meeting query
  res := geoObj.Parse( edtAddrFrom.Text ) ;
  // if not found, ask for more details
  if res > 0 then edtAddrFrom.Text := geoObj.Query[0]
             else edtAddrFrom.Text :=  edtAddrFrom.Text + ' ???' ;

  // remember starting point
  if res <= 0 then exit ;
  pt_a := geoObj.Point[0]  ;

  res := geoObj.Parse( edtAddrTo.Text ) ;
  if res > 0 then edtAddrTo.Text := geoObj.Query[0]
             else edtAddrTo.Text := edtAddrTo.Text + ' ???' ;

  // remember ending point
  if res <= 0 then exit ;
  pt_b := geoObj.Point[0]  ;

  // set starting and ending position
  rtrObj.UpdateTheData ;
  rtrObj.Find( layerRoute.Unproject( pt_a ),
               layerRoute.Unproject( pt_b )
             ) ;

  memRoute.Lines.BeginUpdate ;
  memRoute.Clear ;
  oldnam := '#$@3eqewe' ;

  // display directions
  for i:=0 to rtrObj.ItemsCount -1 do
  begin
    case rtrObj.Items[i].Compass of
      0 : ang := 'FWD  ' ;
      1 : ang := 'RIGHT' ;
      2 : ang := 'RIGHT' ;
      3 : ang := 'RIGHT' ;
      4 : ang := 'BACK ' ;
     -1 : ang := 'LEFT ' ;
     -2 : ang := 'LEFT ' ;
     -3 : ang := 'LEFT ' ;
     -4 : ang := 'BACK ' ;
    end ;

    if oldnam = rtrObj.Items[i].Name then continue ;
    oldnam := rtrObj.Items[i].Name ;

    memRoute.Lines.Add( Format( '%s %s', [ ang, rtrObj.Items[i].Name ] ) ) ;
  end ;
  memRoute.Lines.EndUpdate ;

  layerRoute.RevertShapes ;

  // add shapes of our path to route layer (red)
  for i:=0 to rtrObj.ItemsCount -1 do
  begin
    shp := rtrObj.Items[i].Layer.GetShape( rtrObj.Items[i].Uid ) ;
    if not Assigned( shp ) then continue ;
    layerRoute.AddShape( shp ) ;
    if i = 0 then
      layerRoute.Extent := shp.Extent ;
  end ;

  // mark starting point as green squere
  shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent );
  shp.AddPart ;
  shp.AddPoint( pt_a ) ;
  shp.Params.Marker.Color := TGIS_Color.Green ;
  shp.Unlock ;

  // mark starting point as red squere
  shp := layerRoute.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent );
  shp.AddPart ;
  shp.AddPoint( pt_b ) ;
  shp.Unlock ;

  GIS.Lock ;
  GIS.VisibleExtent := layerRoute.Extent ;
  GIS.Zoom := 0.7 * GIS.Zoom ;
  GIS.Unlock ;
end;


procedure TForm1.chkbxOnlineClick(Sender: TObject);
begin
  if chkbxOnline.Checked then begin
    geoObj.OSMGeocoding := True ;
    rtrObj.OSMRouting := True ;
  end
  else begin
    geoObj.OSMGeocoding := False ;
    rtrObj.OSMRouting := False ;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  geoObj.Free;
  rtrObj.Free;
end;

end.
