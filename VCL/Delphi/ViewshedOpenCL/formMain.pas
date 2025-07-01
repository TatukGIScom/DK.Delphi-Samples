//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to implement a real-time viewshed running on OpenCL.
  Main form.
}
unit formMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  System.TimeSpan,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  //GisLicense,
  GisRtl,
  GisTypes,
  GisTypesUI,
  GisFunctions,
  GisParams,
  GisLayerVector,
  GisLayerPixel,
  GisOpenCL,
  GisViewshed,
  GisLayerADF,
  VCL.GisViewerWnd,

  formInfo ;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    lblInfo: TLabel;
    btnOpenCLInfo: TButton;
    btnDeviceInfo: TButton;
    chkbxUseOpenCL: TCheckBox;
    lblTime: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chkbxUseOpenCLClick(Sender: TObject);
    procedure btnOpenCLInfoClick(Sender: TObject);
    procedure btnDeviceInfoClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    cl_viewshed : TGIS_Viewshed ;
    cl_dem : TGIS_LayerPixel ;
    cl_observers : TGIS_LayerVector ;
    cl_output : TGIS_LayerPixel ;
    cl_time : TDateTime ;
    cl_span : TTimeSpan ;
    cl_proc : Boolean ;
  private
    procedure clearOutput ;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if not GisOpenCLEngine.Available then begin
    ShowMessage( 'OpenCL is not available. Falling back to CPU...' ) ;
    chkbxUseOpenCL.Checked := False ;
    chkbxUseOpenCL.Enabled := False ;
    btnOpenCLInfo.Enabled := False ;
    btnDeviceInfo.Enabled := False ;
  end
  else
    GisOpenCLEngine.Enabled := True ;

  GIS.Open( GisSamplesDataDirDownload +
    '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf');

  cl_proc := False ;
end;


procedure TfrmMain.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt  : TPoint ;
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  if GIS.Mode <> TGIS_ViewerMode.UserDefined then
    exit ;

  pt := Point( X, Y ) ;
  ptg := GIS.ScreenToMap( pt ) ;

  cl_dem := TGIS_LayerPixel( GIS.Items.Items[0] ) ;

  if not GisIsPointInsideExtent( ptg, cl_dem.Extent ) then
      exit ;

  cl_observers := TGIS_LayerVector.Create ;
  cl_observers.Name := 'observers' ;
  cl_observers.CS := cl_dem.CS ;
  cl_observers.Open ;
  shp := cl_observers.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( ptg ) ;

  cl_output := TGIS_LayerPixel.Create ;
  cl_output.Name := 'viewshed' ;
  cl_output.Build( True, cl_dem.CS, cl_dem.Extent,
    cl_dem.BitWidth, cl_dem.BitHeight ) ;
  cl_output.Params.Pixel.GridShadow := False ;
  cl_output.Params.Pixel.AltitudeMapZones.Add(
    ConstructParamAltitudeMapZone(0, 0, TGIS_Color.FromARGB( 255, 0, 0, 0 ), '0' )
  ) ;
  cl_output.Params.Pixel.AltitudeMapZones.Add(
    ConstructParamAltitudeMapZone(1, 1, TGIS_Color.FromARGB( 0, 0, 255, 0 ), '1' )
  ) ;

  cl_viewshed := TGIS_Viewshed.Create ;
  cl_viewshed.Radius := 20000 ; // 20km radius
  cl_viewshed.CurvedEarth := True ;
  cl_viewshed.ObserverElevation := TGIS_ViewshedObserverElevation.OnDem ;
  cl_viewshed.ViewshedOutput := TGIS_ViewshedOutput.Visibility ;
  cl_viewshed.FillWithZeros := True ;

  cl_viewshed.TerrainLayer := cl_dem ;
  cl_viewshed.ObserversLayer := cl_observers ;
  cl_viewshed.OutputLayer := cl_output ;
  cl_viewshed.TerrainOffset := 0.0 ;
  cl_viewshed.ObserversOffsetField := '' ;
  cl_viewshed.ObserversOffset := 30.0 ; // 30m above ground

  cl_viewshed.Generate ;

  cl_output.Transparency := 80 ;
  cl_output.CachedPaint := False ;
  cl_observers.CachedPaint := False ;
  GIS.Add( cl_output ) ;
  GIS.Add( cl_observers ) ;

  GIS.InvalidateTopmost ;

  cl_time := Now ;

  cl_proc := True ;
