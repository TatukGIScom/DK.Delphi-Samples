//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to utilize TatukGIS online services (tiles, geocoding, routing and
  isochrone).
}

unit formMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.UITypes, System.Generics.Collections,
  System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,

  GisTypes,
  GisFunctions,
  GisLayerVector,
  GisLayerWebTiles,
  GisOSMServices,
  VCL.GisViewerWnd,
  VCL.GisControlScale;

type

  T_mapStyle = (
    International,
    English,
    InternationalHillshade,
    EnglishHillshade
  ) ;


  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_Scale: TGIS_ControlScale;
    grpbxGeocoding: TGroupBox;
    edtGeocodingAddress: TEdit;
    btnGeocoding: TButton;
    grpbxRouting: TGroupBox;
    btnRouting: TButton;
    strgrdRouting: TStringGrid;
    btnRoutingAdd: TButton;
    btnRoutingDelete: TButton;
    lblRoutingProfile: TLabel;
    grpbxMap: TGroupBox;
    cmbbxMap: TComboBox;
    grpbxRoutingDir: TGroupBox;
    lblRoutingDirDist: TLabel;
    lblRoutingDirTime: TLabel;
    lblGeocodingLimit: TLabel;
    cmbbxGeocodingLimit: TComboBox;
    strgrdRoutingDir: TStringGrid;
    lblRoutingDirInfo: TLabel;
    grpbxIsochrone: TGroupBox;
    rbtnRoutingProfileCar: TRadioButton;
    rbtnRoutingProfileBike: TRadioButton;
    rbtnRoutingProfileFoot: TRadioButton;
    btnIsochrone: TButton;
    lblIsochroneTime: TLabel;
    edtIsochroneTime: TEdit;
    lblIsochroneBuckets: TLabel;
    cmbbxIsochroneBuckets: TComboBox;
    lblGeocodingAddress: TLabel;
    lblIsochroneAddress: TLabel;
    edtIsochroneAddress: TEdit;
    lblIsochroneProfile: TLabel;
    rbtnIsochroneProfileCar: TRadioButton;
    rbtnIsochroneProfileBike: TRadioButton;
    rbtnIsochroneProfileFoot: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure btnRoutingAddClick(Sender: TObject);
    procedure btnRoutingDeleteClick(Sender: TObject);
    procedure btnGeocodingClick(Sender: TObject);
    procedure btnRoutingClick(Sender: TObject);
    procedure cmbbxMapChange(Sender: TObject);
    procedure strgrdRoutingDirDblClick(Sender: TObject);
    procedure btnIsochroneClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    shpList : TList<Int64> ;
  private
    procedure loadTiles ( const _style : T_mapStyle
                        ) ;
    procedure resetLayers ;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.Math,
  GisRtl,
  GisUtils ;


function growExtent(
  const _ext : TGIS_Extent ;
  const _fac : Double
) : TGIS_Extent ;
var
  ctr  : TGIS_Point ;
  xsiz : Double ;
  ysiz : Double ;
begin
  ctr := GisPoint( 0.5*( _ext.XMin + _ext.XMax ),
                   0.5*( _ext.YMin + _ext.YMax ) ) ;
  xsiz := 0.5*_fac*( _ext.XMax - _ext.XMin ) ;
  ysiz := 0.5*_fac*( _ext.YMax - _ext.YMin ) ;

  Result := GisExtent( ctr.X - xsiz, ctr.Y - ysiz,
                       ctr.X + xsiz, ctr.Y + ysiz ) ;
end ;


function resizeExtent(
  const _ext : TGIS_Extent ;
  const _siz : Double
) : TGIS_Extent ;
var
  ctr  : TGIS_Point ;
  xsiz : Double ;
  ysiz : Double ;
begin
  xsiz := _ext.XMax - _ext.XMin ;
  ysiz := _ext.YMax - _ext.YMin ;

  if ( xsiz > _siz ) or ( ysiz > _siz ) then begin
    Result := _ext ;
    exit ;
  end ;

  ctr := GisPoint( 0.5*( _ext.XMin + _ext.XMax ),
                   0.5*( _ext.YMin + _ext.YMax ) ) ;

  Result := GisExtent( ctr.X - 0.5*_siz, ctr.Y - 0.5*_siz,
                       ctr.X + 0.5*_siz, ctr.Y + 0.5*_siz ) ;
