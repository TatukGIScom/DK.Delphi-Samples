//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  AddLayer sample — demonstrates dynamic layer addition and visual parameter configuration.

  What the sample shows:
    - Programmatically creating a TGIS_LayerSHP instance for vector data
    - Adding layers to the viewer via GIS.Add() method
    - Using GisCreateLayer factory to auto-detect layer type from file extension
    - Setting visual rendering parameters: fill colour, line width, outline, line colour
    - Disabling automatic .ttkgp config-file loading with UseConfig property
    - Applying customised parameters so layers display as explicitly configured
    - Fitting viewport to all loaded layers with GIS.FullExtent()
    - Switching viewer interaction modes: Drag (pan) vs. Select (click features)
    - Zooming programmatically by scaling current Zoom value up/down

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd          - main visual map control
    TGIS_LayerSHP           - vector layer for ESRI Shapefiles
    GisCreateLayer()        - factory function for automatic layer type detection
    TGIS_Params             - layer styling and rendering parameters
    TGIS_Params.Params      - nested property tree for symbol/fill/line customisation
    GIS.Add()               - adds a layer to the viewer
    GIS.FullExtent()        - zoom to combined extent of all loaded layers
    TGIS_ViewerMode         - interaction modes (Drag, Select, Zoom)
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
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  //GisLicense,      // Uncomment when deploying with a runtime licence unit
  GisTypes,          // Core TatukGIS type definitions (TGIS_Color, extents, etc.)
  GisEditor,         // Base layer and viewer infrastructure
  GisLayerSHP,       // ESRI Shapefile layer class (TGIS_LayerSHP)
  GisUtils,          // Utility helpers (GisSamplesDataDirDownload, etc.)
  GisTypesUI,        // UI-specific types (TGIS_ViewerMode, etc.)
  GisViewer,         // Viewer base class

  Vcl.GisViewerWnd, System.ImageList;  // VCL-hosted map viewer control

type
  { AddLayer sample — demonstrates how to programmatically add vector layers to a GIS viewer.
    Creates shapefile layers (TGIS_LayerSHP) for country polygons and rivers polylines, sets visual
    styling parameters (fill color, line width, line color), and adds them to the viewer using GIS.Add().
    Provides zoom navigation and interaction mode switching (pan/select). }
  TForm1 = class(TForm)
    /// The main TatukGIS map viewer control.  All layers are added to this
    /// component; it handles rendering, hit-testing, and user interaction.
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Toolbar1: TToolBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton4: TToolButton;
    /// Checkbox that toggles the viewer between Drag (pan) and Select modes.
    chkDrag: TCheckBox;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure chkDragClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
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
  GisRegistredLayers ;  // Registers known layer types; required for GisCreateLayer to resolve SHP

{-----------------------------------------------------------------------------
  FormCreate
  Called once when the form is first shown.  This is where all layers are
  constructed and added to the GIS viewer so the map is populated before the
  user sees the window.
-----------------------------------------------------------------------------}
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  // --- Layer 1: Country outline (polygon / area layer) ---
  // Construct the layer directly.  TGIS_LayerSHP wraps an ESRI Shapefile;
  // the geometry type (point, polyline, polygon) is determined automatically
  // from the .shp file header when the layer is first accessed.
  ll := TGIS_LayerSHP.Create ;

  // Path points to the sample data directory resolved at runtime.
  // GisSamplesDataDirDownload returns the path where the TatukGIS sample
  // datasets were downloaded (configured via the DK installer or environment).
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\country.shp' ;

  // A human-readable name shown in layer lists / legends.
  ll.Name := 'country' ;

  // Params.Area.Color sets the solid fill colour for polygon geometries.
  // LightGray gives a neutral background so the river overlay is clearly
  // visible on top.
  ll.Params.Area.Color := TGIS_Color.LightGray ;

  // Add the layer to the viewer.  GIS.Add appends to the internal layer
  // stack; layers added first are drawn first (bottom of the visual stack).
  GIS.Add(ll) ;

  // --- Layer 2: Rivers (polyline layer) ---
  // GisCreateLayer is a factory function that examines the file extension and
  // returns the appropriate TGIS_Layer subclass.  Casting to TGIS_LayerSHP is
  // safe here because we know the file is a Shapefile.
  // The first argument becomes the layer's Name property.
  ll := TGIS_LayerSHP( GisCreateLayer( 'rivers',
                                       TGIS_Utils.GisSamplesDataDirDownload +
                                       '\World\Countries\Poland\DCW\lwaters.shp'
                                      )
                       ) ;

  // UseConfig = False prevents the DK from loading a previously saved .ttkgp
  // configuration file for this layer.  This ensures the rendering parameters
  // we set below are always applied fresh, rather than overridden by cached
  // values from a prior session.
  ll.UseConfig := False ;

  // Params.Line controls the stroke appearance of polyline (and polygon
  // outline) geometries.
  // OutlineWidth = 0 removes the contrasting halo drawn around lines, giving
  // a clean single-colour stroke.
  ll.Params.Line.OutlineWidth := 0 ;

  // Width is in screen pixels at the reference zoom level.
  ll.Params.Line.Width := 3 ;

  ll.Params.Line.Color := TGIS_Color.Blue ;

  GIS.Add(ll) ;

  // Zoom the viewport out to encompass the combined extent of all added
  // layers.  Without this call the viewer would show an empty canvas at the
  // default initial extent.
  GIS.FullExtent ;
end;

{-----------------------------------------------------------------------------
  chkDragClick
  Toggles the viewer's active interaction mode.

  TGIS_ViewerMode.Drag  – the user can pan the map by clicking and dragging.
  TGIS_ViewerMode.Select – the user can click features to select them.
-----------------------------------------------------------------------------}
procedure TForm1.chkDragClick(Sender: TObject);
begin
  if chkDrag.Checked then begin
     // Drag mode: left-click + move pans the map canvas.
     GIS.Mode := TGIS_ViewerMode.Drag ;
  end else begin
     // Select mode: left-click picks the topmost feature under the cursor.
     GIS.Mode := TGIS_ViewerMode.Select ;
  end
end;

{-----------------------------------------------------------------------------
  btnFullExtentClick
  Resets the viewport so that all loaded layers fit inside the viewer window.
  Useful after zooming in to navigate back to the overview.
-----------------------------------------------------------------------------}
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{-----------------------------------------------------------------------------
  btnZoomInClick
  Doubles the current zoom level.  The Zoom property is a linear scale factor
  relative to the FullExtent view; doubling it halves the visible area.
-----------------------------------------------------------------------------}
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
   // Multiply the current zoom by 2 to zoom in by one step.
   GIS.Zoom := GIS.Zoom * 2 ;
end;

{-----------------------------------------------------------------------------
  btnZoomOutClick
  Halves the current zoom level, widening the visible area by a factor of two.
-----------------------------------------------------------------------------}
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
   // Divide the current zoom by 2 to zoom out by one step.
   GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
