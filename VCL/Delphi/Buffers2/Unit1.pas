//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Buffers2 - Advanced buffer operation with spatial intersection query.

  This sample extends the Buffers1 concept by demonstrating how to combine
  TGIS_Topology.MakeBuffer with a spatial search to find all features that
  intersect the resulting buffer polygon.

  What the sample shows:
    - Loading a real-world county shapefile (California counties) into the viewer
    - Creating a separate in-memory overlay layer (TGIS_LayerVector) to hold
      the buffer polygon, styled with a semi-transparent yellow fill
    - Using TGIS_LayerVector.FindFirst with an attribute filter (NAME='Merced')
      to locate a specific county as the buffer source shape
    - Calling TGIS_Topology.MakeBuffer to generate a buffer around that county
      (distance controlled by a track-bar; value / 100 converts the integer
      position to degrees on a geographic/planar CRS)
    - Using TGIS_LayerVector.FindFirst / FindNext with the buffer's bounding
      box (Extent) as a spatial pre-filter, then refining with
      TGIS_Shape.IsCommonPoint to identify counties that truly overlap the buffer
    - Visually marking intersecting counties blue and listing their names in
      a Memo control
    - Using a TTimer to debounce rapid track-bar changes so the expensive
      buffer + intersection query only runs after the slider has been idle
      for the timer interval

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd      - the main visual map control
    TGIS_LayerVector    - a file-backed or in-memory vector layer
    GisCreateLayer      - factory function that creates a typed layer object
                          appropriate for the file format being opened
    TGIS_Topology       - utility class for spatial operations (MakeBuffer, etc.)
    TGIS_Shape          - a single geographic feature (point, line, or polygon)
    FindFirst / FindNext - iterator pair for querying shapes within a layer;
                           FindFirst accepts a bounding-box extent and/or
                           an attribute expression string
    IsCommonPoint       - precise overlap test: returns True if the two shapes
                           share at least one point (i.e. they intersect)
    MakeEditable        - returns an editable copy of a read-only shape so that
                           its display parameters (colour, etc.) can be modified
    IgnoreShapeParams   - when False, per-shape Params override layer defaults,
                           which allows individual shapes to be coloured differently
    lb.CS := GIS.CS     - ensures the buffer layer uses the same coordinate
                           system as the viewer so spatial operations are coherent
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisLayer,
  GisParams,
  GisTopology,
  GisRegistredLayers,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;        // Main map viewer control
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;     // Shows the current buffer distance in km
    TrackBar1: TTrackBar;       // Controls buffer distance (0..200, divided by 100 = degrees)
    Timer1: TTimer;             // Debounce timer: delays the buffer recalculation
    btnPlus: TToolButton;       // Increases track-bar position by 5 steps
    btnMinus: TToolButton;      // Decreases track-bar position by 5 steps
    ImageList1: TImageList;
    Memo1: TMemo;               // Lists the names of counties intersecting the buffer
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnMinusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{ FormCreate
  Sets up the initial map state when the form is first displayed.

  Steps:
    1. Use GisCreateLayer to open the California Counties shapefile as a named
       layer ("counties").  GisCreateLayer is a factory that selects the correct
       layer class for the file format automatically.
    2. Lock the viewer, add the county layer, then create an empty in-memory
       "buffer" layer (70 % transparent, yellow fill).
    3. Assign the viewer's coordinate system (CS) to the buffer layer so that
       spatial operations between the two layers are coherent.
    4. Unlock, add the buffer layer, and zoom to the full data extent. }
procedure TForm1.FormCreate(Sender: TObject);
var
  la : TGIS_Layer ;      // the file-backed county layer
  lb : TGIS_LayerVector ; // in-memory buffer overlay layer
begin
  la := GisCreateLayer(
          'counties',
          TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp'
        ) ;
  GIS.Lock;
  GIS.Add( la ) ;

  // Create an overlay layer that will receive the computed buffer polygon.
  // 70 % transparency lets the county boundaries show through.
  lb := TGIS_LayerVector.Create ;
  lb.Name := 'buffer' ;
  lb.Transparency := 70 ;
  lb.Params.Area.Color := TGIS_Color.Yellow ;
  // Sharing the viewer's CS ensures buffer distances are interpreted in the
  // same projection as the source data (geographic degrees here).
  lb.CS := GIS.CS ;
  GIS.Unlock;
  GIS.Add( lb ) ;

  GIS.FullExtent ;
end;

{ Timer1Timer
  Performs the buffer computation and spatial intersection query.

  This handler is triggered by the debounce timer (started by TrackBar1Change).
  Immediately disabling the timer at entry ensures it fires only once per
  slider-movement gesture rather than on every intermediate tick.

  Algorithm:
    1. Retrieve the county and buffer layers by name via GIS.Get.
    2. Find the "Merced" county shape using FindFirst with an attribute filter.
    3. Use TGIS_Topology.MakeBuffer to compute a polygon expanded by
       TrackBar1.Position / 100 units (degrees in the planar/geographic CRS).
    4. Add the buffer polygon to the buffer overlay layer.
    5. Perform a two-stage spatial query on the county layer:
         Stage 1 - FindFirst(buf.Extent): candidate shapes whose bounding boxes
                   overlap the buffer's bounding box (fast, index-assisted).
         Stage 2 - buf.IsCommonPoint(tmp): precise geometric intersection test.
    6. Shapes that pass both stages are coloured blue and their names are added
       to the Memo.  MakeEditable is needed before changing per-shape Params
       because shapes retrieved from a file-backed layer are read-only.
    7. GIS.InvalidateWholeMap refreshes the display in the finally block. }