end ;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.Title := 'Online Services' ;

  strgrdRouting.ColWidths[0] := 64 ;
  strgrdRouting.ColWidths[1] :=
    strgrdRouting.Width - strgrdRouting.ColWidths[0] - 4 ;

  strgrdRouting.Cells[0,0] := 'From' ;
  strgrdRouting.Cells[0,1] := 'Through' ;
  strgrdRouting.Cells[0,2] := 'To' ;

  strgrdRouting.Cells[1,0] := 'Gdynia' ;
  strgrdRouting.Cells[1,1] := 'Czestochowa' ;
  strgrdRouting.Cells[1,2] := 'Wroclaw' ;

  loadTiles( T_mapStyle.English ) ;

  shpList := TList<Int64>.Create ;
end ;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeObject( shpList ) ;
end ;


procedure TfrmMain.loadTiles(
  const _style : T_mapStyle
) ;
const
  LOCAL_LAYER_TILES : String = 'tiles' ;
var
  lwt  : TGIS_LayerWebTiles ;
  path : String ;
  b    : Boolean ;
begin
  b := Assigned( GIS.Get( LOCAL_LAYER_TILES ) ) ;
  if b then
    GIS.Delete( LOCAL_LAYER_TILES ) ;

  lwt := TGIS_LayerWebTiles.Create ;
  path := TGIS_Utils.GisSamplesDataDirDownload() + '\Samples\WebServices\' ;
  case _style of
    T_mapStyle.International :
      path := path + 'TatukGIS OpenStreetMap Tiles.ttkwp' ;
    T_mapStyle.English :
      path := path + 'TatukGIS OpenStreetMap Tiles (English).ttkwp' ;
    T_mapStyle.InternationalHillshade :
      path := path + 'TatukGIS OpenStreetMap Hillshade Tiles.ttkwp' ;
    T_mapStyle.EnglishHillshade :
      path := path + 'TatukGIS OpenStreetMap Hillshade Tiles (English).ttkwp' ;
  end ;
  lwt.Path := path ;
  lwt.Open ;
  lwt.Name := LOCAL_LAYER_TILES ;

  GIS.Add( lwt ) ;
  lwt.Move( 999 ) ;
  if b then
    GIS.InvalidateWholeMap
  else
    GIS.VisibleExtent := lwt.Extent ;
end ;


procedure TfrmMain.resetLayers ;
begin
  if Assigned( GIS.Get( 'fgeocoding' ) ) then
    GIS.Delete( 'fgeocoding' ) ;

  if Assigned( GIS.Get( 'route' ) ) then
    GIS.Delete( 'route' ) ;

  if Assigned( GIS.Get( 'isochrone' ) ) then
    GIS.Delete( 'isochrone' ) ;
end ;


procedure TfrmMain.strgrdRoutingDirDblClick(Sender: TObject);
var
  lrtg : TGIS_LayerVector ;
  shp  : TGIS_Shape ;
begin
  lrtg := TGIS_LayerVector( GIS.Get( 'route' ) ) ;
  if not Assigned( lrtg ) then
    exit ;
  shp := lrtg.GetShape( shpList[strgrdRoutingDir.Row] ) ;
  GIS.VisibleExtent := resizeExtent( shp.ProjectedExtent, 500.0 ) ;
end;

procedure TfrmMain.btnGeocodingClick(Sender: TObject);
var
  ogeo : TGIS_OSMGeocoding ;
  lgeo : TGIS_LayerVector ;
  ext  : TGIS_Extent ;
begin
  resetLayers ;

  if Length( edtGeocodingAddress.Text ) = 0 then begin
    ShowMessage( 'Address not specified.' ) ;
    exit ;
  end ;

  ogeo := TGIS_OSMGeocoding.Create ;
  try
    ogeo.Limit := StrToInt( cmbbxGeocodingLimit.Text ) ;
    lgeo := ogeo.Forward( edtGeocodingAddress.Text ) ;
    if lgeo.GetLastUid > 0 then begin

      lblRoutingDirDist.Caption := 'Total distance: ?' ;
      lblRoutingDirTime.Caption := 'Total time: ?' ;
      strgrdRoutingDir.RowCount := 1 ;
      strgrdRoutingDir.Cells[0,0] := '' ;

      GIS.Add( lgeo ) ;

      ext := resizeExtent( lgeo.ProjectedExtent, 500.0 ) ;
      ext := growExtent( ext, 1.2 ) ;

      GIS.VisibleExtent := ext ;

    end
    else
      ShowMessage( 'Address not found.' ) ;
  finally
    ogeo.Free ;
  end ;
end ;


