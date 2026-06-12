//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  CustomPaint sample — demonstrates custom drawing overlays using paint-hook mechanisms.

  What the sample shows:
    - Per-shape paint-hook via PaintShapeEvent for custom shape rendering
    - Replacing default shape rendering with custom graphics primitives
    - Converting shape geographic position to screen pixels with MapToScreen
    - Drawing rectangles, ellipses, text, and bitmaps with TGIS_RendererAbstract
    - Viewer-level paint-hook via PaintExtraEvent for map-wide overlays
    - Rendering overlays on top of entire map (HUD text, watermarks, etc.)
    - Accessing native renderer canvas handles (GDI+, GDI32, Direct2D, Skia)
    - Calling platform-specific graphics APIs directly for advanced effects
    - Switching between multiple renderer backends at runtime
    - In-memory vector layer with invisible markers as custom drawing anchors
    - Drawing different primitives based on shape attribute values

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - vector layer for custom shape storage
    TGIS_Shape                  - individual geographic feature
    PaintShapeEvent             - per-shape custom rendering callback
    PaintExtraEvent             - viewer-level post-render overlay callback
    TGIS_RendererAbstract       - platform-agnostic drawing interface
    GIS.MapToScreen()           - convert geographic coords to screen pixels
    RendererManager             - access available rendering backends
    TGIS_Bitmap                 - image for custom drawing from file
    TGIS_Pixels                 - raw ARGB pixel array for direct drawing
}
unit Unit1;

{$INCLUDE GisInclude.inc}

