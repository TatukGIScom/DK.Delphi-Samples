//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  PixelEdit - demonstrates how to read and modify raster (pixel) layer data
  programmatically using TatukGIS.

  Five operations are shown, each triggered by a dedicated button:

  1. Terrain profile (btnProfile)
     Iterates over every pixel that lies under a polyline shape, reading the
     grid elevation value (px.Value) and the cumulative distance along the
     line (px.Distance).  The values are zeroed out as a side effect to show
     in-place pixel editing.
     API: TGIS_LayerPixel.Loop(distance_step, shape, editable)

  2. Grid min/max (btnMinMax)
     Finds the pixels with the lowest and highest elevation values inside a
     polygon area.  A temporary vector layer with cross markers is added at
     the two extreme locations so they are visible in the viewer.
     API: TGIS_LayerPixel.Loop(extent, step, shape, mode, editable)

  3. Bitmap average colour (btnAvargeColor)
     Reads every pixel of a satellite image that falls inside a country
     polygon (Spain, shape #679) to compute the average R, G, B colour.
     It then writes that flat colour back into every pixel of the same
     region, demonstrating read-then-write iteration.
     API: px.Color  (TGIS_PixelItem.Color)

  4. Create new JPG (btnCreateBitmap)
     Creates a brand-new JPEG raster layer spanning the entire world in
     WGS-84 (EPSG:4326), then uses LockPixels/UnlockPixels to paint a
     square region red by writing directly into the raw bitmap buffer.
     API: TGIS_LayerJPG.Build(), TGIS_LayerPixel.LockPixels(),
          TGIS_LayerPixelLock.Bitmap[], TGIS_LayerPixelLock.BitmapPos()

  5. Create new GRD (btnCreateGrid)
     Creates a brand-new ESRI Grid raster layer, then fills a region with
     random elevation values using the low-level Grid[][] accessor.
     API: TGIS_LayerGRD.Build(), TGIS_LayerPixelLock.Grid[][]

  Key TatukGIS API concepts shown here:
    - TGIS_LayerPixel      : base class for raster layers
    - TGIS_LayerJPG        : JPEG raster layer subclass
    - TGIS_LayerGRD        : ESRI Grid raster layer subclass
    - TGIS_PixelItem       : represents a single raster cell during iteration;
                             exposes Value (float), Color (TGIS_Color),
                             Center (geographic point), Distance (profile)
    - Loop()               : enumerator-based iteration over raster cells
                             (read-only or editable depending on last parameter)
    - LockPixels()         : locks a rectangular region for direct raw-buffer
                             access; must be paired with UnlockPixels()
    - TGIS_LayerPixelLock  : holds the locked pixel data and its bounds
    - TGIS_CSFactory.ByEPSG: creates a coordinate system from an EPSG code
    - GIS.Lock/Unlock       : suspends/resumes map repainting for batch updates
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  GisAllLayers,
  GisUtils,
  GisTypes,
  GisTypesUI,
  GisCsFactory,
  GisLayerVector,
  GisLayerPixel,
  GisLayerJpg,
  GisLayerGrd,
  VCL.GisViewerWnd,
  VCL.GisControlLegend ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;           // TatukGIS map viewer control
    ToolBar1: TToolBar;            // Toolbar (houses action buttons below)
    btnProfile: TButton;           // Reads elevation profile along a polyline
    btnMinMax: TButton;            // Finds min/max elevation inside a polygon
    btnAvargeColor: TButton;       // Computes and applies average colour in a region
    btnCreateBitmap: TButton;      // Creates and fills a new JPEG raster layer
    btnCreateGrid: TButton;        // Creates and fills a new ESRI Grid layer
    GIS_Legend: TGIS_ControlLegend; // Layer legend panel docked to the left
    Memo1: TMemo;                  // Output text area for results
    procedure btnProfileClick(Sender: TObject);
    procedure btnMinMaxClick(Sender: TObject);
    procedure btnAvargeColorClick(Sender: TObject);
    procedure btnCreateBitmapClick(Sender: TObject);
    procedure btnCreateGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1.btnAvargeColorClick
  Demonstrates reading pixel colour values from a bitmap layer and then
  writing a computed value back.

  Steps:
  1. Open the bitmap project (Blue Marble satellite imagery).
  2. Obtain a reference to the pixel layer ("bluemarble") and a vector layer
     ("countries") that contains country polygons.
  3. Retrieve shape #679 (Spain) and pan/zoom to it.
  4. Iterate over all bitmap pixels that fall inside Spain (editable=False)
     and accumulate the sum of each R, G, B component.
  5. Compute the average colour from the totals.
  6. Iterate again (editable=True this time) and write the average colour back
     to every pixel inside Spain, replacing the satellite texture with a flat
     colour that represents the "dominant" hue of the area.
  7. Invalidate the map to force a repaint. }
