//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Triangulation Sample – Demonstrates Delaunay triangulation and Voronoi diagrams.

  This sample opens a point shapefile (Polish cities) and uses two specialised
  TGIS_LayerVector subclasses from GisTriangulation to compute:

    Delaunay Triangulation
      A triangulation of a set of points such that no point lies inside the
      circumscribed circle of any triangle.  Useful for TIN (Triangulated
      Irregular Network) surface modelling and proximity analysis.

    Voronoi Diagram
      A partitioning of the plane into regions, one per input point, where
      each region contains all locations closer to that point than to any
      other input point.  The Voronoi diagram is the geometric dual of the
      Delaunay triangulation.

  After generation, the result layer is colour-graduated by polygon area
  (GIS_AREA attribute) using a white→red or white→blue gradient rendered
  across 10 equal-interval zones.  This highlights relative cell/triangle sizes.

  User interaction:
    - Click a point on the map to display its attributes in the Attributes panel
    - Radio buttons select Delaunay vs Voronoi before generation
    - "Generate" adds the result layer; duplicate names are rejected with a warning

  Key TatukGIS API classes used:
    TGIS_LayerDelaunay       - generates and stores a Delaunay triangulation
    TGIS_LayerVoronoi        - generates and stores a Voronoi diagram
    TGIS_LayerVector         - base class; ImportLayer() copies source point data
    TGIS_ControlAttributes   - side panel that shows shape attribute data on click
    TGIS_ControlLegend       - layer legend / style control panel
    TGIS_ViewerWnd           - VCL map viewer control
    GisTriangulation unit    - provides TGIS_LayerDelaunay and TGIS_LayerVoronoi
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes,  // TGIS_ControlAttributes
  Vcl.GisControlLegend,      // TGIS_ControlLegend
  Vcl.GisViewerWnd;

