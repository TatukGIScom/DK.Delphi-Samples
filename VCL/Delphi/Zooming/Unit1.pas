//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
// Zooming - TatukGIS Developer Kernel (DK11) sample.
//
// Demonstrates multiple ways to zoom and navigate a loaded map:
//   1. Loading a TatukGIS project file (.ttkproject) which bundles all
//      layer definitions, styles, and coordinate system settings.
//   2. Full-extent button - zooms the viewer to display all loaded data.
//   3. Zoom mode - rubber-band rectangle zoom (left click + drag to zoom in,
//      right click to zoom out by one step).
//   4. Drag mode - panning by clicking and dragging the map.
//   5. Mouse wheel zoom - smooth zoom centered on the cursor position using
//      GIS.ZoomBy(factor, x, y), where the x,y anchor keeps the point under
//      the cursor stationary while the rest of the map scales around it.

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

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main form for the Zooming sample.
    Demonstrates viewer navigation: full extent, zoom mode, drag mode,
    and mouse-wheel zoom anchored to the cursor position. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    // The central GIS map viewer control
    GIS: TGIS_ViewerWnd;
    // Status bar shown at the bottom of the form
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    // "Full Extent" toolbar button - zooms to show all loaded data
    btnFullExtent: TToolButton;
    ToolButton2: TToolButton;
    // "Zoom" toolbar button - enables rubber-band zoom mode
    btnZoom: TToolButton;
    // "Drag" toolbar button - enables pan/drag mode
    btnDrag: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    // Mouse wheel handlers for programmatic zoom centered on cursor
    procedure GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

// Form creation event - loads the sample project file on startup.
// A .ttkproject file is a TatukGIS project format that bundles multiple
// layer definitions, their rendering styles, and coordinate system settings
// into a single file, so no manual layer configuration is required.
procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
end;

// "Full Extent" button click event.
// Resets the viewport to display the complete spatial extent of all loaded
// layers, fitting the entire dataset within the viewer bounds.
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

// "Zoom" button click event.
// Switches the viewer to Zoom mode. The user can left-click and drag to draw
// a rubber-band rectangle defining the new view area; a right-click zooms out
// by one step.
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

// "Drag" button click event.
// Switches the viewer to Drag mode, allowing the user to pan the map by
// clicking and dragging with the mouse.
procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

// Mouse wheel scroll-down (wheel away from user) event - zooms in.
// GIS.ZoomBy(factor, x, y) scales the view by 'factor' centered on the
// screen point (x, y), so the map point under the cursor stays fixed:
//   factor 5/4 = 1.25 -> zoom out (wider view, more area visible)
//   factor 4/5 = 0.80 -> zoom in  (narrower view, more detail)
// Note: MousePos is in screen coordinates; ScreenToClient converts it
// to client (form-relative) coordinates required by ZoomBy.
procedure TForm1.GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
begin
  if GIS.IsEmpty then exit ;

  // Convert from screen to GIS control client coordinates
  pt := GIS.ScreenToClient( MousePos ) ;

  // Zoom in: factor < 1 magnifies the map (smaller area, more detail).
  // The cursor position (pt.X, pt.Y) is the fixed anchor point.
  GIS.ZoomBy( 5/4, pt.X, pt.Y ) ;

  // Signal that the wheel event was handled so the form does not scroll
  Handled := True ;
end;

// Mouse wheel scroll-up (wheel toward user) event - zooms out.
// Uses the same GIS.ZoomBy mechanism as GISMouseWheelDown but with the
// inverse factor to produce the opposite direction of zoom.
procedure TForm1.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
begin
  if GIS.IsEmpty then exit ;

  // Convert from screen to GIS control client coordinates
  pt := GIS.ScreenToClient( MousePos ) ;

  // Zoom out: factor > 1 shrinks the map (larger area, less detail).
  // The cursor position (pt.X, pt.Y) is the fixed anchor point.
  GIS.ZoomBy( 4/5, pt.X, pt.Y ) ;

  // Signal that the wheel event was handled so the form does not scroll
  Handled := True ;
end;

end.
