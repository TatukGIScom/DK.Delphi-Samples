//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Renderer sample — demonstrates how to load and display a TatukGIS project
  file that has been pre-configured with custom rendering rules.

  Key concepts shown:
    - Opening a .ttkproject file with TGIS_ViewerWnd.Open
    - Switching the viewer interaction mode between Zoom and Drag using the
      TGIS_ViewerMode enumeration
    - Restoring the full map extent with TGIS_ViewerWnd.FullExtent

  The actual rendering definitions (symbol styles, colors, scale-dependent
  rules, etc.) live inside the renderer.ttkproject file.  This form simply
  loads that project and wires up the toolbar buttons so the user can
  navigate the map.
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

  //GisLicense,       // Uncomment to embed a run-time license key
  GisTypes,           // Core TatukGIS type definitions
  GisEditor,          // Map editing support
  GisLayerSHP,        // Shapefile layer driver
  GisUtils,           // Utility helpers (e.g. GisSamplesDataDirDownload)
  GisTypesUI,         // UI-related GIS types including TGIS_ViewerMode
  GisViewer,          // Base viewer classes

  Vcl.GisViewerWnd;   // VCL-specific map viewer window control

type
  { TForm1 — main application form.
    Hosts the map viewer (GIS), a toolbar with navigation buttons, and a
    status bar. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;               // Navigation toolbar
    GIS: TGIS_ViewerWnd;             // TatukGIS map viewer control
    StatusBar1: TStatusBar;           // Status bar (coordinates, messages)
    btnFullExtent: TToolButton;       // Button: zoom to full map extent
    btnZoom: TToolButton;             // Button: switch to Zoom interaction mode
    btnDrag: TToolButton;             // Button: switch to Drag/Pan interaction mode
    ToolButton4: TToolButton;         // Toolbar separator
    ImageList1: TImageList;           // Icons for toolbar buttons
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


{ TForm1.FormCreate
  Called when the form is first created.  Opens the renderer project file
  from the shared sample data directory so the map is ready when the form
  appears.

  TGIS_Utils.GisSamplesDataDirDownload returns the path to the downloaded
  TatukGIS sample data set; the project file contains pre-configured layer
  rendering definitions. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Load the pre-configured renderer project; all layer styles are embedded
  // in the .ttkproject file — no additional setup is required here.
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Projects\renderer.ttkproject' );
end;


{ TForm1.btnFullExtentClick
  Zooms the map out to show all loaded layers simultaneously.
  TGIS_ViewerWnd.FullExtent recomputes the bounding rectangle that covers
  every visible layer and adjusts the view accordingly. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ TForm1.btnZoomClick
  Switches the viewer to Zoom interaction mode.
  In Zoom mode the user can draw a rubber-band rectangle to zoom into a
  specific area, or use the scroll wheel to zoom in/out.
  TGIS_ViewerMode.Zoom is defined in GisTypesUI. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ TForm1.btnDragClick
  Switches the viewer to Drag (pan) interaction mode.
  In Drag mode the user can click and drag the map to pan across the dataset.
  TGIS_ViewerMode.Drag is defined in GisTypesUI. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
