//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Topology Sample - Demonstrates polygon set-algebra operations using TGIS_Topology.

  This sample loads two overlapping polygon shapes (A and B) from a shapefile
  and allows the user to compute the following topological combinations:

    A + B   : Union            - area covered by either A or B (or both)
    A * B   : Intersection     - area covered by both A and B
    A - B   : Difference       - area in A but not in B
    B - A   : Difference       - area in B but not in A
    A xor B : SymDifference    - area in A or B but not in both (exclusive OR)

  Results are displayed in a separate in-memory vector layer rendered in red
  with 50% transparency so the original shapes remain visible underneath.

  Key TatukGIS API classes used:
    TGIS_Topology           - engine that performs polygon boolean operations
    TGIS_TopologyCombineType - enumeration of the five combine modes
    TGIS_LayerVector        - in-memory vector layer used to display results
    TGIS_ShapePolygon       - strongly-typed polygon shape handle
    TGIS_ViewerWnd          - map viewer control embedded in the form
}
unit Unit1;

interface

uses
  System.Classes,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisTopology,      // TGIS_Topology and TGIS_TopologyCombineType
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main form for the Topology sample application.
    Demonstrates the five polygon boolean (set-algebra) operations supported
    by TGIS_Topology: Union, Intersection, Difference (A-B),
    Difference (B-A), and Symmetrical Difference (XOR). }
  TForm1 = class(TForm)
    { Map viewer control – renders all loaded layers }
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    { Topology operation buttons }
    btnAplusB: TButton;   // Union:               A + B
    btnAmultB: TButton;   // Intersection:        A * B
    btnAminusB: TButton;  // Difference:          A - B
    btnBminusA: TButton;  // Reverse difference:  B - A
    btnAxorB: TButton;    // Symmetrical diff:    A xor B
    procedure FormCreate(Sender: TObject);
    procedure btnAplusBClick(Sender: TObject);
    procedure btnAmultBClick(Sender: TObject);
    procedure btnAminusBClick(Sender: TObject);
    procedure btnBminusAClick(Sender: TObject);
    procedure btnAxorBClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    // The topology engine that performs boolean polygon operations
    topologyObj : TGIS_Topology ;
    // In-memory output layer; receives the result shape after each operation
    layerObj : TGIS_LayerVector ;
    // The two source polygons loaded from the shapefile (shape indices 1 and 2)
    shpA : TGIS_ShapePolygon ;
    shpB : TGIS_ShapePolygon ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{ TForm1.FormCreate
  Initialises the map viewer, loads the topology sample shapefile,
  extracts polygons A and B from it, and creates a transparent output layer
  that will display the result of each topology operation. }
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  // Create the topology engine (stateless; can be reused for multiple calls)
  topologyObj := TGIS_Topology.Create ;

  GIS.Lock;  // Suspend repaints while we modify the viewer

  // Open the bundled topology sample shapefile (contains two overlapping polygons)
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology.shp' ) ;

  // Retrieve the first (and only) layer just loaded
  ll := TGIS_LayerVector( GIS.Items[0] ) ;
  if not Assigned( ll ) then exit ;

  // MakeEditable returns a detached, editable copy of the shape.
  // This is required so the topology engine can safely read the geometry
  // without interfering with the underlying layer storage.
  shpA := TGIS_ShapePolygon( ll.GetShape( 1 ).MakeEditable );
  if not Assigned( shpA ) then exit ;

  shpB := TGIS_ShapePolygon( ll.GetShape( 2 ).MakeEditable );
  if not Assigned( shpB ) then exit ;

  // Create a blank in-memory vector layer to hold the topology result.
  // This layer sits on top of the source layer in the viewer stack.
  layerObj := TGIS_LayerVector.Create ;
  layerObj.Name := 'output' ;
  layerObj.Transparency := 50 ;        // 50% transparent so source shows through
  layerObj.Params.Area.Color := TGIS_Color.Red ;  // Result polygon fill colour

  GIS.Add( layerObj ) ;
  GIS.Unlock;        // Resume painting
  GIS.FullExtent ;   // Zoom to fit all layers
end;

{ TForm1.btnAplusBClick
  Performs Union (A + B): the resulting shape covers all area contained in
  either polygon A or polygon B, merging any overlapping regions. }
procedure TForm1.btnAplusBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  // Remove any previously computed result from the output layer
  layerObj.RevertShapes ;

  // Combine returns a new shape representing the result, or nil if it fails
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Union ) ;
  if Assigned( tmp ) then
  begin
    layerObj.AddShape( tmp ) ;  // Transfer result shape into the output layer
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;  // Trigger a full repaint
end;

{ TForm1.btnAmultBClick
  Performs Intersection (A * B): the resulting shape covers only the area
  that is simultaneously inside both polygon A and polygon B. }
procedure TForm1.btnAmultBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Intersection ) ;
  if Assigned( tmp ) then
  begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnAminusBClick
  Performs Difference (A - B): the resulting shape covers the area of polygon A
  with the overlapping portion of polygon B removed (i.e. A minus the intersection). }
procedure TForm1.btnAminusBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  // First argument is the "base" shape; second is the shape to subtract
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Difference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnBminusAClick
  Performs Reverse Difference (B - A): identical in logic to A-B but with the
  operand order swapped, so the area of polygon A is subtracted from polygon B. }
procedure TForm1.btnBminusAClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  // Note: operands are reversed compared to btnAminusBClick
  tmp := topologyObj.Combine( shpB, shpA, TGIS_TopologyCombineType.Difference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnAxorBClick
  Performs Symmetrical Difference (A xor B): the resulting shape covers all area
  that belongs to exactly one of A or B, i.e. Union minus Intersection.
  This is the GIS equivalent of an exclusive-OR gate applied to two polygons. }
procedure TForm1.btnAxorBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.SymmetricalDifference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.FormDestroy
  Releases the topology engine when the form is closed.
  The shpA/shpB editable copies are owned by the DK and freed automatically;
  layerObj is owned by the GIS viewer and freed when the viewer is destroyed. }
procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(topologyObj) then topologyObj.Free;
end;

end.
