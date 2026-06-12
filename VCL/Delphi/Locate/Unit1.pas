//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Locate Sample — Demonstrates feature identification and location by finding shapes
  at the cursor position using spatial queries and pixel-to-coordinate conversion.

  Key concepts illustrated:
    - Feature location: finding which shape is at a given position
    - Screen-to-map coordinate conversion: ScreenToMap transforms pixel coordinates
    - Spatial tolerance: 5-pixel screen tolerance for easier feature selection
    - GIS.Locate: queries features at a geographic position
    - Shape attributes: retrieving field values from selected features
    - Shape flashing: visual feedback highlighting the selected shape
    - Dynamic status bar: real-time display of feature attributes

  User workflow:
    1. Hover mouse over the map to see feature name in status bar
    2. Click on a feature to flash it (visual feedback)
    3. Use zoom buttons to zoom in/out
    4. Click "Full Extent" to show all counties
    5. Hover/click on different counties to identify them

  Spatial operations:
    - TGIS_ViewerWnd.ScreenToMap(point) - convert screen pixel to geographic coordinate
    - TGIS_ViewerWnd.Locate(point, tolerance) - find topmost shape at location
      The tolerance parameter accounts for screen resolution and allows easier selection
      of small features (e.g., 5 pixels = ~5 screen pixels screen distance)
    - TGIS_Shape.Flash() - briefly highlight the shape for visual feedback

  Data: California counties (NAME field displayed)

  Concepts:
    - Coordinate systems: screen pixels vs. geographic coordinates
    - Z-order/topmost: Locate returns the topmost/visible shape at the position
    - Tolerance: important for small features or low-resolution displays
}

unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisLayerSHP,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main form for the Locate sample.
    Demonstrates pixel and vector feature location/identification. Users can click on the map
    to locate features at that position and retrieve their attributes and spatial properties. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
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


{
  FormCreate
  Initializes the sample by loading the California counties shapefile.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  { Load the California counties shapefile into the viewer }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\\World\Countries\USA\States\California\Counties.shp' ) ;
end;

{
  GISMouseMove
  Called continuously as mouse moves over the map.
  Locates the feature at the cursor and displays its name in the status bar.

  Algorithm:
    1. Convert screen pixel coordinates to geographic map coordinates
    2. Search for features at that geographic position (with tolerance)
    3. If found, display the feature's NAME attribute
    4. If not found, clear the status bar
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  { Guard: skip if no layers loaded or painting in progress }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Find the topmost shape at the map coordinate.
    Tolerance of 5/GIS.Zoom converts 5 screen pixels to map distance
    to account for display resolution and allow easier feature selection }
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ;

  { Display the feature's NAME attribute in the status bar, or clear if no feature }
  if shp = nil then
     StatusBar.SimpleText := ''  { No feature found: clear status }
  else
     StatusBar.SimpleText := shp.GetField( 'NAME' );  { Show county name }
end;

{
  GISMouseDown
  Called when user clicks on the map.
  Locates the feature at the click position and flashes it for visual feedback.
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  { Guard: skip if no layers loaded or painting in progress }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Convert screen pixel to geographic coordinate }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Find the shape at the clicked location with 5-pixel tolerance }
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ;

  { If a shape was found, flash it (briefly highlight/invert for visual feedback) }
  if shp <> nil then
     shp.Flash ;
end;

{ Fit viewport to show all counties (full extent) }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ Zoom in: doubles the current zoom factor }
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ Zoom out: halves the current zoom factor }
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