procedure TForm1.btnAvargeColorClick(Sender: TObject);
var
  lp     : TGIS_LayerPixel  ;
  lv     : TGIS_LayerVector ;
  shp    : TGIS_Shape       ;
  px     : TGIS_PixelItem   ;
  r,g,b  : Double           ;
  cnt    : Integer          ;
  cl     : TGIS_Color       ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\bitmap.ttkproject' ) ;

  // Obtain the raster (bitmap) layer by name
  lp := TGIS_LayerPixel( GIS.Get( 'bluemarble' ) ) ;
  // Obtain the vector layer containing country polygons
  lv := TGIS_LayerVector( GIS.Get( 'countries' ) ) ;

  // Shape 679 is Spain; MakeEditable returns a mutable copy
  shp := lv.GetShape( 679 ).MakeEditable ; // Spain
  // Suspend repainting while we adjust the viewport
  GIS.Lock ;
  GIS.VisibleExtent := shp.ProjectedExtent ;
  GIS.Zoom := GIS.Zoom / 2.0 ;  // Zoom out slightly to see context
  GIS.Unlock ;

  cnt := 0 ;
  r := 0;
  g := 0;
  b := 0;

  // First pass: iterate pixels inside Spain (read-only, editable=false)
  // 'T' means the shape is used as a mask/clip boundary
  for px in lp.Loop( shp.Extent, 0, shp, 'T', false ) do begin
    r := r + px.Color.R ;  // Accumulate red channel (0-255)
    g := g + px.Color.G ;  // Accumulate green channel (0-255)
    b := b + px.Color.B ;  // Accumulate blue channel (0-255)
    Inc( cnt ) ;
  end;

  if cnt > 0 then begin
    // Build the average colour from the accumulated sums
    cl := TGIS_Color.FromRGB( Trunc(r/cnt) , Trunc(g/cnt), Trunc(b/cnt) ) ;
    // Second pass: overwrite every pixel inside Spain with the average colour
    // (editable=True enables writing)
    for px in lp.Loop( shp.Extent, 0, shp, 'T', true ) do begin
      px.Color := cl ;
    end;
  end;

  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnCreateBitmapClick
  Demonstrates creating a new JPEG raster layer from scratch and writing
  individual pixel values using the low-level LockPixels interface.

  Steps:
  1. Create a TGIS_LayerJPG and call Build() to define its extent, coordinate
     system, and pixel dimensions (360x180 pixels covering -180..180, -90..90).
  2. Call LockPixels() to lock a sub-region for direct buffer access.
     The returned TGIS_LayerPixelLock provides Bitmap[] (a flat integer array
     of ARGB values) and BitmapPos(x,y) which maps pixel coordinates to the
     correct flat array index.
  3. Iterate over the locked region and write the colour red into every cell.
  4. Call UnlockPixels() to flush the changes and release the lock.
  5. Call SaveData() to persist the modified pixels to the JPEG file.
  6. Open the file in the viewer. }
procedure TForm1.btnCreateBitmapClick(Sender: TObject);
var
  lp : TGIS_LayerJPG ;
  lck : TGIS_LayerPixelLock ;
  x, y : Integer ;
  test_jpg : string  ;