end ;


procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  pt  : TPoint ;
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
  dt  : TDateTime ;
  ts  : TTimeSpan ;
begin
  if not ( ssLeft in Shift ) then
    exit ;

  if GIS.Mode <> TGIS_ViewerMode.UserDefined then
    exit ;

  if not cl_proc then
    exit ;

  if not Assigned( cl_output ) then
    exit ;

  cl_span := TTimeSpan.Subtract( Now, cl_time ) ;
  // limit the number of frames to 25 fps
  if cl_span.TotalMilliseconds < 40 then
    exit ;

  pt := Point( X, Y ) ;
  ptg := GIS.ScreenToMap( pt ) ;
  if not GisIsPointInsideExtent( ptg, cl_dem.Extent ) then
    exit ;
  cl_observers.RevertAll ;
  shp := cl_observers.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( ptg ) ;

  if not GisOpenCLEngine.Enabled then
    clearOutput ;

  dt := Now ;
  cl_viewshed.Generate ;
  ts := TTimeSpan.Subtract( Now, dt ) ;
  lblTime.Caption :=
    'Generation time: ' + FloatToStr( ts.TotalMilliseconds ) + ' ms' ;

  GIS.InvalidateTopmost ;

  cl_time := Now ;
end ;


procedure TfrmMain.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt  : TPoint ;
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  if GIS.Mode <> TGIS_ViewerMode.UserDefined then
    exit ;

  if not cl_proc then
    exit ;

  FreeObject( cl_viewshed ) ;
  GIS.Delete( cl_observers.Name ) ;
  GIS.Delete( cl_output.Name ) ;
  GIS.InvalidateWholeMap ;

  lblTime.Caption := '' ;

  cl_proc := False ;
end ;


procedure TfrmMain.clearOutput ;
var
  lpl : TGIS_LayerPixelLock ;
  h   : Integer ;
  w   : Integer ;
begin
  lpl := cl_output.LockPixels( cl_output.Extent, cl_output.CS, True ) ;
  try
    for h := lpl.Bounds.Top to lpl.Bounds.Bottom do begin
      for w := lpl.Bounds.Left to lpl.Bounds.Right do begin
        lpl.Grid[h,w] := 0.0 ;
      end ;
    end ;
  finally
    cl_output.UnlockPixels( lpl ) ;
  end ;
end ;


procedure TfrmMain.chkbxUseOpenCLClick(Sender: TObject);
begin
  GisOpenCLEngine.Enabled := chkbxUseOpenCL.Checked ;
end ;


procedure TfrmMain.btnOpenCLInfoClick(Sender: TObject);
var
  pi  : TGIS_OpenCLPlatformInfo ;
  di  : TGIS_OpenCLDeviceInfo ;
  sl  : TStringList ;
  inf : String ;
  frm : TfrmInfo ;
  i   : Integer ;
  k   : Integer ;
  l   : Integer ;
