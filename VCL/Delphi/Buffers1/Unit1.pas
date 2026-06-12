//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Buffers1 sample — demonstrates spatial buffer operations for proximity analysis.

  What the sample shows:
    - Loading vector shapefiles into the GIS viewer
    - Creating in-memory vector layer to hold buffer results
    - Letting user click on shapes to select them as buffer source
    - Using TGIS_Topology.MakeBuffer to compute buffer polygons around shapes
    - Interactive buffer distance control via trackbar (range -50 to +50 km)
    - Negative buffer values produce inward/erosion buffers instead of expansion
    - Adding result shapes to buffer layer with automatic view refresh
    - Hit-testing with GIS.Locate to find clicked shapes
    - Converting pixel coordinates to map coordinates with ScreenToMap
    - Clearing previous buffer results with RevertShapes before adding new ones

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd          - main visual map control
    TGIS_LayerVector        - in-memory or file-backed vector layer
    TGIS_Topology           - spatial operations (MakeBuffer, Intersection, Union, etc.)
    TGIS_Shape              - individual geographic feature (point, line, polygon)
    TGIS_Topology.MakeBuffer() - compute proximity buffer around shape
    GIS.Locate()            - hit-test at point to find topmost shape
    GIS.ScreenToMap()       - convert screen pixels to geographic coordinates
    TGIS_LayerVector.RevertShapes() - clear all shapes from layer
    TGIS_LayerVector.Add() - add result shape to layer
}

unit Unit1;


interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main form for the Buffers1 sample.
    Loads a topology shapefile, lets the user click a shape to select it,
    then draws a buffer polygon around it whose distance is set by a slider. }
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;         // Main map viewer control
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    TrackBar1: TTrackBar;        // Controls buffer distance (-50..+50 km)
    btnPlus: TToolButton;        // Increases track-bar position by 1
    btnMinus: TToolButton;       // Decreases track-bar position by 1
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnMinusClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  { shp_id holds the unique identifier (Uid) of the currently selected shape.
    It is set when the user clicks on the map and is read back in
    TrackBar1Change to retrieve the correct shape for buffering. }
  shp_id : Integer;

implementation

uses
  GisAllLayers ;
{$R *.DFM}


{ FormCreate
  Sets up the initial map state when the form is first displayed.

  Steps:
    1. Lock the viewer to suppress intermediate repaints during setup.
    2. Open the topology sample shapefile; this becomes layer index 0.
    3. Pre-select shape #2 as the default buffer target.
    4. Create an empty in-memory vector layer named "buffer" that will
       receive the computed buffer polygon.  It is given 50 % transparency
       and a red fill so it is visually distinct from the source data.
    5. Unlock the viewer and zoom to the full data extent. }
procedure TForm1.FormCreate(Sender: TObject);
var
  lb : TGIS_LayerVector ;
begin
  // open a project
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology.shp' ) ;
  shp_id := 2;
  // create a layer for buffer
  lb := TGIS_LayerVector.Create ;
  lb.Name := 'buffer' ;
  lb.Transparency := 50 ;            // 50 % transparent so the source shapes show through
  lb.Params.Area.Color := TGIS_Color.Red ;
  GIS.Add( lb ) ;
  GIS.Unlock;
  GIS.FullExtent ;
end;

{ btnPlusClick
  Increments the track-bar position by one step.
  The TrackBar1Change event fires automatically as a result. }
procedure TForm1.btnPlusClick(Sender: TObject);
begin
  // change bar position and recalculate buffer
  TrackBar1.Position := TrackBar1.Position + 1 ;
end;

{ btnMinusClick
  Decrements the track-bar position by one step.
  The TrackBar1Change event fires automatically as a result. }
procedure TForm1.btnMinusClick(Sender: TObject);
begin
  // change bar position and recalculate buffer
  TrackBar1.Position := TrackBar1.Position - 1 ;
end;

{ GISMouseDown
  Handles mouse clicks on the map to select the shape that will be buffered.

  The procedure:
    1. Guards against clicks during painting or on an empty viewer.
    2. Converts the screen pixel position to map coordinates via ScreenToMap.
    3. Calls GIS.Locate to find the nearest shape within a 5-pixel tolerance
       (converted to map units via GIS.Zoom).
    4. Remembers the shape's Uid in shp_id and briefly flashes it to give
       visual feedback to the user. }
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    ptg : TGIS_Point ;
    shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // locate a shape after click
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision

  // remember id to use buffer on selected shape
  if shp <> nil then
  begin
      shp_id := shp.Uid ;
      shp.Flash ;   // briefly highlights the shape to confirm selection
  end;
end;

{ TrackBar1Change
  Recomputes the buffer polygon each time the user moves the track bar.

  Algorithm:
    1. Retrieve the source layer (index 0) and the "buffer" overlay layer.
    2. Fetch the previously selected shape by its stored Uid.
    3. Create a TGIS_Topology instance and call MakeBuffer.
       - The distance is TrackBar1.Position * 1000 metres (i.e. position units
         are kilometres; negative values produce an inward / erosion buffer).
    4. Clear the buffer layer (RevertShapes) then add the new result shape.
    5. Recalculate extents for all affected layers and refresh the view. }
procedure TForm1.TrackBar1Change(Sender: TObject);
var
  ll  : TGIS_LayerVector ;   // source layer containing the shapes
  lb  : TGIS_LayerVector ;   // overlay layer that displays the buffer
  shp : TGIS_Shape       ;   // the shape being buffered
  tmp : TGIS_Shape       ;   // temporary buffer result returned by MakeBuffer
  tpl : TGIS_Topology    ;   // topology engine used to compute the buffer
begin
  ll := TGIS_LayerVector(GIS.Items[0]) ;
  if not Assigned( ll ) then exit ;

  lb := TGIS_LayerVector( GIS.Get( 'buffer' ) ) ;
  if not Assigned( lb ) then exit ;

  shp := ll.GetShape( shp_id ) ;
  if not Assigned( shp ) then exit ;

  // create a buffer using topology
  tpl := TGIS_Topology.Create ;
  try
    lb.RevertShapes ;  // discard any previously computed buffer shape
    // MakeBuffer returns a new polygon expanded by the given distance in metres.
    // Multiplying by 1000 converts the track-bar's kilometre value to metres.
    tmp := tpl.MakeBuffer( shp, TrackBar1.Position * 1000 ) ;
    if Assigned( tmp ) then
    begin
      lb.AddShape( tmp ) ;  // transfer ownership to the buffer layer
      tmp.Free ;
    end ;
    // check extents
    ll.RecalcExtent ;
    lb.RecalcExtent ;
    GIS.RecalcExtent ;
    GIS.FullExtent ;
  finally
    tpl.Free ;
  end ;
end;

end.