begin
  Memo1.Clear ;

  test_jpg := 'test.jpg';
  if FileExists(test_jpg) then
    DeleteFile(test_jpg);

  lp := TGIS_LayerJPG.Create ;
  try
    // Build() defines the file path, coordinate system (WGS-84 = EPSG:4326),
    // the geographic extent (-180,-90 to 180,90), and the pixel dimensions.
    lp.Build( test_jpg, TGIS_CSFactory.ByEPSG( 4326 ),
              TGIS_Utils.GisExtent( -180, -90, 180, 90 ), 360, 180
            ) ;

    // Lock a rectangular sub-region for direct pixel-buffer access.
    // The True parameter requests write (editable) access.
    lck := lp.LockPixels( TGIS_Utils.GisExtent( -45, -45, 45, 45 ), lp.CS, True ) ;
    try
      // Iterate over pixel columns (x) and rows (y) within the locked bounds
      for x := lck.Bounds.Left to lck.Bounds.Right do begin
        for y := lck.Bounds.Top to lck.Bounds.Bottom do begin
          // BitmapPos(x,y) converts 2-D coordinates to the flat array offset.
          // TGIS_Color.Red.ARGB is the 32-bit ARGB integer for opaque red.
          lck.Bitmap[ lck.BitmapPos(x,y) ] := Integer( TGIS_Color.Red.ARGB );
        end;
      end;
    finally
      // UnlockPixels() flushes buffered writes and releases the lock.
      lp.UnlockPixels( lck );
    end;

    lp.SaveData ;  // Persist the changes to the JPEG file on disk
  finally
    lp.Free ;
  end;

  GIS.Open( test_jpg ) ;
end;

{ TForm1.btnCreateGridClick
  Demonstrates creating a new ESRI Grid raster layer from scratch and writing
  floating-point elevation values using the low-level LockPixels interface.

  The approach is the same as btnCreateBitmapClick, but uses a Grid layer
  (continuous floating-point values rather than RGB colour) and the Grid[][]
  accessor instead of the Bitmap[] accessor. }
procedure TForm1.btnCreateGridClick(Sender: TObject);
var
  lp : TGIS_LayerGRD ;
  lck : TGIS_LayerPixelLock ;
  x, y : Integer ;
  test_grd : string ;
begin
  Memo1.Clear ;

  test_grd := 'test.grd';
  if FileExists(test_grd) then
    DeleteFile(test_grd);

  lp := TGIS_LayerGRD.Create ;
  try
    lp.Build( test_grd, TGIS_CSFactory.ByEPSG( 4326 ),
              TGIS_Utils.GisExtent( -180, -90, 180, 90 ), 360, 180
            ) ;

    // Lock a sub-region for write access
    lck := lp.LockPixels( TGIS_Utils.GisExtent( -45, -45, 45, 45 ), lp.CS, True ) ;
    try
      for x := lck.Bounds.Left to lck.Bounds.Right do begin
        for y := lck.Bounds.Top to lck.Bounds.Bottom do begin
          // Grid[row][col] stores a floating-point elevation value.
          // Note the index order: Grid[y][x] (row-major storage).
          lck.Grid[y][x] := Random(100) ;
        end;
      end;
    finally
      lp.UnlockPixels( lck );
    end;

    lp.SaveData ;
  finally
    lp.Free ;
  end;

  GIS.Open( test_grd ) ;
end;

{ TForm1.btnMinMaxClick
  Demonstrates reading pixel values from a DEM (Digital Elevation Model)
  grid layer and locating the cells with the minimum and maximum elevations
  within a clipping polygon.

  Steps:
  1. Open the grid project.
  2. Loop over all pixels inside the polygon shape using Loop(), tracking
     the minimum and maximum values and their geographic centres.
  3. Add a temporary vector layer with cross markers at the two extreme
     locations so they appear visually in the viewer.
  4. Report the results in Memo1. }
