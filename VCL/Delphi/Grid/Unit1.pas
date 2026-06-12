//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Grid Sample - How to manipulate grid (raster/DEM) layer presentation.

  This sample demonstrates:
    - Loading a raster DEM (Digital Elevation Model) grid file in ArcInfo
      Binary Grid (.adf) format using TGIS_LayerPixel.
    - Clearing altitude colour zones to revert to default rendering.
    - Defining custom altitude colour zones that map elevation ranges to
      named colours, creating a hypsometric tint effect.
    - Loading an external INI configuration file that stores layer display
      parameters (colour zones, shadow settings, etc.).
    - Toggling hill-shading (GridShadow) to give the terrain a 3-D appearance.
    - Reading the native (raw elevation) pixel value under the mouse cursor
      using TGIS_LayerPixel.Locate and displaying it in the status bar.

  Key TatukGIS API classes used:
    TGIS_ViewerWnd     - the map viewer control
    TGIS_LayerPixel    - represents any raster/grid layer (DEM, image, etc.)
    TGIS_ControlLegend - companion legend/layer list panel
    TGIS_Utils         - utility helpers (e.g. sample data directory)
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

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
  GisAllLayers,
  GisEditor,
  GisLayerPixel,
  GisLayerSHP,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlLegend,
  Vcl.GisViewerWnd;

type
  { Main form for the Grid sample application.
    Loads a DEM raster layer and allows the user to experiment with
    altitude colour zones, hill-shading, and INI-based configuration. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;           // The main map viewer control
    StatusBar1: TStatusBar;        // Shows coordinates and pixel altitude value
    ImageList1: TImageList;
    btnFullExtent: TToolButton;    // Zoom to full map extent
    ToolButton2: TToolButton;
    btnZoom: TToolButton;          // Activate rubber-band zoom mode
    btnDrag: TToolButton;          // Activate pan/drag mode
    ToolButton1: TToolButton;
    Splitter1: TSplitter;
    GIS_ControlLegend1: TGIS_ControlLegend;  // Layer legend/visibility panel
    btnClear: TButton;             // Remove all custom altitude zones (reset to defaults)
    btnUserDefined: TButton;       // Apply a hard-coded altitude colour zone set
    btnReloadIni: TButton;         // Reload the layer config from the layer's own INI file
    btnShadow: TButton;            // Toggle hillshade (GridShadow) on/off
    btnUserIni: TButton;           // Load a custom sample INI colour config
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnUserDefinedClick(Sender: TObject);
    procedure btnReloadIniClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnShadowClick(Sender: TObject);
    procedure btnUserIniClick(Sender: TObject);
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
  Opens the sample DEM (NED - National Elevation Dataset) in ArcInfo Binary
  Grid format.  TGIS_ViewerWnd.Open auto-detects the file format, creates a
  TGIS_LayerPixel internally and adds it to the viewer's layer list. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Open the NED elevation grid; the viewer auto-detects the ADF format
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
            '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf'
          ) ;
end;

