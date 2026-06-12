//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Reproject sample — demonstrates coordinate system transformation and reprojection of geospatial data.

  What the sample shows:
    - Loading a shapefile into the GIS viewer
    - Accessing the projection catalogue via CsProjList (registry of projections)
    - Building a projected coordinate system from components:
      Geographic coordinate system (datum and ellipsoid)
      Projection method (UTM, Mercator, etc.)
      Units of measurement (meters, feet, etc.)
    - Assigning a coordinate system to the viewer and layer
    - Automatic coordinate transformation when rendering with new CS
    - Selecting a target map projection from dropdown (populated from registry)
    - Viewer automatically reprojects and displays data in new CS
    - Exporting reprojected data to a new shapefile
    - Real-time preview of reprojected layer in viewer

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - vector layer for spatial data
    TGIS_LayerSHP               - shapefile layer implementation
    TGIS_CSCoordinateSystem      - coordinate system definition
    CsProjList                  - projection catalogue lookup
    TGIS_Projection             - projection method
    TGIS_CSUnits                - unit definitions (meters, feet, etc.)
    TGIS_Layer.SaveAs()         - export reprojected data to new file
    GIS.CS property             - assign coordinate system to viewer
    On-the-fly transformation   - automatic reprojection during rendering
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisCsBase,
  GisCsProjections,
  GisCsFactory,
  GisCsSystems,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Reproject sample — demonstrates coordinate system transformation and reprojection of geospatial data.
    Loads a shapefile and allows users to select a target map projection (e.g., UTM, Mercator, Geographic).
    Reprojects the layer geometry and saves the result to a new file. Demonstrates TGIS_Projection
    instantiation, spatial reference assignment, and layer coordinate transformation. }
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    Button1: TButton;
    ToolButton1: TToolButton;
    dlgSave: TSaveDialog;
    ToolButton3: TToolButton;
    cbxSrcProjection: TComboBox;
    procedure Button2Click(Sender: TObject);
    procedure cbxSrcProjectionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the form: populates the projection dropdown with all registered projections
  from the TatukGIS coordinate system library, then loads the sample shapefile.
}
procedure TForm1.FormCreate(Sender: TObject);
var
  i : Integer ;
  lst : TStringList ;
begin
  { Create a temporary string list for sorting projection WKT strings }
  lst := TStringList.Create ;
  lst.Sorted := True ;
  try
    lst.Clear ;
    { Enumerate all registered projections in the CsProjList (TatukGIS projection registry) }
    for i:=0 to CsProjList.Count -1 do
    begin
      { Add the WKT (Well-Known Text) representation of each projection to the list }
      lst.Add( CSProjList[i].WKT ) ;
    end ;
    { Populate the combobox with the sorted list of projection WKT strings }
    for i:=0 to lst.Count - 1 do
      cbxSrcProjection.Items.AddObject( lst[i], lst.Objects[i] ) ;
    { Select the first projection by default }
    cbxSrcProjection.ItemIndex := 0 ;
  finally
    lst.Free ;
  end ;

  { Trigger the projection change handler to initialize the viewer with the selected projection }
  cbxSrcProjectionChange( Self ) ;

  { Load the sample country boundary shapefile for reprojection demonstration }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\country.shp' ) ;
end;

{
  Button2Click
  Exports the reprojected layer to a new shapefile. The exported data retains
  the currently selected projection/coordinate system.
}
procedure TForm1.Button2Click(Sender: TObject);
var
  lv : TGIS_LayerVector ;
  lo : TGIS_LayerVector ;
begin
  { Guard: cannot export if no layers are loaded }
  if GIS.IsEmpty then exit ;

  { Show a "Save As" dialog to let the user choose an output filename and location }
  if not dlgSave.Execute then exit ;

  { Get the source layer (currently displayed with reprojected coordinates) }
  lv := TGIS_LayerVector( GIS.Items[0] );

  { Create a new SHP layer for output }
  lo := TGIS_LayerSHP.Create ;
  { Set the output file path from the save dialog }
  lo.Path := dlgSave.FileName;
  { Assign the current coordinate system (the reprojected one) to the output layer
    so that exported coordinates match what's displayed on the map }
  lo.CS := GIS.CS ;
  try
    { Import all features from the source layer into the output layer.
      ImportLayer handles the coordinate transformation automatically based on
      the coordinate systems assigned to the source and destination layers. }
    lo.ImportLayer( lv,  TGIS_Utils.GisWholeWorld,
                    TGIS_ShapeType.Unknown, '', False

                  ) ;
  finally
    lo.Free ;
  end ;
end;

{
  cbxSrcProjectionChange
  Called when the user selects a different map projection from the dropdown.

  Process:
    1. Retrieve the WKT string for the selected projection
    2. Look up a geographic coordinate system (datum) from the registry
    3. Look up units of measurement (meters, feet, etc.)
    4. Look up the projection method (e.g., UTM Zone 33N, Mercator)
    5. Combine these into a projected coordinate system
    6. Assign the new CS to the viewer, triggering automatic reprojection
    7. Zoom to full extent to see the data in the new projection
}
procedure TForm1.cbxSrcProjectionChange(Sender: TObject);
var
  sproj : String ;
  ocs   : TGIS_CSCoordinateSystem ;
  ogcs  : TGIS_CSGeographicCoordinateSystem ;
  ounit : TGIS_CSUnits ;
  oproj : TGIS_CSProjAbstract ;
begin
  { Get the WKT (Well-Known Text) representation of the selected projection }
  sproj := cbxSrcProjection.Items[cbxSrcProjection.ItemIndex] ;

  { Look up the geographic coordinate system (EPSG 4030 = WGS84 datum) from the registry }
  ogcs := CSGeographicCoordinateSystemList.ByEPSG( 4030 ) ;

  { Look up the measurement units (METER) from the coordinate system units registry }
  ounit := CSUnitsList.ByWKT( 'METER') ;

  { Look up the projection method (e.g., Transverse Mercator for UTM) from the projection registry }
  oproj := CSProjList.ByWKT( sproj ) ;

  { Create a new projected coordinate system combining:
    - Geographic coordinate system (datum/ellipsoid)
    - Projection method (UTM, Mercator, etc.)
    - Units of measurement
    - Projection-specific parameters (zone, scale factor, false easting, etc.) }
  ocs := TGIS_CSProjectedCoordinateSystem.Create(
           -1, 'Test',
           ogcs.EPSG, ounit.EPSG, oproj.EPSG,
           CSProjectedCoordinateSystemList.DefaultParams( oproj.EPSG )
         );

  { Lock the viewer to batch coordinate transformation without intermediate redraws }
  GIS.Lock ;
  try
    try
      { Assign the new coordinate system to the viewer.
        This triggers automatic transformation of all layer coordinates
        from the original CS to the new CS. }
      GIS.CS := ocs ;
      { Zoom to the full extent of the data in the new projection.
        This is necessary because the geographic extents differ when coordinates
        are transformed to a different projection system. }
      GIS.FullExtent ;
    except
      { If projection fails, revert to no coordinate system }
      GIS.CS := nil
    end;
  finally
    { Unlock the viewer to allow redrawing with the new CS applied }
    GIS.Unlock ;
  end;
end;


end.