begin
  sl := TStringList.Create ;
  try

    for i := 0 to GisOpenCLEngine.PlatformCount - 1 do begin
      pi := GisOpenCLEngine.Platforms[i] ;
      sl.Append( 'Platform ' + IntToStr( i ) + ':' ) ;
      sl.Append( '    Name: ' + pi.Name ) ;
      sl.Append( '    Vendor: ' + pi.Vendor ) ;
      sl.Append( '    Version: ' + pi.Version ) ;
      sl.Append( '    Profile: ' + pi.Profile ) ;
      sl.Append( '    Number of devices: ' + IntToStr( pi.DeviceCount ) ) ;
      for k := 0 to pi.DeviceCount - 1 do begin
        di := pi.Devices[k] ;
        sl.Append( '    Device ' + IntToStr( k ) + ':' ) ;
        if di.Available then
          sl.Append( '        Available: True' )
        else
          sl.Append( '        Available: False' ) ;
        if di.DeviceType = TGIS_OpenCLDeviceType.CPU then
          sl.Append( '        Type: CPU' )
        else
        if di.DeviceType = TGIS_OpenCLDeviceType.GPU then
          sl.Append( '        Type: GPU' )
        else
          sl.Append( '        Type: accelerator' ) ;
        sl.Append( '        Name: ' + di.Name ) ;
        sl.Append( '        Vendor: ' + di.Vendor ) ;
        sl.Append( '        Version: ' + di.Version ) ;
        sl.Append( '        Profile: ' + di.Profile ) ;
        sl.Append( '        OpenCL C version: ' + di.OpenCLCVersion ) ;
        sl.Append( '        Driver version: ' + di.DriverVersion ) ;
        sl.Append( '        Maximum work group size: ' + IntToStr( di.WorkGroupSize ) ) ;
        sl.Append( '        Clock frequency: ' + IntToStr( di.ClockFrequency ) + ' MHz'  ) ;
        sl.Append( '        Maximum memory allocation size: ' + IntToStr( di.MemoryAllocationSize ) + ' bytes' ) ;
        sl.Append( '        Number of compute units: ' + IntToStr( di.ComputeUnits ) ) ;
        sl.Append( '        Extensions:' ) ;
        for l := 0 to di.ExtensionCount - 1 do
          sl.Append( '            ' + di.Extensions[l] ) ;
      end ;
    end ;

    inf := sl.Text ;

  finally
    FreeObject( sl ) ;
  end ;

  frm := TfrmInfo.Create( Self ) ;
  try
    frm.Execute( 'OpenCL info', inf ) ;
  finally
    FreeObject( frm ) ;
  end ;
end ;


procedure TfrmMain.btnDeviceInfoClick(Sender: TObject);
var
  di  : TGIS_OpenCLDeviceInfo ;
  sl  : TStringList ;
  inf : String ;
  frm : TfrmInfo ;
  l   : Integer ;
begin
  di := GisOpenCLEngine.ActiveDevice ;
  sl := TStringList.Create ;
  try

    if di.DeviceType = TGIS_OpenCLDeviceType.CPU then
      sl.Append( 'Type: CPU' )
    else
    if di.DeviceType = TGIS_OpenCLDeviceType.GPU then
      sl.Append( 'Type: GPU' )
    else
      sl.Append( 'Type: accelerator' ) ;
    sl.Append( 'Name: ' + di.Name ) ;
    sl.Append( 'Vendor: ' + di.Vendor ) ;
    sl.Append( 'Version: ' + di.Version ) ;
    sl.Append( 'Profile: ' + di.Profile ) ;
    sl.Append( 'OpenCL C version: ' + di.OpenCLCVersion ) ;
    sl.Append( 'Driver version: ' + di.DriverVersion ) ;
    sl.Append( 'Maximum work group size: ' + IntToStr( di.WorkGroupSize ) ) ;
    sl.Append( 'Clock frequency: ' + IntToStr( di.ClockFrequency ) + ' MHz' ) ;
    sl.Append( 'Maximum memory allocation size: ' + IntToStr( di.MemoryAllocationSize ) + ' bytes' ) ;
    sl.Append( 'Number of compute units: ' + IntToStr( di.ComputeUnits ) ) ;
    sl.Append( 'Extensions:' ) ;
    for l := 0 to di.ExtensionCount - 1 do
      sl.Append( '    ' + di.Extensions[l] ) ;

    inf := sl.Text ;

  finally
    FreeObject( sl ) ;
  end ;

  frm := TfrmInfo.Create( Self ) ;
  try
    frm.Execute( 'Active device info', inf ) ;
  finally
    FreeObject( frm ) ;
  end ;
end ;


end.
