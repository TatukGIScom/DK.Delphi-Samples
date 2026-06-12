//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Snap Sample — Demonstrates point tracking and snap-to-geometry functionality
  for constraining moving objects to the nearest feature.

  Key concepts illustrated:
    - Point tracking: simulating movement of a point object (e.g., GPS-tracked vehicle)
    - Snap-to-geometry: automatically constraining a moving point to the nearest
      feature in a reference layer (e.g., moving along streets instead of cross-country)
    - TGIS_Shape.SetPosition() with and without target layer parameter
    - Difference between free movement (direct coordinates) and snapped movement
      (coordinates projected onto nearest street/feature)
    - Timer-based animation for simulating continuous movement

  User workflow:
    1. "Track Without Snapping" - simulates free-form point movement
       Police car icon moves in arbitrary direction, independent of streets
    2. "Track With Snapping" - simulates GPS-constrained tracking
       Police car icon follows the nearest street, snapping to street network

  Data:
    - TIGER street network (San Bernardino, CA)
    - Police car symbol icon

  Key API methods:
    - TGIS_Shape.SetPosition(point, nil, tolerance) - move point freely
    - TGIS_Shape.SetPosition(point, layer, tolerance) - move point snapped to layer
      The tolerance parameter defines the snap search radius in map coordinates
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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    btnWithoutSnapping: TButton;
    btnWithSnapping: TButton;
    tmrWithSnapping: TTimer;
    tmrWithoutSnapping: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnWithoutSnappingClick(Sender: TObject);
    procedure tmrWithoutSnappingTimer(Sender: TObject);
    procedure btnWithSnappingClick(Sender: TObject);
    procedure tmrWithSnappingTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    shpPolice   : TGIS_Shape ; // police shape
    cntPoint    : Integer    ; // number of evaluated points
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the sample: loads the street network, creates a tracking points layer,
  and sets up a police car icon for movement simulation.

  Steps:
    1. Load TIGER street network shapefile (reference layer for snapping)
    2. Create in-memory tracking points layer to hold the police car symbol
    3. Create and style the police car point shape
}
procedure TForm1.FormCreate(Sender: TObject);
var
 ll : TGIS_LayerVector ;
begin
  GIS.Lock;

  { Load the TIGER street network (San Bernardino area) as the base reference layer.
    This layer will be used for snap-to-geometry in the snapping mode. }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload+
            '\World\Countries\USA\States\California\San Bernardino\TIGER\tl_2008_06071_edges_trunc.shp'
           ) ;

  { Zoom in 5x for better visibility of street details }
  GIS.Zoom := GIS.Zoom * 5 ;

  { Center the viewport on San Bernardino area (34.0629, -117.0208) }
  GIS.CenterViewport( TGIS_Utils.GisPoint( -117.0208, 34.0629) );

  { Create an in-memory vector layer to hold tracking points (police car movements) }
  ll := TGIS_LayerVector.Create ;
  ll.Path := 'trackingpoints' ;
  ll.CS := GIS.CS ;
  GIS.Add( ll ) ;

  { Disable label allocator and caching for real-time point movement performance }
  ll.Params.Labels.Allocator := False ;
  ll.CachedPaint := False ;
  GIS.Unlock;

  { Create a point shape for the police car icon }
  shpPolice := ll.CreateShape( TGIS_ShapeType.Point ) ;

  { Load and assign the police car bitmap symbol }
  shpPolice.Params.Marker.Symbol :=
            SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\police.bmp?TRUE' ) ;

  { Set symbol size (negative = screen pixels, not map coordinates) }
  shpPolice.Params.Marker.Size := -13 ;

  { Configure label appearance (ID number "112") }
  shpPolice.Params.Labels.OutlineWidth := 0  ;
  shpPolice.Params.Labels.Pattern      := TGIS_BrushStyle.Clear ;
  shpPolice.Params.Labels.Position     := [TGIS_LabelPosition.DownCenter] ;
  shpPolice.Params.Labels.Value        := '112' ;
end;


{
  FormDestroy
  Cleans up resources: closes the viewer which releases all loaded layers and shapes.
}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  { Close the viewer - automatically frees all layers and shapes }
  GIS.Close ;
end;