{$IFDEF LEVEL_RX12_VCL}
  {$DEFINE SKIA}
{$ENDIF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPAPI,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  VCL.Direct2D,

  VCL.GisViewerWnd,
  VCL.GisRenderer,
  VCL.GisRendererGdiPlus,
  VCL.GisRendererGdi32,
  VCL.GisRendererDirect2D,
  VCL.GisGdiPlus,

  {$IFDEF SKIA}
    VCL.GisRendererSkia,
    System.Skia,
  {$ENDIF}

  GisUtils,
  GisLayerVector,
  GisRendererAbstract,
  GisTypes,
  GisTypesUI,
  GisParams,
  GisRtl, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;        // Main TatukGIS map viewer control
    cbRenderer: TComboBox;      // Drop-down to switch the active renderer at runtime
    procedure FormCreate(Sender: TObject);
    // PaintShapeEvent callback: custom per-shape drawing
    procedure GISPaintShapeEvent(_sender: TObject; _shape : TGIS_Shape);
    procedure FormDestroy(Sender: TObject);
    // PaintExtraEvent callback: custom overlay drawn after all layers finish
    procedure GISPaintExtraEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure cbRendererChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1   : TForm1            ;
  ll      : TGIS_LayerVector  ;  // The "CustomPaint" layer containing the 4 demo shapes
  bmp     : TGIS_Bitmap       ;  // Bitmap loaded from police.bmp for Image1 painting
  px      : TGIS_Pixels       ;  // Raw ARGB pixel array (5x5) for Image2 painting

implementation

{$R *.dfm}

{ TForm1.cbRendererChange
  Replaces the viewer's active rendering backend when the user selects a
  different entry in the combo box.

  RendererManager.CreateInstance creates a fresh renderer instance by class
  name.  Assigning it to GIS.Renderer keeps TatukGIS's drawing pipeline
  intact while replacing the drawing backend (GDI+, GDI32, Direct2D, Skia).

  ControlUpdateWholeMap triggers a full repaint with the new renderer so the
  result is immediately visible.
}
procedure TForm1.cbRendererChange(Sender: TObject);
begin
  if cbRenderer.ItemIndex >= 0 then
    GIS.Renderer := RendererManager.CreateInstance( RendererManager.Names[cbRenderer.ItemIndex] ) ;

  GIS.ControlUpdateWholeMap;
end;

{ TForm1.FormCreate
  Initialises the raw pixel buffer, creates the layer with four demo shapes,
  loads the bitmap, and populates the renderer combo box.

  initialize_pixels defines a 5x5 raw ARGB pixel array used by Image2:
    - Row 0  (indices 0..4):  solid red   ($FFFF0000)
    - Diagonal pixels at [7], [12], [17], [22]: solid blue ($FF0000FF)
    - Remaining pixels:       transparent ($00000000)
  The alpha channel is in the high byte (0xFF = opaque, 0x00 = transparent),
  matching the TGIS_BitmapFormat.ARGB layout.

  Four point shapes are placed at geographic coordinates:
    (-25,  25) -> "Rectangle"  (NW quadrant)
    ( 25,  25) -> "Ellipse"    (NE quadrant)
    (-25, -25) -> "Image1"     (SW quadrant)
    ( 25, -25) -> "Image2"     (SE quadrant)
  All have Marker.Size = 0 so no default marker symbol is drawn; all visual
  output comes entirely from the GISPaintShapeEvent callback.

  The layer extent is set to (-100,-100,100,100) to encompass all four shapes.
}
procedure TForm1.FormCreate(Sender: TObject);
var
  shp  : TGIS_Shape  ;
  name : String ;
  i : Integer ;

  { initialize_pixels
    Fills the px array with raw ARGB values describing a small 5x5 test image:
      - First row of 5 pixels: opaque red
      - One blue pixel diagonally every 5 elements (positions 7, 12, 17, 22)
      - All other pixels: fully transparent
    This pattern demonstrates the CanvasDrawBitmap overload that accepts a
    raw pixel array with an explicit source offset and pixel format.
  }
  procedure initialize_pixels ;
  begin
    // Row 0: all red (ARGB $FFFF0000 = fully opaque red)
    px[ 0] := Integer($FFFF0000) ;
    px[ 1] := Integer($FFFF0000) ;
    px[ 2] := Integer($FFFF0000) ;
    px[ 3] := Integer($FFFF0000) ;
    px[ 4] := Integer($FFFF0000) ;
    // Row 1: mostly transparent, one blue pixel at column 2
    px[ 5] := Integer($00000000) ;
    px[ 6] := Integer($00000000) ;
    px[ 7] := Integer($FF0000FF) ; // opaque blue ($FFRRGGBB -> $FF0000FF = blue)
    px[ 8] := Integer($00000000) ;
    px[ 9] := Integer($00000000) ;
    // Row 2: mostly transparent, one blue pixel at column 2
    px[10] := Integer($00000000) ;
    px[11] := Integer($00000000) ;
    px[12] := Integer($FF0000FF) ;
    px[13] := Integer($00000000) ;
    px[14] := Integer($00000000) ;
    // Row 3: mostly transparent, one blue pixel at column 2
    px[15] := Integer($00000000) ;
    px[16] := Integer($00000000) ;
    px[17] := Integer($FF0000FF) ;
    px[18] := Integer($00000000) ;
    px[19] := Integer($00000000) ;
    // Row 4: mostly transparent, one blue pixel at column 2
    px[20] := Integer($00000000) ;
    px[21] := Integer($00000000) ;
    px[22] := Integer($FF0000FF) ;
    px[23] := Integer($00000000) ;
    px[23] := Integer($00000000) ; // note: index 23 assigned twice (last pixel)
  end;
begin
  SetLength(px, 25);  // allocate 5x5 pixel buffer

  initialize_pixels ;

  // Create the demo layer; no data source - all geometry is created in code.
  ll := TGIS_LayerVector.Create;
  ll.Name := 'CustomPaint';

  GIS.Add(ll);

  // Register the custom per-shape paint callback.
  // PaintShapeEvent fires once per shape during each repaint cycle,
  // replacing the default shape rendering for this layer.
  ll.PaintShapeEvent := GISPaintShapeEvent;
  // Add a "type" field so each shape can carry its drawing-mode selector.
  ll.AddField('type', TGIS_FieldType.String,100,0);
  ll.Extent := GIS.Extent;

  // --- Create the four demo point shapes ---
  // Each shape is an invisible point (Marker.Size=0) at a fixed map coordinate.
  // Lock(Extent) prevents the layer from auto-expanding its extent during
  // the AddPoint call; Unlock releases the lock.

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(-25,25) );  // NW quadrant
  shp.Params.Marker.Size := 0;   // invisible - custom draw handles all visuals
  shp.SetField( 'type', 'Rectangle' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(25,25) );   // NE quadrant
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Ellipse' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(-25,-25) ); // SW quadrant
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Image1' );
  shp.Unlock ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint(25,-25) );  // SE quadrant
  shp.Params.Marker.Size := 0;
  shp.SetField( 'type', 'Image2' );
  shp.Unlock ;

  // Set layer extent to enclose all four shapes
  ll.Extent := TGIS_Utils.GisExtent(-100,-100,100,100)     ;

  // Load the bitmap used by the "Image1" paint case.
  // TGIS_Bitmap is TatukGIS's cross-renderer bitmap wrapper.
  bmp := TGIS_Bitmap.Create;
  bmp.LoadFromFile(TGIS_Utils.GisSamplesDataDirDownload + 'Symbols\police.bmp');

  GIS.FullExtent;

  // Populate the renderer combo box with all available rendering backends.
  // RendererManager.Names lists the registered renderer class names.
  cbRenderer.Items.Clear ;
  for i := 0 to RendererManager.Names.Count-1 do
    cbRenderer.Items.Add(RendererManager.Names[i]);
  // Pre-select the currently active renderer in the list.
  cbRenderer.ItemIndex := RendererManager.Names.IndexOf(GIS.Renderer.ClassName);