procedure TForm1.Timer1Timer(Sender: TObject);
var
  ll  : TGIS_LayerVector ;   // the county source layer
  lb  : TGIS_LayerVector ;   // the buffer overlay layer
  shp : TGIS_Shape       ;   // the Merced county shape (buffer source)
  tmp : TGIS_Shape       ;   // iterator shape during FindFirst/FindNext loop
  buf : TGIS_Shape       ;   // the computed buffer polygon stored in lb
  tpl : TGIS_Topology    ;   // topology engine used to compute the buffer
begin
  // Disable the timer immediately so it does not fire again while we work.
  Timer1.Enabled := False ;

  try
    // Retrieve layers by name.  GIS.Get returns nil if the name is not found.
    ll := TGIS_LayerVector( GIS.Get( 'counties' ) ) ;
    if not Assigned( ll ) then exit ;
    lb := TGIS_LayerVector( GIS.Get( 'buffer' ) ) ;
    if not Assigned( lb ) then exit ;

    // FindFirst with an attribute filter locates the Merced county shape.
    // TGIS_Utils.GisWholeWorld passes the full-world extent as a spatial
    // envelope so that no shapes are excluded by bounding-box pre-filtering.
    shp := ll.FindFirst( TGIS_Utils.GisWholeWorld, 'NAME=''Merced''' ) ;

    if not Assigned( shp ) then exit ;

    tpl := TGIS_Topology.Create ;
    try
      lb.RevertShapes ;  // discard any previously computed buffer polygon
      // MakeBuffer distance is in the layer's native units (degrees here).
      // Dividing by 100 converts the integer track-bar value to a fractional degree.
      tmp := tpl.MakeBuffer( shp, TrackBar1.Position / 100 ) ;
      if Assigned( tmp ) then begin
        buf := lb.AddShape( tmp ) ;  // transfer to the overlay layer
        tmp.Free ;
      end else
        buf := nil ;
    finally
      tpl.Free ;
    end ;

    // ── Intersection query ─────────────────────────────────────────────────
    // Only proceed if the buffer was successfully created.
    if not Assigned( buf ) then exit ;

    ll := TGIS_LayerVector( GIS.Get( 'counties' ) ) ;
    // IgnoreShapeParams = False allows per-shape colour overrides to be applied.
    // When True (default after RevertShapes), all shapes use the layer default.
    ll.IgnoreShapeParams := False ;
    if not Assigned( ll ) then exit ;
    ll.RevertShapes ;  // reset per-shape style overrides from the previous run
    Memo1.Clear ;
    Memo1.Lines.BeginUpdate ;

    // Stage 1: FindFirst with buf.Extent as a bounding-box pre-filter.
    // Only shapes whose extent overlaps the buffer's bounding box are returned.
    tmp := ll.FindFirst( buf.Extent );
    while Assigned( tmp ) do begin
      // Stage 2: precise geometric test - does the shape share any point with
      // the buffer polygon?
      if buf.IsCommonPoint( tmp ) then begin
        // MakeEditable returns a writable copy so we can change Params.Area.Color.
        // Without this call, modifying Params on a read-only shape has no effect.
        tmp := tmp.MakeEditable ;
        Memo1.Lines.Add( tmp.GetField( 'name' ) ) ;
        tmp.Params.Area.Color := TGIS_Color.Blue ;
      end;
      tmp := ll.FindNext ;  // advance to the next candidate shape
    end ;
    Memo1.Lines.EndUpdate ;

  finally
    // Always redraw the map, even if an early exit occurred above.
    GIS.InvalidateWholeMap ;
  end ;

end;

{ TrackBar1Change
  Debounces rapid slider movement by resetting and re-enabling the timer.

  When the user drags the slider quickly, this event fires many times per
  second.  Instead of running the expensive buffer query on every tick, we
  restart the timer so that the query only runs after the slider has been
  idle for one timer interval (250 ms by default). }
procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Timer1.Enabled := False ;
  // Show the current distance in the status bar while dragging.
  StatusBar1.SimpleText := IntToStr( TrackBar1.Position ) + ' km' ;
  Timer1.Enabled := True ;
end;

{ btnPlusClick
  Increases the buffer distance by 5 track-bar units and immediately
  triggers a buffer recompute by calling Timer1Timer directly. }
procedure TForm1.btnPlusClick(Sender: TObject);
begin
  TrackBar1.Position := TrackBar1.Position + 5 ;
  Timer1Timer( Self ) ;
end;

{ btnMinusClick
  Decreases the buffer distance by 5 track-bar units and immediately
  triggers a buffer recompute by calling Timer1Timer directly. }
procedure TForm1.btnMinusClick(Sender: TObject);
begin
  TrackBar1.Position := TrackBar1.Position - 5 ;
  Timer1Timer( Self ) ;
end;

end.