{
  btnWithoutSnappingClick
  Initiates the free-form point tracking (no snapping to streets).
  Resets the police car to the viewport center and starts the movement timer.
}
procedure TForm1.btnWithoutSnappingClick(Sender: TObject);
begin
  { Disable buttons during tracking animation }
  btnWithoutSnapping.Enabled := False ;
  btnWithSnapping.Enabled    := False ;

  { Position the police car at the viewport center }
  shpPolice.SetPosition( Gis.Center, nil, 0 ) ;

  { Reset movement counter and start the free movement timer }
  cntPoint := 0 ;
  tmrWithoutSnapping.Enabled := True ;
end;

{
  tmrWithoutSnappingTimer
  Animates the police car movement without snapping.
  The point moves in an arbitrary direction (typically would be GPS tracking in a real app).
  Runs for 120 frames then stops.
}
procedure TForm1.tmrWithoutSnappingTimer(Sender: TObject);
var
  ptg : TGIS_Point ;
begin
  { Disable timer to prevent recursive calls }
  tmrWithoutSnapping.Enabled := False ;

  { Calculate next position (arbitrary direction)
    In a real application, this would read from a GPS device }
  ptg.X := shpPolice.Centroid.X - 0.00020 ;
  ptg.Y := shpPolice.Centroid.Y + 0.00010 ;

  { Move the icon to the new position WITHOUT snapping to streets.
    SetPosition(point, nil, tolerance) = free movement mode.
    The second parameter (nil) indicates no target layer for snapping. }
  shpPolice.Lock( TGIS_Lock.Projection ) ;
  shpPolice.SetPosition( ptg, nil, 0 ) ;
  shpPolice.Unlock ;

  { Increment frame counter }
  Inc( cntPoint ) ;

  { Continue animation for 120 frames, then stop and re-enable buttons }
  if cntPoint < 120 then
    tmrWithoutSnapping.Enabled := True
  else begin
    btnWithoutSnapping.Enabled := True ;
    btnWithSnapping.Enabled    := True ;
  end ;
end;


{
  btnWithSnappingClick
  Initiates point tracking WITH snap-to-geometry (snapped to nearest street).
  Resets the police car to the viewport center and starts the snapped movement timer.
}
procedure TForm1.btnWithSnappingClick(Sender: TObject);
begin
  { Disable buttons during tracking animation }
  btnWithoutSnapping.Enabled := False ;
  btnWithSnapping.Enabled    := False ;

  { Position the police car at the viewport center (start position) }
  shpPolice.SetPosition( Gis.Center, nil, 0 ) ;

  { Reset movement counter and start the snapped movement timer }
  cntPoint := 0 ;
  tmrWithSnapping.Enabled := True ;
end;


{
  tmrWithSnappingTimer
  Animates the police car movement WITH snap-to-geometry.
  The point moves in an arbitrary direction but is automatically snapped to the
  nearest street feature in the street layer.
  Runs for 120 frames then stops.

  Key difference from free movement:
    SetPosition(point, layer, tolerance) snaps the point to the nearest feature
    within the tolerance distance. Without snapping, the point moves freely.
}
procedure TForm1.tmrWithSnappingTimer(Sender: TObject);
var
  ptg : TGIS_Point ;
begin
  { Disable timer to prevent recursive calls }
  tmrWithSnapping.Enabled := False ;

  { Calculate next position (arbitrary direction)
    In a real application, this would read from a GPS device }
  ptg.X := shpPolice.Centroid.X - 0.00020  ;
  ptg.Y := shpPolice.Centroid.Y + 0.00010 ;
     { Alternative: read from GPS: ptg := GIS.CS.FromWgs84( GisPoint( objGps.Longitude, objGps.Latitude ) ) ; }

  { Move the icon to the new position WITH snapping to streets.
    SetPosition(point, layer, tolerance) snaps to the nearest feature.
    layer = GIS.Items[0] = the TIGER street network (reference layer)
    tolerance = 0.05 = search radius in map coordinates for finding nearest street }
  shpPolice.Lock( TGIS_Lock.Projection ) ;
  shpPolice.SetPosition( ptg,
                         TGIS_LayerVector( GIS.Items[0] ),
                         0.05 ) ;
  shpPolice.Unlock ;

  { Increment frame counter }
  Inc( cntPoint ) ;

  { Continue animation for 120 frames, then stop and re-enable buttons }
  if cntPoint < 120 then
    tmrWithSnapping.Enabled := True
  else begin
    btnWithoutSnapping.Enabled := True ;
    btnWithSnapping.Enabled    := True ;
  end ;
end;


end.
