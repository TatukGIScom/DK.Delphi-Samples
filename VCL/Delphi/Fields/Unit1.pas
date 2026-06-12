//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Fields Sample - Demonstrates how to use field (attribute) properties of a layer.

  This sample shows:
    - How to define custom attribute fields on an in-memory vector layer using
      TGIS_LayerVector.AddField, specifying name, type (TGIS_FieldType), width,
      and decimal precision.
    - How to write field values to individual shapes using TGIS_Shape.SetField.
    - How to use the special "FIELD:<name>" expression syntax in rendering
      parameters (Params.Marker, Params.Line, Params.Area, Params.Labels) so
      that each shape is rendered using its own per-attribute color, size,
      rotation, label text, and label position.
    - How to expose a layer's attribute table through TGIS_DataSet and display
      it in a database-bound TDBGrid.
    - The difference between locking a shape with TGIS_Lock.Projection (keeps
      coordinates in the layer's own projection space) vs TGIS_Lock.Extent
      (coordinates are treated as plain extent/world coordinates).

  Supported shape types demonstrated: Point, Arc (polyline), Polygon.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.DBGrids,

  Data.DB,

  //GisLicense,
  GisTypes,        // Core GIS types: TGIS_ShapeType, TGIS_FieldType, TGIS_Lock, etc.
  GisDataSet,      // TGIS_DataSet: exposes a vector layer as a TDataSet for DB-aware controls
  GisEditor,
  GisLayerVector,  // TGIS_LayerVector: in-memory or file-backed vector layer
  GisSymbol,
  GisTypesUI,      // UI-related GIS types: TGIS_labelPosition, ConstructParamPosition
  GisUtils,        // Utility helpers: TGIS_Utils.GisPoint, GisSamplesDataDirDownload, etc.
  GisViewer,

  Vcl.GisControlLegend,  // TGIS_ControlLegend: displays layer tree / legend panel
  Vcl.GisViewerWnd,      // TGIS_ViewerWnd: the main interactive map viewer control
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    CreateLayerButton: TButton;         // Triggers CreateLayerButtonClick to build the demo layer
    GIS: TGIS_ViewerWnd;                // Main map viewer control
    chkUseSymbols: TCheckBox;           // When checked, CGM symbol files are used instead of plain markers
    GIS_ControlLegend: TGIS_ControlLegend; // Legend panel bound to the created layer
    GIS_DataSet1: TGIS_DataSet;         // Bridges the vector layer to the VCL data-aware grid
    DBGrid1: TDBGrid;                   // Shows the attribute table rows editable via TGIS_DataSet
    DataSource1: TDataSource;           // VCL data source linking TGIS_DataSet to DBGrid1
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure CreateLayerButtonClick(Sender: TObject);
    procedure GIS_DataSet1AfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses GisParams ;  // ConstructParamPosition and related rendering-parameter helpers

{-------------------------------------------------------------------------------
  CreateLayerButtonClick

  Main demonstration procedure. Each click:
    1. Closes any existing map content.
    2. Creates a new in-memory TGIS_LayerVector named "Fields".
    3. Defines eight attribute fields that will drive the layer's appearance.
    4. Populates the layer with Point, Arc, and Polygon shapes, each carrying
       randomly-generated per-shape attribute values.
    5. Configures the layer's rendering parameters to read color, size, rotation,
       and label text directly from the field values via "FIELD:<fieldname>" tokens.
    6. Displays the layer in the viewer and binds its attribute table to the grid.
-------------------------------------------------------------------------------}
procedure TForm1.CreateLayerButtonClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;  // The in-memory vector layer that owns all shapes and fields
  shp : TGIS_Shape ;        // A single shape (point / arc / polygon) being created
  i   : Integer ;           // Loop counter
  an  : Double ;            // Random rotation angle (degrees) shared by label & symbol for one shape
begin
  GIS.Close ;  // Remove any previously loaded layers before rebuilding

  // Create a new in-memory vector layer; no path is given so it lives entirely
  // in RAM and is not persisted to disk unless explicitly saved.
  lv := TGIS_LayerVector.Create ;
  lv.Name := 'Fields' ;
  lv.Open ;  // Must be opened before adding fields or shapes

  // -------------------------------------------------------------------------
  // Field definitions
  // AddField(name, type, width, decimals)
  //   - TGIS_FieldType.Float   : floating-point number stored with decimal places
  //   - TGIS_FieldType.Number  : integer-compatible numeric field (decimals = 0)
  //   - TGIS_FieldType.String  : text field; width is the character count
  //
  // These fields will later be referenced by name in rendering-parameter
  // "FIELD:<name>" expressions so the DK renderer reads their values at draw time.
  // -------------------------------------------------------------------------
  lv.AddField( 'rotateLabel',  TGIS_FieldType.Float,  10, 4 ) ;  // Label rotation angle (degrees)
  lv.AddField( 'rotateSymbol', TGIS_FieldType.Float,  10, 4 ) ;  // Symbol/marker rotation angle (degrees)
  lv.AddField( 'color',        TGIS_FieldType.Number, 10, 0 ) ;  // Fill/stroke color as packed RGB integer
  lv.AddField( 'outlinecolor', TGIS_FieldType.Number, 10, 0 ) ;  // Outline/border color as packed RGB integer
  lv.AddField( 'size',         TGIS_FieldType.Number, 10, 0 ) ;  // Symbol or line width size value
  lv.AddField( 'label',        TGIS_FieldType.String,  1, 0 ) ;  // Text to display as the shape label
  lv.AddField( 'position',     TGIS_FieldType.String,  1, 0 ) ;  // Encoded label placement position
  lv.AddField( 'scale',        TGIS_FieldType.Float,  10, 4 ) ;  // Scale factor (Pi/180 converts deg->rad for symbol)

  // -------------------------------------------------------------------------
  // Create 11 Point shapes at random locations within [0,20] x [0,20]
  // Each point gets its own random color, rotation, label, and position.
  // TGIS_Lock.Projection is used so coordinates are interpreted in the
  // layer's coordinate system rather than the viewer extent.
  // -------------------------------------------------------------------------
  for i := 0 to 10 do begin
    shp := lv.CreateShape( TGIS_ShapeType.Point ) ;
    shp.Lock( TGIS_Lock.Projection ) ;  // Lock with Projection: coords are in layer CRS
    shp.AddPart ;                        // A point shape requires one part before AddPoint
    shp.AddPoint( TGIS_Utils.GisPoint( Random( 20 ), Random( 20 ) ) ) ;

    an := Random( 360 ) ;                // Random angle for both label and symbol rotation

    // SetField(name, value) writes the attribute value for the current shape.
    // The value type is implicitly converted to match the field's TGIS_FieldType.
    shp.SetField( 'rotateLabel',  an ) ;
    shp.SetField( 'rotateSymbol', an ) ;

    // Pack three 8-bit random channel values into a single integer: 0x00RRGGBB
    shp.SetField( 'color',        Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
    shp.SetField( 'outlinecolor', Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
    shp.SetField( 'label',        'Point' + IntToStr( i ) ) ;
    shp.SetField( 'size',         Random( 400 ) ) ;

    // ConstructParamPosition encodes a TGIS_labelPosition enum value as a
    // string token understood by the renderer's PositionAsText parameter.
    shp.SetField( 'position', ConstructParamPosition( [ TGIS_labelPosition( Random( 9 ) ) ] ) ) ;

    // Pi/180 is a scale factor used when the renderer converts degree field
    // values to radians for symbol rotation arithmetic.
    shp.SetField( 'scale', Pi/180 ) ;
    shp.Unlock ;  // Commit the geometry and attributes; shape becomes part of the layer
  end;

  // -------------------------------------------------------------------------
  // Create one multi-vertex Arc (open polyline) with 11 random vertices
  // spread around the origin [-10,10] x [-10,10].
  // TGIS_Lock.Extent is used here; coords are world/extent coordinates.
  // -------------------------------------------------------------------------
  shp := lv.CreateShape( TGIS_ShapeType.Arc );
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  for i := 0 to 10 do begin
    shp.AddPoint( TGIS_Utils.GisPoint( Random( 20 ) - 10 , Random( 20 ) - 10 ) );
  end ;
  an := Random( 360 ) ;
  shp.SetField( 'rotateLabel',  an ) ;
  shp.SetField( 'rotateSymbol', an ) ;
  shp.SetField( 'color',        Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
  shp.SetField( 'label',        'Point' + IntToStr( 1 ) ) ;
  shp.SetField( 'outlinecolor', Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
  shp.SetField( 'scale', Pi/180 ) ;
  shp.Unlock ;

  // -------------------------------------------------------------------------
  // Create 11 two-vertex Arc shapes with incrementing "size" field values
  // (i = 1..11), positioned in a horizontal row at X = [22,42], Y = 0..10.
  // This group visually demonstrates how the "FIELD:size" expression causes
  // each line to be drawn with a different width.
  // -------------------------------------------------------------------------
  for i := 1 to 11 do begin
    shp := lv.CreateShape( TGIS_ShapeType.Arc );
    shp.Lock( TGIS_Lock.Extent ) ;
    shp.AddPart ;
    shp.AddPoint( TGIS_Utils.GisPoint( 20+ 2*i , 0 ) );
    shp.AddPoint( TGIS_Utils.GisPoint( 30+ 2*i , 10 ) );
    an := Random( 360 ) ;
    shp.SetField( 'rotateLabel',  an ) ;
    shp.SetField( 'rotateSymbol', an ) ;
    shp.SetField( 'size',         i ) ;  // Increasing size: produces visibly thicker lines
    shp.SetField( 'color',        Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
    shp.SetField( 'outlinecolor', Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
    shp.SetField( 'scale', Pi/180 ) ;
    shp.Unlock ;
  end ;

  // -------------------------------------------------------------------------
  // Create one Polygon shape with 4 random vertices near the origin.
  // -------------------------------------------------------------------------
  shp := lv.CreateShape( TGIS_ShapeType.Polygon );
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ;
  for i := 0 to 3 do
  begin
    shp.AddPoint( TGIS_Utils.GisPoint( Random( 20 ) - 10 , Random( 20 ) - 10 ) );
  end ;
  an := Random( 360 ) ;
  shp.SetField( 'rotateLabel',  an ) ;
  shp.SetField( 'rotateSymbol', an ) ;
  shp.SetField( 'color',        Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
  shp.SetField( 'outlinecolor', Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) ) ;
  shp.SetField( 'label',        'Point' + IntToStr( 2 ) ) ;
  shp.Unlock ;

  // =========================================================================
  // Rendering parameter configuration
  //
  // The "FIELD:<fieldname>" token in any *AsText property tells the DK
  // renderer to evaluate the named field on each shape at draw time instead
  // of using a single static value.  An optional unit suffix (e.g. ":1 dip",
  // ":1 deg") converts the raw numeric value to the expected unit.
  // =========================================================================

  // --- Point / Marker rendering ---
  lv.Params.Marker.ColorAsText        := 'FIELD:color' ;        // Per-shape fill color
  lv.Params.Marker.OutlineColorAsText := 'FIELD:outlinecolor' ; // Per-shape outline color
  lv.Params.Marker.OutlineWidth       := 1 ;                    // Static 1-pixel outline width
  // Size in twips (1 point = 20 twips); base size when no custom CGM symbol is used
  lv.Params.Marker.Size               := 20 * 20;

  if chkUseSymbols.Checked then
  begin
    // Load a CGM vector symbol from the samples data directory.
    // Prepare() registers the symbol in the SymbolList cache and returns a handle.
    lV.Params.Marker.Symbol             := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\2267.cgm' ) ;
    lv.Params.Marker.SizeAsText         := 'FIELD:size:1 dip' ;       // Size from field, in device-independent pixels
    lv.Params.Marker.SymbolRotateAsText := 'FIELD:rotateSymbol' ;     // Symbol rotation from field (degrees)
  end;

  // --- Label rendering ---
  lv.Params.Labels.Field           := 'label' ;              // Which field supplies the label text
  lv.Params.Labels.Allocator       := False ;                // Disable automatic label conflict avoidance
  lv.Params.Labels.ColorAsText     := 'FIELD:color' ;        // Label background color from field
  lv.Params.Labels.OutlineColorAsText := 'FIELD:outlinecolor' ; // Label outline color from field
  lv.Params.Labels.PositionAsText  := 'FIELD:position' ;    // Label anchor position (encoded string) from field
  lv.Params.Labels.FontColorAsText := 'FIELD:color' ;        // Font color from field (same as fill here)
  lv.Params.Labels.RotateAsText    := 'FIELD:rotateLabel:1 deg'; // Label rotation from field, unit = degrees

  // --- Line / Arc rendering ---
  if chkUseSymbols.Checked then
  begin
    lV.Params.Line.Symbol            := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\1301.cgm' ) ;
    lv.Params.Line.SymbolRotateAsText := 'FIELD:rotateSymbol:1 deg';
  end;
  lv.Params.Line.ColorAsText        := 'FIELD:color' ;
  lv.Params.Line.OutlineColorAsText := 'FIELD:outlinecolor' ;
  lv.Params.Line.WidthAsText        := 'FIELD:size:1 dip' ; // Line width driven by the "size" field value

  // --- Area / Polygon rendering ---
  lv.Params.Area.SymbolRotateAsText := 'FIELD:rotateSymbol' ;
  if chkUseSymbols.Checked then
    lV.Params.Area.Symbol            := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\1301.cgm' ) ;
  lv.Params.Area.ColorAsText        := 'FIELD:color' ;
  lv.Params.Area.OutlineColorAsText := 'FIELD:outlinecolor' ;

  // -------------------------------------------------------------------------
  // Add the finished layer to the viewer, fit the viewport, refresh the
  // legend panel, and open the attribute table via TGIS_DataSet so that
  // DBGrid1 shows all field values and allows in-place editing.
  // -------------------------------------------------------------------------
  GIS.Add( lv ) ;
  GIS.FullExtent ;                          // Zoom to show all shapes
  GIS_ControlLegend.GIS_Layer := lv ;
  GIS_ControlLegend.Update ;

  // Open the dataset over the full layer extent; the DataSource1/DBGrid1
  // binding is set up in the DFM, so the grid populates automatically.
  GIS_DataSet1.Open( lv, lv.Extent ) ;
end;

{-------------------------------------------------------------------------------
  GIS_DataSet1AfterPost

  Called by TGIS_DataSet after the user commits an edited row in DBGrid1.
  Invalidating the whole map forces a redraw so any field value changes
  (color, size, label text, etc.) are immediately reflected in the viewer.
-------------------------------------------------------------------------------}
procedure TForm1.GIS_DataSet1AfterPost(DataSet: TDataSet);
begin
  GIS.InvalidateWholeMap() ;
end;

end.
