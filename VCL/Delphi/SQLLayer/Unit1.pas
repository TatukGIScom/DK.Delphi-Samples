//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  SQLLayer Sample - Delphi VCL
  ============================
  Demonstrates how to open and display an SQL Layer using TatukGIS DK11.

  An SQL layer (*.ttkls file) is a virtual layer definition that describes how
  to retrieve spatial data from a relational database (e.g. PostgreSQL/PostGIS,
  SQL Server, SQLite, Oracle Spatial) using a SQL query.  The .ttkls file
  contains the connection string, the SQL statement, and field mappings; it
  can be opened just like any other layer format supported by the DK.

  Key concepts shown:
    - Opening a .ttkls project file with TGIS_ViewerWnd.Open
    - Fitting the view to the full data extent with FullExtent
    - Switching the viewer interaction mode between Zoom and Drag

  To adapt this sample to your own database:
    Edit the gistest.ttkls file to supply your connection string and SQL query.
    The .ttkls file can also be opened in the TatukGIS Editor for visual
    configuration.
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,

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

  //GisLicense,   // Uncomment and configure if using a licensed build
  GisTypes,       // Core TatukGIS type definitions (TGIS_Point, extents, etc.)
  GisAllLayers,   // Registers all available layer drivers (SHP, raster, SQL, …)
  GisEditor,      // Layer editing support
  GisLayer,       // Base layer class
  GisLayerSHP,    // Shapefile layer driver
  GisTypesUI,     // UI-related type extensions (TGIS_ViewerMode, colours, …)
  GisUtils,       // Utility helpers, including GisSamplesDataDirDownload
  GisViewer,      // Base viewer class

  Vcl.GisViewerWnd; // VCL windowed map viewer component

type
  { Main form for the SQLLayer sample.
    Demonstrates advanced SQL database layer operations and styling. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;          // Toolbar hosting the navigation buttons
    GIS: TGIS_ViewerWnd;         // TatukGIS map viewer — renders the SQL layer
    StatusBar1: TStatusBar;      // Status bar at the bottom of the window
    ImageList1: TImageList;      // Icon images used by the toolbar buttons
    btnFullExtent: TToolButton;  // Button: zoom to full data extent
    ToolButton2: TToolButton;    // Toolbar separator
    btnZoom: TToolButton;        // Button: activate zoom interaction mode
    btnDrag: TToolButton;        // Button: activate pan/drag interaction mode
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


/// <summary>
///   Called when the form is first created.
///   Opens the SQL layer project file and fits the view to its full extent.
/// </summary>
/// <remarks>
///   GisSamplesDataDirDownload returns the path to the TatukGIS sample data
///   directory (downloaded separately).  The gistest.ttkls file inside
///   Samples\SQLLayers\ contains the database connection and SQL definition.
///   Edit that file to point to your own database before running.
/// </remarks>
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Open the SQL layer definition file (.ttkls).
  // TGIS_ViewerWnd.Open accepts a file path to any supported layer or project
  // format; for .ttkls it connects to the configured database and executes
  // the SQL query to produce the virtual layer.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +  '\Samples\SQLLayers\gistest.ttkls' ) ;

  // Zoom the view so that all loaded features are visible.
  GIS.FullExtent ;
end;

/// <summary>
///   Zooms the map out to the full data extent, making all features visible.
/// </summary>
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

/// <summary>
///   Switches the viewer to Zoom mode.
///   In this mode, left-click-drag draws a rubber-band rectangle to zoom in;
///   right-click zooms out.
/// </summary>
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // TGIS_ViewerMode.Zoom — rubber-band zoom interaction
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

/// <summary>
///   Switches the viewer to Drag (pan) mode.
///   In this mode, click-drag scrolls the map without changing the zoom level.
/// </summary>
procedure TForm1.btnDragClick(Sender: TObject);
begin
  // TGIS_ViewerMode.Drag — pan/scroll interaction
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