end;

{ TForm1.FormDestroy
  Frees the TGIS_Bitmap object held in the global 'bmp' variable.
  The layer and pixel array are cleaned up automatically by TatukGIS and
  the Delphi memory manager respectively.
}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeObject(bmp);
end;

{ TForm1.GISPaintExtraEvent
  PaintExtraEvent callback - fired once after all layers have finished
  rendering, before the viewer's back-buffer is flipped to screen.

  _renderer is the currently active TGIS_RendererAbstract instance.
  _mode     is TGIS_DrawMode and indicates whether this is a full or
            incremental repaint (not used here, but useful for optimisation).

  This handler demonstrates accessing the renderer's native canvas handle
  to call platform-specific drawing APIs.  This approach is NOT recommended
  for production code because it tightly couples the drawing logic to a
  specific backend; use TGIS_RendererAbstract primitives instead for
  portability across GDI+, GDI32, Direct2D, and Skia.

  The native canvas is obtained via _renderer.CanvasNative and cast to the
  appropriate type for each backend:
    TGIS_RendererVclGdiPlus  -> GPGRAPHICS (Windows GDI+ Graphics object)
    TGIS_RendererVclGdi32    -> TCanvas    (VCL canvas wrapping a GDI DC)
    TGIS_RendererVclDirect2D -> TDirect2DCanvas
    TGIS_RendererVclSkia     -> ISkCanvas  (Skia canvas; compile with SKIA define)
}
procedure TForm1.GISPaintExtraEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
var
  cnvGDIP     : GPGRAPHICS            ;  // GDI+ graphics context
  font        : GPFONT                ;
  brush       : GPBRUSH               ;
  fontFamily  : GPFONTFAMILY          ;
  sf          : GPSTRINGFORMAT        ;
  rect        : TGPRectF              ;  // GDI+ rectangle (floating-point)
  text        : PWideChar             ;
  cnvGDI32    : TCanvas               ;  // VCL TCanvas wrapping a GDI DC
  cnvD2D      : TDirect2DCanvas       ;  // VCL Direct2D canvas
  {$IFDEF SKIA}
    cnvSkia   : ISkCanvas             ;  // Skia canvas (RAD RX12+ only)
  {$ENDIF}
begin
  // --- GDI+ backend: use native GDI+ flat API to draw text ---
  // Casting CanvasNative to TGIS_GdipGraphics and then extracting .Native
  // gives access to the underlying GDI+ GPGRAPHICS handle.
  if _renderer is TGIS_RendererVclGdiPlus then begin
    cnvGDIP := GPGRAPHICS(TGIS_GdipGraphics(_renderer.CanvasNative).Native);
    GdipCreateSolidFill( $FF0000FF, brush ) ;
    GdipCreateFontFamilyFromName(PWideChar('Arial'), nil, fontFamily) ;
    GdipCreateFont(fontFamily, 8, FontStyleRegular, ord(UnitPoint), font) ;
    GdipCreateStringFormat(0, LANG_NEUTRAL, sf) ;
    text := 'Hello from GDI+';

    try
      rect := MakeRect( 50.0, 50.0, 150.0, 100.0 ) ;

      GdipDrawString(
        cnvGDIP,
        PWideChar(text),
        Length(text),
        font,
        @rect,
        sf,
        brush
        );
    finally
      // Always release GDI+ resources to avoid handle leaks
     GdipDeleteBrush(brush);
     GdipDeleteFont(font);
     GdipDeleteFontFamily(fontFamily);
     GdipDeleteStringFormat(sf);
    end;
  end
  // --- GDI32 backend: use VCL TCanvas.TextOut ---
  else
  if _renderer is TGIS_RendererVclGdi32 then begin
    cnvGDI32 := TCanvas(_renderer.CanvasNative);
    cnvGDI32.TextOut(50,50, 'Hello from GDI32');
  end
  // --- Direct2D backend: use TDirect2DCanvas.TextOut ---
  else
  if _renderer is TGIS_RendererVclDirect2D then begin
    cnvD2D := TDirect2DCanvas(_renderer.CanvasNative);
    cnvD2D.TextOut(50,50, 'Hello from D2D');
  end
  else
  {$IFDEF SKIA}
  // --- Skia backend: use ISkCanvas.DrawSimpleText (RAD RX12+) ---
  if _renderer is TGIS_RendererVclSkia then begin
    cnvSkia := TSkCanvas(_renderer.CanvasNative);
    cnvSkia.DrawSimpleText('Hello from Skia', 50, 50, TSkFont.Create, TSkPaint.Create);
  end
  else
  {$ENDIF}
  begin
    // Future or unrecognised renderers: no action required
  end;
