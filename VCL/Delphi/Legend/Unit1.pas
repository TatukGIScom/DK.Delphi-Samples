//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Legend Sample - Delphi VCL

  Demonstrates how to use the TGIS_ControlLegend panel alongside a map viewer.
  The legend control provides an interactive, dockable layer list that lets the
  user toggle layer visibility, reorder layers, expand/collapse layer symbology,
  and open layer property dialogs - all without writing any extra code.

  Key concepts shown:
    - Placing TGIS_ControlLegend next to TGIS_ViewerWnd and linking them via
      the GIS_Viewer property so the legend reflects the loaded map automatically.
    - Switching between two display modes at runtime:
        * TGIS_ControlLegendMode.Layers  - flat list of every individual layer
        * TGIS_ControlLegendMode.Groups  - tree grouped by layer group membership
    - Opening a .ttkproject file that bundles multiple SHP layers together.
    - Controlling the viewer interaction mode (Zoom / Drag).
    - Persisting any layer-style changes back to the project file with SaveAll.
    - Reflecting the current map scale in the status bar after each repaint.
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
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,       // Uncomment when deploying with a commercial license key
  GisTypes,           // Core TatukGIS type definitions
  GisEditor,          // Layer editing support
  GisLayerSHP,        // SHP/DBF vector layer driver
  GisLayerVector,     // Base vector layer class
  GisTypesUI,         // UI-specific types (TGIS_ViewerMode, etc.)
  GisUtils,           // Helper utilities (GisSamplesDataDirDownload, etc.)
  GisViewer,          // Base viewer class
  GisLegend,          // Legend model (layer list, group model)

  Vcl.GisControlLegend,  // TGIS_ControlLegend VCL control
  Vcl.GisViewerWnd;      // TGIS_ViewerWnd VCL control (the interactive map canvas)

type
  { Main application form for the Legend sample.
    Hosts a TGIS_ViewerWnd (map canvas) and a TGIS_ControlLegend panel
    side-by-side, separated by a resizable splitter. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;           // The main interactive map canvas
    StatusBar1: TStatusBar;         // Displays current map scale after each paint
    ImageList1: TImageList;         // Toolbar button icons
    btnFullExtent: TToolButton;     // Zooms to the full extent of all loaded layers
    ToolButton2: TToolButton;       // Separator
    btnZoom: TToolButton;           // Switches viewer to Zoom interaction mode
    btnDrag: TToolButton;           // Switches viewer to Drag/Pan interaction mode
    ToolButton1: TToolButton;       // Separator
    Splitter1: TSplitter;           // Resizable divider between legend panel and map
    GIS_ControlLegend1: TGIS_ControlLegend; // Interactive legend panel linked to GIS viewer
    SpeedButton1: TSpeedButton;     // Save configuration button
    TabControl1: TTabControl;       // Tabs to switch legend display mode (Layers / Groups)
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GISAfterPaint(_sender, _canvas: TObject);
    procedure TabControl1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{ TForm1.FormCreate
  Called once when the form is first created.
  Opens the sample Poland multi-layer project so the map and legend are
  populated immediately without requiring user interaction.
  TGIS_ViewerWnd.Open() accepts a .ttkproject path; it loads all embedded
  layer references and refreshes the legend control automatically because
  GIS_ControlLegend1.GIS_Viewer is already pointed at GIS (set in the DFM). }
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Load the bundled Poland DCW project; GIS_ControlLegend1 will populate
  // its layer list automatically because it is linked to this viewer.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
end;

{ TForm1.btnFullExtentClick
  Resets the map viewport to show all loaded layers at their combined extent.
  Useful after zooming into a specific area and wanting to return to the
  overview. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  // Zoom out to fit the complete bounding box of all visible layers
  GIS.FullExtent ;
end;

{ TForm1.btnZoomClick
  Switches the viewer to Zoom mode.
  In Zoom mode, a left-click-drag draws a rubber-band rectangle that the
  viewer zooms into; a right-click zooms back out by a fixed factor. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // TGIS_ViewerMode.Zoom: left-drag to zoom in, right-click to zoom out
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ TForm1.btnDragClick
  Switches the viewer to Drag (pan) mode.
  In Drag mode the user pans the map by click-dragging, which is the most
  natural way to explore a map after zooming in. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  // TGIS_ViewerMode.Drag: click-drag to pan the visible map extent
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{ TForm1.Button1Click
  Saves all layer configuration changes (symbology, visibility, order) back to
  the originating project or layer files.
  Guards against calling SaveAll on an empty viewer to avoid an error. }
procedure TForm1.Button1Click(Sender: TObject);
begin
  if GIS.IsEmpty then exit ;  // Nothing loaded - nothing to save

  // Persist any legend changes (visibility flags, symbology edits, layer order)
  // back to the .ttkproject file and its referenced layer files.
  GIS.SaveAll ;
end;

{ TForm1.GISAfterPaint
  Fired by TGIS_ViewerWnd after every completed map repaint.
  Updates the status bar with the human-readable map scale string
  (e.g. "1 : 250 000") so the user always knows the current zoom level. }
procedure TForm1.GISAfterPaint(_sender, _canvas: TObject);
begin
  // ScaleAsText returns a formatted "1 : N" string for the current viewport
  StatusBar1.Panels[1].Text := GIS.ScaleAsText ;
end;

{ TForm1.TabControl1Change
  Switches the legend control between its two display modes when the user
  selects a different tab:
    Tab 0 (Layers) - shows a flat, ordered list of every individual layer.
                     Useful when the user wants to manage individual layers.
    Tab 1 (Groups) - shows layers organised into their logical group hierarchy.
                     Useful when the project uses group layers to structure data.
  Both modes support the same interactive features (visibility toggle,
  drag-to-reorder, expand to see symbology classes, double-click for properties). }
procedure TForm1.TabControl1Change(Sender: TObject);
begin
  if TabControl1.TabIndex = 0 then
    // Flat mode: each layer appears as a separate top-level item
    GIS_ControlLegend1.Mode := TGIS_ControlLegendMode.Layers
  else
    // Grouped mode: layers are nested inside their parent group nodes
    GIS_ControlLegend1.Mode := TGIS_ControlLegendMode.Groups ;
end;

end.