{ TForm1.btnFullExtentClick
  Zooms the viewer to the combined extent of all loaded layers so the
  entire dataset is visible at once. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  // show full map
  GIS.FullExtent ;
end;

{ TForm1.btnZoomClick
  Switches the viewer interaction mode to Zoom, allowing the user to
  drag a rectangle to zoom into an area. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // set zoom mode
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ TForm1.btnDragClick
  Switches the viewer interaction mode to Drag (pan), allowing the user
  to scroll the map by clicking and dragging. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  // set drag mode
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

{ TForm1.btnClearClick
  Removes all custom altitude colour zones from the pixel layer, reverting
  it to the default rendering style loaded from the layer's configuration.
  AltitudeMapZones is a list of "minVal, maxVal, colour, label" strings
  that define a hypsometric tint. Clearing it makes TatukGIS fall back to
  its built-in greyscale gradient. }
procedure TForm1.btnClearClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  // Cast Items[0] to TGIS_LayerPixel to access raster-specific properties
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  // Remove all elevation-to-colour mappings
  ll.Params.Pixel.AltitudeMapZones.Clear ;
  // Force a full redraw of the viewer
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnUserDefinedClick
  Demonstrates assigning a custom hypsometric (altitude-to-colour) scheme
  directly in code.  Each zone string follows the format:
    "minElevation, maxElevation, colourName, zoneLabel"
  Elevation values are in the native unit of the DEM (metres for NED). }
procedure TForm1.btnUserDefinedClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  // Always clear before adding new zones to avoid duplicate entries
  ll.Params.Pixel.AltitudeMapZones.Clear ;
  // Define six elevation bands covering the terrain range in this DEM
  ll.Params.Pixel.AltitudeMapZones.Add( '200,  400 , OLIVE , VERY LOW') ;
  ll.Params.Pixel.AltitudeMapZones.Add( '400,  700 , OLIVE , LOW'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '700,  900 , GREEN , MID'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '900,  1200, BLUE  , HIGH'    ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '1200, 1700, RED   , SKY'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '1700, 2200, YELLOW, HEAVEN'  ) ;
  // Redraw the viewer so the new colour scheme is applied immediately
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnReloadIniClick
  Reloads the display configuration from the INI file that is co-located
  with the grid data file.  TatukGIS looks for a file with the same path
  and an ".ini" suffix; setting ConfigName explicitly allows pointing to
  any config file.  RereadConfig re-parses the file and updates all
  display parameters (colour zones, shadow, transparency, etc.). }
procedure TForm1.btnReloadIniClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  // Point ConfigName to the data file itself - TatukGIS will append ".ini"
  ll.ConfigName := TGIS_Utils.GisSamplesDataDirDownload +
                   '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf' ;
  // Re-read and apply the configuration from the associated INI file
  ll.RereadConfig ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnShadowClick
  Toggles the hill-shading (GridShadow) effect.  When enabled, TatukGIS
  computes a simulated directional light source over the DEM surface,
  darkening north-facing slopes and brightening south-facing ones.
  This dramatically improves the perceived depth of the terrain. }
procedure TForm1.btnShadowClick(Sender: TObject);
var
  ll : TGIS_LayerPixel  ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  // Toggle: if shadow was on, turn it off; if off, turn it on
  ll.Params.Pixel.GridShadow := not ll.Params.Pixel.GridShadow ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.btnUserIniClick
  Loads a pre-built sample INI file (dem_ned.ini) that ships with the
  TatukGIS sample data.  This is useful to show that the colour
  configuration can be stored externally and reused across projects without
  modifying code. }
procedure TForm1.btnUserIniClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  // Point to the bundled sample INI configuration file
  ll.ConfigName := TGIS_Utils.GisSamplesDataDirDownload +
                   '\Samples\Projects\dem_ned.ini' ;
  ll.RereadConfig ;
  GIS.InvalidateWholeMap ;
end;

{ TForm1.GISMouseMove
  Reads the raw (native) pixel value from the DEM at the map coordinate
  under the mouse and displays it in the status bar.

  How it works:
    1. ScreenToMap converts the screen pixel (X, Y) to map/geographic coords.
    2. TGIS_LayerPixel.Locate queries the raster at that point and returns:
         rgb      - the rendered colour at that pixel
         natives  - array of raw band values (element [0] = elevation in metres)
         transp   - whether the pixel is transparent (outside data extent)
    3. The raw elevation value is shown in the status bar panel. }
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg     : TGIS_Point       ;  // Geographic map coordinate
  ll      : TGIS_LayerPixel  ;  // Reference to the grid layer
  rgb     : TGIS_Color       ;  // Rendered colour at the queried point
  natives : TGIS_DoubleArray ;  // Raw band values (elevation in metres at [0])
  transp  : Boolean          ;  // True if the queried point is outside the data
begin
  // Avoid querying while the map is being redrawn to prevent re-entrant calls
  if GIS.InPaint then exit ;

  // Convert screen coordinates to geographic map coordinates
  ptg := GIS.ScreenToMap( Point( X, Y ) ) ;
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;

  // Query the raster value at the given map point
  if ll.Locate( ptg, rgb, natives, transp ) then
    // natives[0] holds the raw DEM elevation value in the layer's native unit
    StatusBar1.Panels[1].Text := FloatToStr( natives[0] )
  else
    StatusBar1.Panels[1].Text := 'Unknown' ;
end;

end.
