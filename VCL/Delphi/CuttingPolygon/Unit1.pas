{
  CuttingPolygon sample — demonstrates how to clip a raster (pixel) layer's rendering to within
  an arbitrary polygon boundary using TGIS_LayerPixel.CuttingPolygon.

  What the sample shows:
    - Loading a raster image (world map) into the GIS viewer
    - Creating an in-memory vector layer with a custom polygon
    - Implementing raster clipping/masking via CuttingPolygon property
    - Assigning a triangular polygon as the cutting mask
    - Toggling clipping on/off via button click (Do Cutting)
    - Raster rendering constrained to polygon boundary
    - Remaining regions outside polygon are not rendered
    - Interactive zoom and pan with clipped raster display

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerPixel             - raster/image layer
    TGIS_LayerVector            - in-memory vector layer
    TGIS_LayerPixel.CuttingPolygon - masking/clipping property
    TGIS_Shape                  - polygon geometry for clipping
    TGIS_ControlLegend          - layer list/legend panel
    OnFormCreate event          - initialization workflow
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  GisTypes,
  GisAllLayers,
  GisLayerSHP,
  GisLayerPixel,
  GisLayerVector,
  GisViewer,
  //GisLicense,
  GisTypesUI,
  GisUtils,
  GisRegistredLayers,

  Vcl.GisViewerWnd,
  Vcl.GisControlLegend ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_ControlLegend1: TGIS_ControlLegend;
    ToolBar1: TToolBar;
    btnCutting: TButton;
    btnZoom: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCuttingClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
  private
  var
    ll  : TGIS_LayerVector ;
    lp  : TGIS_LayerPixel ;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ btnCuttingClick - Core algorithm for raster clipping

  Algorithm:
    1. Retrieve the raster layer (TGIS_LayerPixel, first in list at index 0)
    2. Get the triangular polygon from the vector layer (shape #1, since #0 is implicit)
    3. Transform polygon to match raster's coordinate system via CreateCopyCS
       (ensures spatial coherence between raster and clipping boundary)
    4. Assign transformed polygon to raster layer's CuttingPolygon property
       (this activates hardware clipping during rendering)
    5. Hide the vector layer to show only the clipped raster result
    6. Force full map redraw to apply clipping effect

  Technical details:
    - CuttingPolygon: property that masks raster rendering to polygon boundary
    - CreateCopyCS: transforms shape coordinates to target coordinate system
    - InvalidateWholeMap: triggers complete re-rendering with clipping active
}
procedure TForm1.btnCuttingClick(Sender: TObject);
begin
  { Get the raster layer (world image at index 0) }
  lp := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;

  { Get the triangular polygon from the vector layer, transform to raster's CS,
    and assign as the clipping boundary }
  lp.CuttingPolygon := TGIS_ShapePolygon( ll.GetShape( 1 ).CreateCopyCS( lp.CS ) );

  { Hide the vector layer so only the clipped raster is visible }
  ll.Active := False ;

  { Trigger complete map redraw to apply the clipping effect }
  GIS.InvalidateWholeMap ;
end;

{ btnZoomClick - Activate zoom navigation mode

  Switches the viewer from pan/drag mode to zoom mode, allowing the user to
  rectangle-zoom by clicking and dragging on the map.
}
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  { Set viewer to zoom interaction mode (versus TGIS_ViewerMode.Drag for panning) }
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;


{ FormCreate - Initialize map with raster layer and clipping polygon template

  Algorithm:
    1. Load world raster image (world_8km.jpg from sample data)
    2. Create in-memory vector layer for holding the clipping polygon
    3. Create a single triangular polygon shape by:
       a. Create new polygon geometry
       b. Lock shape to extent mode (use geographic coordinates)
       c. Add three vertices to form triangle
       d. Unlock shape (complete geometry definition)
    4. Zoom viewer to show full extent of both layers
    5. Store layer references in private fields for use by button handlers

  Data structure:
    - lp (TGIS_LayerPixel): raster layer, will be clipped
    - ll (TGIS_LayerVector): in-memory vector layer, contains clipping polygon
    - shp (TGIS_Shape): triangular polygon for clipping boundary
}
procedure TForm1.FormCreate(Sender: TObject);
var
  shp : TGIS_Shape ;  { The triangular clipping polygon shape }
begin
  { Load world raster image as base layer }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg');

  { Create in-memory vector layer to hold the clipping polygon }
  ll := TGIS_LayerVector.Create ;
  ll.Name := 'shape' ;
  GIS.Add(ll) ;

  { Create a new polygon shape in the vector layer }
  shp := ll.CreateShape(TGIS_ShapeType.Polygon);

  { Lock shape to extent mode: coordinates are geographic (longitude/latitude)
    not screen pixels, allowing direct assignment of map coordinates }
  shp.Lock(TGIS_Lock.Extent);

  { Define single ring (outer boundary) }
  shp.AddPart ;

  { Add three vertices to create equilateral triangle for clipping boundary }
  shp.AddPoint( TGIS_Utils.GisPoint( -5, 8 ) ) ;   { Top vertex }
  shp.AddPoint( TGIS_Utils.GisPoint( 40, 2 ) ) ;   { Right vertex }
  shp.AddPoint( TGIS_Utils.GisPoint( 20, -20 ) ) ; { Bottom vertex }

  { Unlock shape to finalize geometry (closes ring automatically) }
  shp.Unlock;

  { Zoom viewer to display full extent of all loaded layers }
  GIS.FullExtent ;
end;

end.