end;

{ TForm1.GISPaintShapeEvent
  PaintShapeEvent callback - fired by the "CustomPaint" layer once for each
  shape during a repaint pass, replacing the default shape rendering.

  _shape is the shape currently being painted.  It has an invisible marker
  (Marker.Size = 0) so no default symbol would appear.  The handler:
    1. Calls GIS.MapToScreen(_shape.PointOnShape) to obtain the shape's
       geographic position as screen-pixel coordinates.
    2. Calls _shape.Draw() to ensure any default rendering hooks still fire
       (a no-op for marker-size-0 shapes, but good practice).
    3. Reads the "type" field to select a drawing primitive, then uses the
       shape's layer renderer (TGIS_RendererAbstract) to draw on screen.

  All coordinates passed to renderer Canvas* methods are in screen pixels.
  The 20x20 pixel size of each primitive is fixed and does not scale with zoom.

  Drawing cases:
    "Rectangle" - red-bordered yellow filled box; "Rectangle" label above.
    "Ellipse"   - black-bordered red ellipse; "Ellipse" label above.
    "Image1"    - the police.bmp TGIS_Bitmap stretched into a 20x20 box;
                  "Image1" label above.
    "Image2"    - the raw px pixel array (5x5, ARGB, top-to-bottom scan order)
                  scaled into a 20x20 box; "Image2" label above.
                  The TPoint(5,5) source-offset parameter skips the first 5
                  pixels (the red row) and starts reading from the second row.
}
procedure TForm1.GISPaintShapeEvent(_sender: TObject; _shape : TGIS_Shape);
var
  rdr       : TGIS_RendererAbstract ;  // renderer for this layer/viewer
  pt        : TPoint                ;  // screen-pixel position of the shape
begin
  // Convert the shape's geographic position to screen pixels.
  // PointOnShape returns the representative point for the shape geometry.
  pt := GIS.MapToScreen( _shape.PointOnShape ) ;
  // Allow any default rendering hooks to run (no visible effect here).
  _shape.Draw ;
  // Obtain the abstract renderer from the shape's owning layer.
  rdr := _shape.Layer.Renderer as TGIS_RendererAbstract;

  // --- Select drawing primitive based on the shape's "type" field ---

  if _shape.GetField('type') = 'Rectangle' then begin
    // Draw a red-bordered yellow rectangle centred on the shape's screen position.
    rdr.CanvasPen.Color := TGIS_Color.Red ;
    rdr.CanvasBrush.Color := TGIS_Color.Yellow ;
    rdr.CanvasDrawRectangle(TRect.Create(pt, 20, 20));
    // Draw the label 20 pixels above the rectangle
    pt.Y := pt.Y - 20 ;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Rectangle');
  end
  else
  if _shape.GetField('type') = 'Ellipse' then begin
    // Draw a black-bordered red ellipse; width=20, height=20.
    rdr.CanvasPen.Color := TGIS_Color.Black ;
    rdr.CanvasBrush.Color := TGIS_Color.Red ;
    rdr.CanvasDrawEllipse(pt.X ,pt.Y ,20 ,20) ;
    pt.Y := pt.Y - 20 ;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Ellipse');
  end
  else
  if _shape.GetField('type') = 'Image1' then begin
    // Stretch the TGIS_Bitmap (loaded from police.bmp) into a 20x20 screen rect.
    rdr.CanvasDrawBitmap(
    bmp,
    TRect.Create(
      pt.X ,
      pt.Y ,
      pt.X + 20,
      pt.Y + 20
    )) ;
    pt.Y := pt.Y - 20;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Image1');
  end
  else
  if _shape.GetField('type') = 'Image2' then begin
    // Draw using a raw ARGB pixel array (the px buffer initialised in FormCreate).
    // Parameters:
    //   px                       - the pixel data buffer
    //   Point(5, 5)              - source offset: start reading from pixel (5,5)
    //                              within the 5xN source, skipping the red row
    //   TRect.Create(...)        - destination rectangle in screen pixels
    //   TGIS_BitmapFormat.ARGB   - pixel layout: alpha-red-green-blue per 32-bit word
    //   TGIS_BitmapLinesOrder.Down - scanlines are ordered top-to-bottom
    rdr.CanvasDrawBitmap(
      px,
      Point( 5, 5),
      TRect.Create( pt.X , pt.Y , pt.X + 20, pt.Y + 20 ),
      TGIS_BitmapFormat.ARGB,
      TGIS_BitmapLinesOrder.Down
    ) ;
    pt.Y := pt.Y - 20;
    rdr.CanvasDrawText(TRect.Create(pt, 20, 20), 'Image2');
  end

end ;

end.
