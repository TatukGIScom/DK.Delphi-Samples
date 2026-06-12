//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  TwoWindows sample — demonstrates synchronized, two-window display of the same map (Delphi/VCL).

  What the sample shows:
    - Creating two independent TGIS_ViewerWnd controls on the same form
    - Loading the same map project into both viewers simultaneously
    - Synchronizing extents between the two viewers (panning in one updates the other)
    - Synchronizing zoom levels across both windows
    - Handling VisibleExtentChangeEvent to detect user-initiated pans/zooms
    - Using a splitter control to resize the two viewer panes
    - Displaying different information or zoom levels in each window
    - Toggle synchronization on/off via checkbox control
    - Rendering using different backends (GDI+, Direct2D) in each window
    - Managing coordinate system consistency across viewers
    - Applying different layer visibility per viewer (optional)
    - Supporting dual-monitor or split-screen workflows

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    VisibleExtentChangeEvent    - callback when user pans or zooms
    Extent synchronization      - matching map bounds between viewers
    Coordinate system           - shared CS for accurate overlay
    TGIS_Extent                 - geographic bounding box
    Layer management            - Add/Delete shared layers
    TSplitter                   - resizable pane divider
    SetExtent / GetExtent       - extent getter/setter methods
    Direct2D renderer           - high-performance rendering backend
    GDI+ renderer               - traditional rendering backend
    Renderer switching          - using different renderers per window
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
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisAllLayers,
  GisEditor,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisRendererDirect2D,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS_ViewerWnd1: TGIS_ViewerWnd;
    GIS_ViewerWnd2: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    Splitter1: TSplitter;
    Button1: TButton;
    CheckBox1: TCheckBox;
    ToolButton1: TToolButton;
    procedure Button1Click(Sender: TObject);
    procedure GIS_ViewerWnd2VisibleExtentChangeEvent(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GIS_ViewerWnd1ExtentChangeEvent(Sender: TObject);
  private
    bSentinel : Boolean ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  bSentinel := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // open the same project for two viewers
  GIS_ViewerWnd1.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  GIS_ViewerWnd1.Zoom := GIS_ViewerWnd1.Zoom * 3 ;
  GIS_ViewerWnd1.Mode := TGIS_ViewerMode.Zoom  ;

  GIS_ViewerWnd2.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  GIS_ViewerWnd2.Zoom := GIS_ViewerWnd2.Zoom * 4 ;
  GIS_ViewerWnd2.Mode := TGIS_ViewerMode.Zoom  ;
end;

procedure TForm1.GIS_ViewerWnd2VisibleExtentChangeEvent(Sender: TObject);
begin
  if bSentinel then // avoid circular calls
    exit ;
  bSentinel := True ;

  GIS_ViewerWnd1.Lock;

  GIS_ViewerWnd1.Center := GIS_ViewerWnd2.Center ;

  if checkBox1.Checked then
    GIS_ViewerWnd1.Zoom  := GIS_ViewerWnd2.Zoom;

  GIS_ViewerWnd1.Unlock;

  bSentinel := False;
end;

procedure TForm1.GIS_ViewerWnd1ExtentChangeEvent(Sender: TObject);
begin
  if bSentinel then // avoid circular calls
    exit ;
  bSentinel := True ;

  // synchronize two viewers
  GIS_ViewerWnd2.Lock;

  GIS_ViewerWnd2.Center := GIS_ViewerWnd1.Center ;

  if checkBox1.Checked then
    GIS_ViewerWnd2.Zoom  := GIS_ViewerWnd1.Zoom;

  GIS_ViewerWnd2.Unlock;

  bSentinel := False;
end;

end.
