//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Pixel - demonstrates how to open and display raster (pixel) layers using
  different rendering modes provided by TatukGIS.

  The sample loads a pre-built .ttkproject file that contains a raster layer
  and lets the user switch between several rendering profiles via a combo box:
    - Normal              : standard colour rendering
    - Normal with histogram: applies histogram stretch for better contrast
    - Grayscale           : converts all bands to a single grey channel
    - Transparent         : renders with alpha/transparency support
    - Colorize            : maps pixel values through a colour gradient
    - Inversion           : inverts all colour channels
    - Inversion by RGB    : inverts individual R, G, B channels separately

  Key TatukGIS API concepts shown here:
    - TGIS_ViewerWnd  : the main map viewer control
    - TGIS_Utils.GisSamplesDataDirDownload : resolves the root path of the
        bundled sample data so hard-coded absolute paths are avoided
    - GIS.Open()      : opens a .ttkproject (or any supported raster/vector
        file) and adds all its layers to the viewer
    - GIS.FullExtent(): zooms the view to fit all loaded layers
    - TGIS_ViewerMode : enumeration that controls user-interaction mode
        (Zoom = rubber-band zoom, Drag = pan/scroll)
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

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisUtils,
  GisTypesUI,
  GisViewer,

  Vcl.GisViewerWnd;

type
  { Main form for the Pixel sample application.
    Demonstrates loading and displaying a raster pixel layer through
    various rendering project configurations. }
  TForm1 = class(TForm)
    ToolBar1: TToolBar;        // Toolbar housing navigation buttons
    GIS: TGIS_ViewerWnd;       // The TatukGIS map viewer control
    StatusBar1: TStatusBar;    // Status bar at the bottom of the form
    ComboProject: TComboBox;   // Drop-down for selecting a rendering project
    btnFullExtent: TToolButton; // Zoom to full extent of all loaded layers
    btnZoom: TToolButton;       // Switch to rubber-band zoom interaction mode
    btnDrag: TToolButton;       // Switch to pan/drag interaction mode
    ToolButton4: TToolButton;   // Toolbar separator
    ToolButton5: TToolButton;   // Toolbar separator
    ImageList1: TImageList;     // Icons used by the toolbar buttons
    procedure FormCreate(Sender: TObject);
    procedure ComboProjectChange(Sender: TObject);
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
  Runs when the form is first created.
  Selects the first project in the combo box and triggers an initial load
  so the viewer is populated as soon as the application starts. }
procedure TForm1.FormCreate(Sender: TObject);
begin
  ComboProject.ItemIndex := 0 ;
  ComboProjectChange( self ) ;
end;

{ TForm1.ComboProjectChange
  Fires whenever the user picks a different project from the combo box.
  Calls GIS.Open() with the path to the selected .ttkproject file.
  GisSamplesDataDirDownload returns the base directory for sample data,
  keeping the path independent of any particular installation layout. }
procedure TForm1.ComboProjectChange(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Projects\' + ComboProject.Items[ ComboProject.ItemIndex ] ) ;
end;

{ TForm1.btnFullExtentClick
  Resets the map view so that all loaded layers are visible simultaneously. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ TForm1.btnZoomClick
  Switches the viewer to Zoom mode: the user draws a rectangle to zoom in,
  or right-clicks to zoom out. }
procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

{ TForm1.btnDragClick
  Switches the viewer to Drag mode: the user can pan the map by clicking
  and dragging. }
procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
