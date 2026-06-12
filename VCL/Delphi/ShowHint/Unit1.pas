//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  ShowHint Sample — Demonstrates displaying dynamic tooltips (hints) with feature
  attribute data when hovering over shapes on the map.

  Key concepts illustrated:
    - Tooltip/hint text binding to feature attributes
    - Mouse-over feature detection with spatial location
    - Custom hint styling (color, position, timing)
    - Application hint configuration (HintPause, HintHidePause, etc.)
    - Attribute field selection and display
    - Dynamic hint color changes based on cursor location (map vs toolbar)
    - Cursor coordinates display in status bar

  User workflow:
    1. Hover over shapes on the map to see hints with attribute values
    2. Use "Hints" button to configure:
       - Which layer to show hints for
       - Which attribute field to display in the hint
       - Hint color and on/off toggle
    3. Hover over toolbar to revert hint color to standard

  Hints display:
    - Positioned 10 pixels right and 10 pixels up from the cursor
    - Color configurable via hint settings dialog
    - Auto-hide after 2 seconds
    - Shows feature attribute data from selected field (default: PPPTNAME)

  Data: Poland administrative boundaries (.ttkproject)
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
  Vcl.ImgList,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayer,
  GisLayerShp,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    btnHints: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnHintsClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    hintField   : String;
    hintLayer   : String;
    hintDisplay : Boolean;
    hintColor   : TColor;
    hintColorStd: TColor;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  frmHint;

{$R *.DFM}


{
  FormCreate
  Initializes the ShowHint sample:
    1. Sets up hint display parameters (field name, layer, color)
    2. Configures global Application hint timing and appearance
    3. Loads the Poland shapefile/project
}
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  { Initialize hint configuration with defaults }
  hintDisplay := true;                         { Hints enabled by default }
  hintColor   := clYellow;                     { Default hint background color }
  hintField   := 'PPPTNAME';                   { Default attribute field to display }
  hintLayer   := 'city1';                      { Default layer to show hints for }
  hintColorStd:= Application.HintColor;        { Save standard hint color for toolbar }

  { Configure Application-wide hint timing and appearance }
  Application.ShowHint := true;                { Enable hints globally }
  Application.HintPause := 50;                 { Delay before hint appears (ms) }
  Application.HintShortPause := 50;            { Short pause between hints (ms) }
  Application.HintHidePause := 2000;           { Duration hint is visible (ms) }
  Application.HintColor := hintColor;          { Set initial hint background color }

  { Load the Poland administrative boundaries project }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
end;

{ Fit viewport to show all layers (full extent) }
procedure TfrmMain.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent;
end;

{ Zoom in: doubles the current zoom factor }
procedure TfrmMain.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ Zoom out: halves the current zoom factor }
procedure TfrmMain.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

{
  btnHintsClick
  Opens the Hints Configuration dialog to allow user to:
    - Enable/disable hints
    - Choose which layer to show hints for
    - Select which attribute field to display in hints
    - Set the hint background color
}
procedure TfrmMain.btnHintsClick(Sender: TObject);
begin
  { Show the hint configuration modal dialog }
  if frmHints.ShowModal = mrCancel then exit ;

  { Retrieve updated configuration values from the dialog }
  hintDisplay := frmHints.chkShow.Checked;               { Hints enabled/disabled }
  hintColor   := frmHints.paColor.Color;                 { Selected hint color }
  hintField   := frmHints.lbFields.Items[frmHints.lbFields.ItemIndex];      { Selected field }
  hintLayer   := frmHints.cbLayers.Items[frmHints.cbLayers.ItemIndex];      { Selected layer }
end;

{
  GISMouseMove
  Called continuously as the mouse moves over the map.
  Detects features under the cursor and displays their attribute data as hints.

  Algorithm:
    1. Get the hint layer from the viewer
    2. Convert cursor screen coordinates to geographic coordinates
    3. Find the topmost shape at the cursor location
    4. If shape found: display its attribute as a hint tooltip
    5. If no shape: hide the hint
    6. Display coordinate values in the status bar
}
procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
  str : String;
  la  : TGIS_Layer ;
  lv  : TGIS_LayerVector   ;
begin
  { Guard: skip if no layers loaded or currently painting }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Get the layer specified in the hint configuration (default: 'city1') }
  la := TGIS_Layer(GIS.Get( hintLayer )) ;

  { Guard: exit if layer not found or is not a vector layer }
  if la = nil then exit ;
  if not (la is TGIS_LayerVector ) then exit ;

  { Cast to vector layer for feature access }
  lv := la as TGIS_LayerVector ;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Find the topmost shape at the cursor with 5-pixel screen tolerance }
  shp := TGIS_Shape( lv.Locate( ptg, 5/GIS.Zoom ) ) ;

  { If no shape found at cursor: hide hint and show empty text }
  if shp = nil then
  begin
    GIS.Hint := '';
    GIS.ShowHint := false;
  end
  { If shape found and hints enabled: display the attribute value as a hint }
  else if hintDisplay then
  begin
    { Set the hint color to the configured color }
    Application.HintColor := hintColor;

    { Extract the value from the configured attribute field }
    str := shp.GetField(hintField);

    { Set the hint text and enable it }
    GIS.Hint := str;
    GIS.ShowHint := true;

    { Activate the hint at cursor position (10px right, 10px up) }
    Application.ActivateHint( ClientToScreen( Point(X + 10,Y - 10) ) );

    { Display cursor coordinates in the status bar }
    str := Format( 'x: %.4f   y: %.4f', [ptg.X, ptg.Y] ) ;
    StatusBar1.SimpleText := str;
  end;
end;

{
  ToolBar1MouseMove
  Resets the hint color to the standard color when mouse moves over the toolbar.
  Ensures toolbar hints use standard appearance, not the custom map hint color.
}
procedure TfrmMain.ToolBar1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  { Revert to standard hint color when hovering over toolbar buttons }
  Application.HintColor := hintColorStd;
end;

end.