procedure TfrmMain.btnRoutingClick(Sender: TObject);
var
  lrtg  : TGIS_LayerVector ;
  ortg  : TGIS_OSMRouting ;
  names : TGIS_StringList ;
  ext   : TGIS_Extent ;
  shp   : TGIS_Shape ;
  uid   : Int64 ;
  dist  : Integer ;
  time  : Integer ;
  hrs   : Integer ;
  mns   : Integer ;
  dir   : String ;
  str   : String ;
  bfin  : Boolean ;
  b     : Boolean ;
  i     : Integer ;

  function sign2dir(
    const _sign : Integer
  ) : String ;
  begin
    case _sign of
      -99 : Result := '[unknown]' ;
      -98 : Result := 'Make a u-turn' ;
       -8 : Result := 'Make a left u-turn' ;
       -7 : Result := 'Keep left' ;
       -6 : Result := 'Exit roundabout' ;
       -3 : Result := 'Sharp turn left' ;
       -2 : Result := 'Turn left' ;
       -1 : Result := 'Slight turn left' ;
        0 : Result := 'Continue' ;
        1 : Result := 'Slight turn right' ;
        2 : Result := 'Turn right' ;
        3 : Result := 'Sharp turn right' ;
        4 : Result := 'Finish' ;
        5 : Result := 'Reach the intermediate destination' ;
        6 : Result := 'Enter roundabout and take the ' ;
        7 : Result := 'Keep right' ;
        8 : Result := 'Make a right u-turn' ;
      101 : Result := 'Start trip' ;
      102 : Result := 'Transfer' ;
      103 : Result := 'End trip' ;
      else  Result := 'Ignore' ;
    end ;
  end ;

  function exit_number( const _s : String ) : String ;
  begin
    case _s[StringLast( _s )] of
      '1' : Result := _s + 'st' ;
      '2' : Result := _s + 'nd' ;
      '3' : Result := _s + 'rd' ;
       else Result := _s + 'th' ;
    end ;
  end ;

  procedure add_dir( const _s : String ; const _u : Int64 ) ;
  begin
    if not IsStringEmpty( strgrdRoutingDir.Cells[0,0] ) then
      strgrdRoutingDir.RowCount := strgrdRoutingDir.RowCount + 1 ;
    strgrdRoutingDir.Cells[0,strgrdRoutingDir.RowCount - 1] := _s ;
    shpList.Add( _u ) ;
  end ;

begin
  resetLayers ;

  for i := 0 to strgrdRouting.RowCount - 1 do begin
    if Length( strgrdRouting.Cells[1,i] ) = 0 then begin
      ShowMessage( 'Address not specified.' ) ;
      exit ;
    end ;
  end ;

  names := TGIS_StringList.Create ;
  ortg := TGIS_OSMRouting.Create ;
  try

    if rbtnRoutingProfileCar.Checked then
      ortg.Profile := TGIS_OSMRoutingProfile.Car
    else
    if rbtnRoutingProfileBike.Checked then
      ortg.Profile := TGIS_OSMRoutingProfile.Bike
    else
    if rbtnRoutingProfileFoot.Checked then
      ortg.Profile := TGIS_OSMRoutingProfile.Foot ;

    for i := 0 to strgrdRouting.RowCount - 1 do
      names.Add( strgrdRouting.Cells[1,i] ) ;

    lrtg := ortg.Route( names ) ;

    if Assigned( lrtg ) then begin
      b := False ;
      dist := 0 ;
      time := 0 ;
      for shp in lrtg.Loop( lrtg.Extent, '( type = ''route'' )' ) do begin
        dist := dist + VarToInt32( shp.GetField( 'distance' ) ) ;
        time := time + VarToInt32( shp.GetField( 'time' ) ) ;
        b := True ;
      end ;

      GIS.Add( lrtg ) ;
      ext := resizeExtent( lrtg.ProjectedExtent, 500.0 ) ;
      GIS.VisibleExtent := growExtent( ext, 1.2 ) ;

      if b then begin

        if dist < 1000 then
          str := IntToStr( dist ) + ' m'
        else
          str := DotFloatToStrPrec( dist/1000.0, 2 ) + ' km' ;
        lblRoutingDirDist.Caption := 'Total distance: ' + str ;

        hrs := time div 3600 ;
        mns := ( time div 60 ) - hrs*60 ;
        if hrs = 0 then
          str := IntToStr( mns ) + ' min'
        else
          str := IntToStr( hrs ) + ' h ' + IntToStr( mns ) + ' min' ;
        lblRoutingDirTime.Caption := 'Total time: ' + str ;

        bfin := False ;
        strgrdRoutingDir.RowCount := 1 ;
        strgrdRoutingDir.Cells[0,0] := '' ;
        shpList.Clear ;
        for shp in lrtg.Loop( lrtg.Extent, '( type = ''route'' )' ) do begin
          uid := shp.Uid ;
          i := VarToInt32( shp.GetField( 'sign' ) ) ;
          str := VarToString( shp.GetField( 'name' ) ) ;

          case i of
            -98, -8, 8, 5 : dir := sign2dir( i ) ;
            6 : dir := sign2dir( i ) +
                       exit_number( VarToString( shp.GetField( 'exit' ) ) ) +
                       ' exit' ;
            else begin
              dir := sign2dir( i ) ;
              if not IsStringEmpty( str ) then begin
                if i = 0 then
                  dir := dir + ' on ' + str
                else
                  dir := dir + ' onto ' + str ;
              end ;
            end ;
          end ;

          if i = 5 then begin
            add_dir( dir, uid ) ;
            bfin := True ;
            continue ;
          end ;

          dist := VarToInt32( shp.GetField( 'distance' ) ) ;
          if dist < 1000 then
            dir := dir + ' (' + IntToStr( dist ) + ' m, '
          else
            dir := dir + ' (' + DotFloatToStrPrec( dist/1000.0, 2 ) + ' km, ' ;

          time := VarToInt32( shp.GetField( 'time' ) ) ;
          hrs := time div 3600 ;
          mns := ( time div 60 ) - hrs*60 ;
          if hrs = 0 then begin
            if mns = 0 then
              dir := dir + '<1 min)'
            else
              dir := dir + IntToStr( mns ) + ' min)' ;
          end
          else
            dir := dir + IntToStr( hrs ) + ' h ' + IntToStr( mns ) + ' min)' ;

          add_dir( dir, uid ) ;
        end ;

        if bfin then
          add_dir( 'Reach the final destination', uid )
        else
          add_dir( 'Reach the destination', uid ) ;

      end
      else
        ShowMessage( 'Route not found.' ) ;
    end ;

  finally
    ortg.Free ;
    names.Free ;
  end ;