type
  { Main form for the Triangulation sample application.
    Demonstrates Delaunay triangulation and Voronoi diagram generation
    using TGIS_LayerDelaunay and TGIS_LayerVoronoi. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    { Map viewer – renders all loaded layers }
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ImageList1: TImageList;
    Panel1: TPanel;
    { Side panel: displays the attribute table row for the shape clicked on the map }
    GIS_Attributes: TGIS_ControlAttributes;
    { Group box containing the Voronoi/Delaunay radio buttons and layer name field }
    grpbxResult: TGroupBox;
    rdbtnVoronoi: TRadioButton;
    rdbtnDelaunay: TRadioButton;
    btnGenerate: TButton;
    lblName: TLabel;
    edtName: TEdit;
    { Legend control – shows layer list and allows style editing }
    GIS_ControlLegend1: TGIS_ControlLegend;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure rdbtnVoronoiClick(Sender: TObject);
    procedure rdbtnDelaunayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  GisTriangulation ;  // TGIS_LayerDelaunay, TGIS_LayerVoronoi

{ TForm1.FormCreate
  Opens the Polish city point shapefile and customises its rendering style.
  A second "selected" param set is also added so that clicked shapes get a
  distinct blue fill when shown in the Attributes control. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Open city point data – this layer provides the input point set for triangulation
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\city.shp' ) ;

  // Customise the default rendering style for the city point layer
  with TGIS_LayerVector( GIS.Items[0] ) do
  begin
    Params.Marker.Color         := TGIS_Color.FromRGB($4080FF) ;  // Warm blue marker colour
    Params.Marker.OutlineWidth  := 2 ;
    Params.Marker.Style         := TGIS_MarkerStyle.Circle ;

    // Add a second param set named "selected" to style shapes shown in
    // the Attributes panel differently from the default.
    ParamsList.Add ;
    Params.Style := 'selected' ;
    Params.Area.OutlineWidth := 1 ;
    Params.Area.color := TGIS_Color.Blue ;
  end ;

  // Refresh the legend to reflect the new layer styles
   GIS_ControlLegend1.Update ;
end;

{ TForm1.GISMouseDown
  Hit-tests the map on mouse press to find the nearest shape and displays
  its attribute data in the GIS_Attributes side panel.

  ScreenToMap converts pixel coordinates to geographic (map) coordinates.
  Locate searches all layers for the nearest shape within a tolerance of
  5 screen pixels (converted to map units by dividing by the zoom factor). }
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;   // Nothing loaded yet
  if GIS.InPaint then exit ;   // Avoid reentrancy during repainting

  // Convert screen pixel position to geographic coordinates
  ptg := GIS.ScreenToMap( Point(x, y ) );

  // Locate the nearest shape within a 5-pixel tolerance
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision
  if shp <> nil then
    GIS_Attributes.ShowShape(shp) ;  // Populate the attribute panel
end;

{ TForm1.rdbtnDelaunayClick
  Pre-fills the output layer name when the user selects Delaunay mode.
  The name is used by btnGenerateClick to set the new layer's name and
  to detect duplicate layers. }
procedure TForm1.rdbtnDelaunayClick(Sender: TObject);
begin
  edtName.Text := 'Delaunay' ;
end;

{ TForm1.rdbtnVoronoiClick
  Pre-fills the output layer name when the user selects Voronoi mode. }
procedure TForm1.rdbtnVoronoiClick(Sender: TObject);
begin
  edtName.Text := 'Voronoi' ;
end;

{ TForm1.btnFullExtentClick
  Zooms the viewer so that all loaded layers fit within the visible area. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ TForm1.btnGenerateClick
  Creates either a TGIS_LayerVoronoi or TGIS_LayerDelaunay layer, imports
  the city point data as its input, configures a graduated colour-render
  style based on polygon area, and adds it to the viewer.

  ImportLayer copies all point features from the source layer (GIS.Items[0])
  into the new triangulation layer and computes the triangulation/diagram on
  the fly.  After the call the layer contains fully formed polygon shapes.

  The GIS_AREA attribute (computed automatically by the triangulation engine)
  is used to drive a white-to-colour gradient rendered over 10 equal zones,
  giving an immediate visual impression of cell/triangle area variation. }
procedure TForm1.btnGenerateClick(Sender: TObject);
var
  lVrn : TGIS_LayerVector ;
begin
  // Prevent overwriting an existing layer with the same name
  if gis.Get( edtName.Text ) <> nil then
  begin
    ShowMessage( 'Result layer already exists. Use different name.') ;
    exit ;
  end ;

  // Instantiate the correct layer type based on the radio selection
  if rdbtnVoronoi.Checked then
    lVrn := TGIS_LayerVoronoi.Create   // Voronoi diagram
  else
    lVrn := TGIS_LayerDelaunay.Create ; // Delaunay triangulation

  lVrn.Name := edtName.Text ;

  // ImportLayer reads all point features from the source layer and uses them
  // as the input seed set for the triangulation/diagram computation.
  // TGIS_ShapeType.Unknown lets the engine infer the output shape type automatically.
  lVrn.ImportLayer( TGIS_LayerVector( GIS.Items[ 0 ] ), GIS.Extent,
                    TGIS_ShapeType.Unknown, '', False
                   ) ;

  lVrn.Transparency := 60 ;  // Make the result layer semi-transparent

  // Configure graduated colour rendering keyed on the built-in GIS_AREA attribute.
  // GIS_AREA holds the area of each output polygon in map units squared.
  lVrn.Params.Render.Expression := 'GIS_AREA' ;
  lVrn.Params.Render.MinVal     := 10000000 ;     // ~10 km² lower bound
  lVrn.Params.Render.MaxVal     := 1300000000 ;   // ~1300 km² upper bound
  lVrn.Params.Render.StartColor := TGIS_Color.White ;
  // Use red for Voronoi, blue for Delaunay to distinguish them visually
  if rdbtnVoronoi.Checked then
    lVrn.Params.Render.EndColor  := TGIS_Color.Red
  else
    lVrn.Params.Render.EndColor := TGIS_Color.Blue ;
  lVrn.Params.Render.Zones      := 10 ;           // Divide the range into 10 colour zones
  // TGIS_Color.RenderColor instructs the renderer to substitute the computed
  // gradient colour for the polygon fill during painting.
  lVrn.Params.Area.Color        := TGIS_Color.RenderColor ;

  // Inherit the coordinate system from the source layer
  lVrn.CS := GIS.CS ;

  GIS.Add( lVrn ) ;
  GIS.InvalidateWholeMap ;
  GIS_ControlLegend1.Update ;  // Refresh legend to show the new layer
end;

{ TForm1.btnZoomInClick
  Doubles the current zoom factor, zooming into the centre of the map. }
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ TForm1.btnZoomOutClick
  Halves the current zoom factor, zooming out from the centre of the map. }
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
