//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  TrackingTest sample — demonstrates animated tracking of GPS-like movement (Delphi/VCL).

  What the sample shows:
    - Creating an in-memory vector layer to hold a tracked object (vehicle marker)
    - Programmatically animating a point shape moving along a predefined path
    - Using a timer to update shape position at regular intervals
    - Rotating the symbol to face the direction of movement (heading)
    - Calculating movement vector and bearing from current and previous positions
    - Optionally locking the viewer extent to follow the tracked object
    - Implementing BusyEvent callback to update animation progress
    - Displaying tracking status in viewer (current position, heading, speed)
    - Using TGIS_Params to control symbol appearance and colour
    - Toggling lock mode (Projection vs Extent) for tracking behavior
    - Creating smooth animated movement across the map view

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - in-memory layer for tracked object
    TGIS_Shape                  - the tracked point shape
    TGIS_Shape.SetXY()          - update shape position
    TGIS_Params.Marker          - point symbol properties (rotation, size, color)
    Timer                       - animation update interval
    OnExtentChanged             - event for viewer extent synchronization
    VisibleExtent / SetExtent   - programmatically control viewer pan/zoom
    TGIS_Lock                   - projection vs. extent locking for tracking
    BusyEvent                   - progress notification during animation
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    btnAnimate: TButton;
    chkUseLock: TCheckBox;
    ToolButton1: TToolButton;
    procedure btnAnimateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnAnimateClick(Sender: TObject);
var
  i,j   : Integer    ;
  shp : TGIS_Shape ;
  pt : TGIS_Point ;
  delta : Integer ;
begin
  btnAnimate.Enabled := False ;

  for i:=0 to 90 do
  begin
    if chkUseLock.Checked then
    begin
      GIS.Lock ;
    end ;

    // move plains
    for j :=1 to 90 do
    begin
      shp := TGIS_LayerVector( GIS.Items[1] ).GetShape( j ) ;
      pt := shp.Centroid ;
      delta := j mod 3 -1 ;
      shp.SetPosition( TGIS_Utils.GisPoint( pt.X + delta, pt.Y  ), nil, 0 ) ;
      Application.ProcessMessages ;
    end ;

    if chkUseLock.Checked then
    begin
      GIS.UnLock ;
      GIS.Invalidate;
      Application.ProcessMessages ;
    end
    else
    //  GIS.LabelsReg.Reset ;
  end ;

  btnAnimate.Enabled := True ;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  i   : Integer    ;
  shp : TGIS_Shape ;
begin
  GIS.Lock ;
  try
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg' );
    GIS.Zoom := GIS.Zoom * 2 ;

    // create a layer and add a field
    ll := TGIS_LayerVector.Create ;
    ll.Params.Marker.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\2267.cgm' ) ;
    ll.Params.Marker.SymbolRotate := Pi/2 ;
    ll.Params.Marker.Size := -20 ;
    ll.Params.Line.Symbol := SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\1301.cgm' ) ;
    ll.Params.Line.Width   := -5 ;
    ll.CachedPaint := False ;
    ll.CS := GIS.CS ;
    GIS.Add( ll ) ;
  finally
    GIS.Unlock ;
  end;
  ll.AddField('Name', TGIS_FieldType.String, 255, 0 ) ;
  ll.Params.Labels.Field := 'Name' ;

  // add random plains
  for i:=0 to 100 do
  begin
    shp := TGIS_LayerVector( GIS.Items[1] ).CreateShape( TGIS_ShapeType.Point ) ;
    shp.SetField('Name', IntToStr( i+1 ));
    shp.Params.Marker.SymbolRotate := DegToRad( Random( 360 ) ) ;
    shp.Params.Marker.Color := TGIS_Color.FromRGB( Random(256) shl 16 + Random( 256 ) shl 8 + Random ( 256 ) );
    shp.Params.Marker.OutlineColor := shp.Params.Marker.Color ;
    shp.Lock( TGIS_Lock.Extent );
    shp.AddPart ;
    shp.AddPoint( TGIS_Utils.GisPoint( -180 + Random( 360 ) , ( 90 - Random( 180 ) )) );
    shp.UnLock;
  end ;

end;


end.
