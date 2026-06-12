//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Rotation Sample — Demonstrates interactive map rotation around a user-defined point.

  Key concepts illustrated:
    - Map rotation: TGIS_ViewerWnd.RotationAngle property (in radians)
    - Rotation point: TGIS_ViewerWnd.RotationPoint (center of rotation)
    - Interactive rotation control via trackbar slider
    - Changing rotation point with mouse clicks
    - Coordinate transformation: screen pixel coordinates to map coordinates
    - Feature identification on mouse hover

  User workflow:
    1. Click on the map to set the rotation center point
    2. Use trackbar or +/- buttons to rotate the map around that point
    3. Click "Reset" to return to 0 degrees rotation
    4. Hover over features to see their names in the status bar
    5. Use zoom buttons to zoom in/out

  Visual indicators:
    - North arrow control shows map rotation visually
    - Degree label displays current rotation angle
    - Rotation applies to all rendered layers and vector features

  Data: Poland boundary and administrative layers (.ttkproject file)
}
unit Unit1;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.Variants,

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
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes,
  Vcl.GisControlLegend,
  Vcl.GisViewerWnd,
  VCL.GisControlNorthArrow;

type
  TForm1 = class (TForm)
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    Button1: TButton;
    GIS: TGIS_ViewerWnd;
    ImageList1: TImageList;
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    CheckBox1: TCheckBox;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    decreaseBtn: TButton;
    rotationTB: TTrackBar;
    increaseBtn: TButton;
    degLabel: TLabel;
    GIS_ControlNorthArrow1: TGIS_ControlNorthArrow;
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton; Shift:
                           TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btnFullExtentClick(Sender: TObject);
    procedure decreaseBtnClick(Sender: TObject);
    procedure increaseBtnClick(Sender: TObject);
    procedure rotationTBChange(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


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

{ Reset rotation angle to 0 degrees (north-up) }
procedure TForm1.Button1Click(Sender: TObject);
begin
  rotationTB.Position := 0;
end;

{ Decrease rotation angle by 1 degree }
procedure TForm1.decreaseBtnClick(Sender: TObject);
begin
  rotationTB.Position := rotationTB.Position - 1;
end;

{
  FormCreate
  Initializes the rotation sample: loads the Poland shapefile/project,
  sets up the initial rotation point, and applies initial zoom and extent.
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  { Initialize rotation angle to 0 degrees (north-up orientation) }
  GIS.RotationAngle := 0 ;

  { Load the Poland administrative boundaries project (.ttkproject) }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;

  { Fit the viewport to show all loaded layers }
  GIS.FullExtent ;

  { Zoom in 2x for better visibility of the data }
  GIS.Zoom := GIS.Zoom * 2  ;

  { Set the rotation center point to the geographic center of the data extent.
    This is where the map will rotate around when the user rotates it. }
  GIS.RotationPoint := TGIS_Utils.GisCenterPoint( GIS.Extent ) ;
end;

{
  GISMouseDown
  Handles mouse clicks on the map.
  Sets the rotation center point to the clicked location.
  Optionally pans the viewport center to the same location.
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
begin
  { Guard: skip if no layers loaded }
  if GIS.IsEmpty then exit ;

  { Convert screen pixel coordinates to geographic map coordinates }
  { Set the rotation center (pivot point) to the clicked location.
    The map will rotate around this point when you adjust the trackbar. }
  GIS.RotationPoint := GIS.ScreenToMap( Point( X, Y ) );

  { Optional: if "Pan" checkbox is checked, also center the viewport on the clicked point }
  if CheckBox1.Checked then
    GIS.Center := GIS.ScreenToMap( Point( X, Y ) );
end;

{
  GISMouseMove
  Displays the name of the feature under the cursor in the status bar.
  Called continuously as the mouse moves over the map.
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y:
        Integer);
var
  ptg: TGIS_Point;
  shp: TGIS_Shape;
begin
  { Guard: skip if no layers loaded or painting in progress }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Find the topmost shape at the cursor location with 5-pixel screen tolerance.
    This tolerance makes it easier to select or identify small features. }
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ;

  { Display the feature name in the status bar, or clear it if no feature found }
  if shp = nil then
     StatusBar.Panels[1].Text := ''
  else
     { Access the 'name' attribute field from the feature's attribute table }
     StatusBar.Panels[1].Text := shp.GetField('name');
end;

{ Recalculate layer extents and fit the viewport to show all data }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

{ Increase rotation angle by 1 degree }
procedure TForm1.increaseBtnClick(Sender: TObject);
begin
  rotationTB.Position := rotationTB.Position + 1;
end;

{
  rotationTBChange
  Called when the trackbar is moved.
  Applies the new rotation angle to the viewer and updates the degree label.

  Algorithm:
    1. Get the trackbar position (degrees: -180 to +180)
    2. Convert degrees to radians using DegToRad function
    3. Apply the rotation angle to the GIS viewer
    4. Redraw the entire map with the new rotation
    5. Update the degree label to show current angle
}
procedure TForm1.rotationTBChange(Sender: TObject);
begin
  { Convert the trackbar position (degrees) to radians and apply to the viewer }
  GIS.RotationAngle := DegToRad(rotationTB.Position);

  { Redraw the entire map to show the rotation effect }
  GIS.InvalidateWholeMap;

  { Update the displayed degree value next to the trackbar }
  degLabel.Caption := 'Degree: ' + IntToStr ( rotationTB.Position ) ;
end;

end.