end ;


procedure TfrmMain.btnRoutingAddClick(Sender: TObject);
begin
  strgrdRouting.RowCount := strgrdRouting.RowCount + 1 ;
  strgrdRouting.Cells[0,strgrdRouting.RowCount - 2] := 'Through' ;
  strgrdRouting.Cells[0,strgrdRouting.RowCount - 1] := 'To' ;
end ;


procedure TfrmMain.btnRoutingDeleteClick(Sender: TObject);
begin
  if strgrdRouting.RowCount = 2 then
    exit ;

  strgrdRouting.RowCount := strgrdRouting.RowCount - 1 ;
  strgrdRouting.Cells[0,strgrdRouting.RowCount - 1] := 'To' ;
end ;


procedure TfrmMain.cmbbxMapChange(Sender: TObject);
begin
  case cmbbxMap.ItemIndex of
    0 : loadTiles( T_mapStyle.International ) ;
    1 : loadTiles( T_mapStyle.English ) ;
    2 : loadTiles( T_mapStyle.InternationalHillshade ) ;
    3 : loadTiles( T_mapStyle.EnglishHillshade ) ;
  end ;
end ;


procedure TfrmMain.btnIsochroneClick(Sender: TObject);
var
  oiso : TGIS_OSMIsochrone ;
  liso : TGIS_LayerVector ;
  ext  : TGIS_Extent ;
  time : Integer ;
begin
  resetLayers ;

  if Length( edtIsochroneAddress.Text ) = 0 then begin
    ShowMessage( 'Address not specified.' ) ;
    exit ;
  end ;

  if not TryStrToInt( edtIsochroneTime.Text, time ) then begin
    ShowMessage( '''' + edtIsochroneTime.Text +
                 ''' is not a positive number.' ) ;
    exit ;
  end ;

  oiso := TGIS_OSMIsochrone.Create ;
  try

    if rbtnIsochroneProfileCar.Checked then
      oiso.Profile := TGIS_OSMRoutingProfile.Car
    else
    if rbtnIsochroneProfileBike.Checked then
      oiso.Profile := TGIS_OSMRoutingProfile.Bike
    else
    if rbtnIsochroneProfileFoot.Checked then
      oiso.Profile := TGIS_OSMRoutingProfile.Foot ;

    oiso.Buckets := StrToInt( cmbbxIsochroneBuckets.Text ) ;
    oiso.TimeLimit := time ;
    liso := oiso.Isochrone( edtIsochroneAddress.Text ) ;

    if liso.GetLastUid > 0 then begin

      lblRoutingDirDist.Caption := 'Total distance: ?' ;
      lblRoutingDirTime.Caption := 'Total time: ?' ;
      strgrdRoutingDir.RowCount := 1 ;
      strgrdRoutingDir.Cells[0,0] := '' ;

      GIS.Add( liso ) ;

      ext := resizeExtent( liso.ProjectedExtent, 500.0 ) ;
      ext := growExtent( ext, 1.2 ) ;

      GIS.VisibleExtent := ext ;

    end
    else
      ShowMessage( 'Address not found.' ) ;
  finally
    oiso.Free ;
  end ;
end ;


end.