procedure TForm1.btnMinMaxClick(Sender: TObject);
var
  lp     : TGIS_LayerPixel  ;
  lv     : TGIS_LayerVector ;
  ltmp   : TGIS_LayerVector ;
  shp    : TGIS_Shape       ;
  shptmp : TGIS_Shape       ;
  px     : TGIS_PixelItem  ;
  dmin,
  dmax  : Double ;
  ptmin,
  ptmax : TGIS_Point ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\grid.ttkproject' ) ;

  // Retrieve the elevation grid layer and the polygon that defines the area
  lp := TGIS_LayerPixel( GIS.Get( 'elevation' ) ) ;
  lv := TGIS_LayerVector( GIS.Get( 'polygon' ) ) ;
  shp := lv.GetShape( 1 ).MakeEditable ;
  shp.IsSelected := True ;  // Highlight the polygon in the viewer

  dmax := -1e38 ;   // Start with the smallest possible value
  dmin :=  1e38 ;   // Start with the largest possible value

  // Loop over pixels within the shape extent, clipped to the shape boundary.
  // px.Value holds the elevation; px.Center gives the geographic coordinates.
  for px in lp.Loop( shp.Extent, 0, shp, 'T', false ) do begin
    if px.Value < dmin then begin
      dmin  := px.Value  ;
      ptmin := px.Center ;
    end;

    if px.Value > dmax then begin
      dmax  := px.Value  ;
      ptmax := px.Center ;
    end;
  end;

  // Create a temporary vector layer in the same CRS to draw the markers
  ltmp := TGIS_LayerVector.Create ;
  ltmp.CS := lp.CS ;
  GIS.Add( ltmp );

  // Use cross symbols to indicate the min/max pixel locations
  ltmp.Params.Marker.Style := TGIS_MarkerStyle.Cross ;
  ltmp.Params.Marker.Size := -10 ;  // Negative size = screen pixels (not map units)
  ltmp.Params.Marker.Color := TGIS_Color.Black  ;

  // Add a point shape at the minimum elevation location
  shptmp := ltmp.CreateShape( TGIS_ShapeType.Point ) ;
  shptmp.AddPart ;
  shptmp.AddPoint( ptmin ) ;

  // Add a point shape at the maximum elevation location
  shptmp := ltmp.CreateShape( TGIS_ShapeType.Point ) ;
  shptmp.AddPart ;
  shptmp.AddPoint( ptmax ) ;

  GIS.InvalidateWholeMap ;

  Memo1.Lines.Add( Format( 'Min: %f, Location: %f %f', [ dmin, ptmin.X, ptmin.Y ] ) ) ;
  Memo1.Lines.Add( Format( 'Max: %f, Location: %f %f', [ dmax, ptmax.X, ptmax.Y ] ) ) ;
end;

{ TForm1.btnProfileClick
  Demonstrates reading a terrain elevation profile along a polyline.

  Steps:
  1. Open the grid project.
  2. Retrieve the elevation grid and a polyline shape ("line" layer, shape 1).
  3. Use Loop(distance_step, shape, editable) to iterate over each pixel
     that the line passes through.  px.Distance is the cumulative distance
     along the line to the pixel centre; px.Value is the elevation.
  4. As a side-effect, each pixel's value is zeroed out to illustrate
     in-place editing during the same loop pass. }
procedure TForm1.btnProfileClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel  ;
  lv  : TGIS_LayerVector ;
  shp : TGIS_Shape       ;
  px  : TGIS_PixelItem   ;
begin
  Memo1.Clear ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\PixelEdit\grid.ttkproject' ) ;

  lp := TGIS_LayerPixel( GIS.Get( 'elevation' ) ) ;
  lv := TGIS_LayerVector( GIS.Get( 'line' ) ) ;
  shp := lv.GetShape( 1 ).MakeEditable ;
  shp.IsSelected := True ;  // Highlight the profile line

  Memo1.Lines.BeginUpdate ;
  try
    // Loop(step, shape, editable): iterates pixels along the polyline.
    // step=0 means visit every raster cell the line crosses.
    // editable=False allows reading but not writing.
    for px in lp.Loop( 0, shp, False ) do begin
      Memo1.Lines.Add( Format( 'Distance: %f, Height:%f', [ px.Distance, px.Value ] ) ) ;
      px.Value := 0 ;  // Zero out each visited pixel (demonstrates write access)
    end;
  finally
    Memo1.Lines.EndUpdate ;
  end;
end;

{ TForm1.FormCreate
  Initialises the form; clears the memo output area on startup. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

end.
