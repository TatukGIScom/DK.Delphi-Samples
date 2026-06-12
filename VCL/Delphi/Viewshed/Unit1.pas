{
  Viewshed sample — demonstrates line-of-sight terrain analysis using TGIS_Viewshed.
  Loads a DEM (Digital Elevation Model) for San Bernardino, CA.  The user clicks on the map
  to place observers; TGIS_Viewshed.Generate computes a viewshed raster (which cells are
  visible from all observer points) and an AGL (Above-Ground-Level) raster (minimum height
  needed for non-visible cells to become visible from at least one observer).
  Radio buttons switch between binary viewshed, frequency viewshed, and AGL display.
}

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Types, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,


  GisTypes,
  GisTypesUI,
  GisLayer,
  GisLayerVector,
  GisLayerPixel,
  GisRendererAbstract,
  VCL.GisRendererDirect2D,
  VCL.GisViewerWnd, Vcl.ComCtrls, VCL.GisControlLegend, GisOpenCL, Vcl.ExtCtrls ;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    gbMapMode: TGroupBox;
    rbtnZoom: TRadioButton;
    rbtnAddObserver: TRadioButton;
    btnFullExtent: TButton;
    btnReset: TButton;
    gbVisibleLayer: TGroupBox;
    rbtnViewshedBinary: TRadioButton;
    rbtnAGL: TRadioButton;
    lblObserverElevation: TLabel;
    edtObserverElevation: TEdit;
    rbtnViewshedFreq: TRadioButton;
    lblHint: TLabel;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rbtnZoomClick(Sender: TObject);
    procedure rbtnAddObserverClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure rbtnViewshedBinaryClick(Sender: TObject);
    procedure rbtnAGLClick(Sender: TObject);
    procedure rbtnViewshedFreqClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer2Timer(Sender: TObject);
    procedure GISAfterPaintRendererEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure GISBeforePaintRendererEvent(_sender: TObject;
      _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
    procedure Button1Click(Sender: TObject);
  private
    procedure setLayerActive ;
    procedure makeViewshedRamp ;
    procedure showComment ;
  private
    lTerrain   : TGIS_LayerPixel ;
    lObservers : TGIS_LayerVector ;
    lViewshed  : TGIS_LayerPixel ;
    lAGL       : TGIS_LayerPixel ;
  end ;

var
  frmMain : TfrmMain ;

implementation

{$R *.dfm}

uses
  GisRtl,
  GisUtils,
  GisFunctions,
  GisAllLayers,
  GisParams,
  GisSymbol,
  GisViewshed ;

const
  SAMPLE_VIEWSHED_NAME : String = 'Viewshed' ;
  SAMPLE_AGL_NAME      : String = 'Above-Ground-Level' ;

{ Toggles active state between the viewshed and AGL layers based on the selected
  radio button, refreshes the color ramp, and updates the hint label. }
procedure TfrmMain.setLayerActive ;
begin
  GIS.Lock ;
  makeViewshedRamp ;
  if Assigned( GIS.Get( SAMPLE_VIEWSHED_NAME ) ) then begin
    lViewshed.Active := not rbtnAGL.Checked ;
    lAGL.Active := rbtnAGL.Checked  ;
    GIS.InvalidateWholeMap ;
  end ;
  GIS.Unlock ;

  showComment ;
end ;

{ Applies a binary (green = visible) or frequency (red-to-green gradient) color
  ramp to the viewshed layer based on the selected radio button. }
procedure TfrmMain.makeViewshedRamp ;
begin
  if not Assigned( GIS.Get( SAMPLE_VIEWSHED_NAME ) ) then
    exit ;

  lViewshed.Transparency := 60 ;
  lViewshed.Params.Pixel.GridShadow := False ;
  lViewshed.Params.Pixel.AltitudeMapZones.Clear ;

  // create color ramp for binary viewshed
  if rbtnViewshedBinary.Checked then begin
    // make default value transparent
    lViewshed.GenerateRamp(
      TGIS_Color.FromARGB( 127, 0, 255, 0),
      TGIS_Color.None,
      TGIS_Color.FromARGB( 127, 0, 255, 0),
      lViewshed.MinHeight, 0.01,
      lViewshed.MaxHeight, False,
      ( lViewshed.MaxHeight - lViewshed.MinHeight )/100,
      ( lViewshed.MaxHeight - lViewshed.MinHeight )/10,
      nil, False
    ) ;
  end
  else
  // create color ramp for frequency viewshed
  if rbtnViewshedFreq.Checked then begin
    lViewshed.GenerateRamp(
      TGIS_Color.FromARGB( 127, 255, 0, 0),
      TGIS_Color.None,
      TGIS_Color.FromARGB( 127, 0, 255, 0),
      0, 0,
      lViewshed.MaxHeight, False,
      ( lViewshed.MaxHeight - lViewshed.MinHeight )/100,
      ( lViewshed.MaxHeight - lViewshed.MinHeight )/10,
      nil, False
    ) ;
  end ;
end ;

{ Updates the hint label with a description of the currently active layer's
  color scheme. }
procedure TfrmMain.showComment;
begin
  if rbtnViewshedBinary.Checked then
  begin
    lblHint.Caption := 'Green - area of visibility.' ;
  end
  else
  if rbtnViewshedFreq.Checked then
  begin
    lblHint.Caption := 'Visibility frequency; ' +
                       'Red - one  observer is visible; ' +
                       'Green - all observers are visible.' ;
  end
  else
  if rbtnAGL.Checked and Assigned( lAGL ) then
  begin
    lblHint.Caption := 'Minimum height that must be added to a nonvisible cell ' +
                       'to make it visible by at least one observer; '+
                       'Red = ' + IntToStr( Round( lAGL.MaxHeight ) ) + ' m' ;
  end


end;

procedure TfrmMain.Timer2Timer(Sender: TObject);
begin
  GIS.InvalidateTopmost ;
end;

{ Opens the DEM raster for San Bernardino, CA; creates an Observers vector layer
  with a tower symbol; and zooms to the full extent. }
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
    'World\Countries\USA\States\California\San Bernardino\NED\w001001.adf'
  ) ;
  // obtain the DEM layer
  lTerrain := TGIS_LayerPixel( GIS.Get( 'w001001' ) ) ;
  lTerrain.Params.Pixel.AltitudeMapZones.Clear ;

  // create a layer for storing the observer locations
  lObservers := TGIS_LayerVector.Create ;
  lObservers.Name := 'Observers' ;
  lObservers.CS := lTerrain.CS ;
  lObservers.Open ;

  // add a symbol to represent observers
  lObservers.Params.Marker.Symbol :=
    SymbolList.Prepare( 'LIBSVG:std:TowerCommunication01' ) ;
  lObservers.Params.Marker.Color := TGIS_Color.White ;
  lObservers.Params.Marker.OutlineColor := TGIS_Color.White ;
  lObservers.Params.Marker.Size := -32 ;
  lObservers.CachedPaint := False ;
  GIS.Add( lObservers ) ;
  GIS.Unlock;
  GIS.FullExtent ;
end ;

var
  tm : Cardinal ;

procedure TfrmMain.GISAfterPaintRendererEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
begin
  Button1.Caption := (GetTickCount - tm ).ToString;
end;

procedure TfrmMain.GISBeforePaintRendererEvent(_sender: TObject;
  _renderer: TGIS_RendererAbstract; _mode: TGIS_DrawMode);
begin
  tm := GetTickCount ;
end;

{ In UserDefined mode, adds the clicked point as an observer, runs
  TGIS_Viewshed.Generate to compute viewshed and AGL rasters, and refreshes the
  display with the appropriate color ramp. }
procedure TfrmMain.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt   : TGIS_Point ;
  shp  : TGIS_Shape ;
  vs   : TGIS_Viewshed ;
  elev : Single ;
begin
  // read observer elevation offset
  if GIS.Mode = TGIS_ViewerMode.UserDefined then begin
    try
      elev := DotStrToFloat( edtObserverElevation.Text ) ;
    except
      ShowMessage( '''' + edtObserverElevation.Text +
                   ''' is not a valid floating point value.'
      ) ;
      exit ;
    end ;

    GIS.Lock ;
    try
      // check if the point lays within the DEM area
      pt := GIS.ScreenToMap( Point( X, Y ) ) ;
      if not GisIsPointInsideExtent( pt, lTerrain.Extent ) then
        exit ;

      // add observer to the observer layer
      shp := lObservers.CreateShape(
        TGIS_ShapeType.Point, TGIS_DimensionType.XY
      ) ;
      shp.AddPart ;
      shp.AddPoint( pt ) ;

      // remove previous viewshed/AGL layers
      if Assigned( GIS.Get( SAMPLE_VIEWSHED_NAME ) ) then begin
        GIS.Delete( lAGL.Name ) ;
        lAGL := nil ;
        GIS.Delete( lViewshed.Name ) ;
        lViewshed := nil ;
      end ;

      // create and set up the layer to host viewshed
      lViewshed := TGIS_LayerPixel.Create ;
      lViewshed.Build( True, lTerrain.CS, lTerrain.Extent,
                       lTerrain.BitWidth, lTerrain.BitHeight ) ;
      lViewshed.Name := SAMPLE_VIEWSHED_NAME ;
      lViewshed.Open ;

      // create and set up the layer to host above-ground-level
      lAGL := TGIS_LayerPixel.Create ;
      lAGL.Build( True, lTerrain.CS, lTerrain.Extent,
                 lTerrain.BitWidth, lTerrain.BitHeight ) ;
      lAGL.Name := SAMPLE_AGL_NAME ;
      lAGL.Open ;

      // create viewshed tool
      vs := TGIS_Viewshed.Create ;
      try
        // set the base observer elevation to be read from the DEM layer
        vs.ObserverElevation := TGIS_ViewshedObserverElevation.OnDem ;
        // turn on the correction for earth curvature and refractivity
        vs.CurvedEarth := True ;

        // initiate the viewshed/AGL generation process
        vs.Generate(
          lTerrain, lObservers, lViewshed, lAGL, 0.0, '', elev
        ) ;
      finally
        FreeObject( vs ) ;
      end ;

      lViewshed.Active := not rbtnAGL.Checked ;
      lAGL.Active := rbtnAGL.Checked ;

      lAGL.CachedPaint := False ;
      lViewShed.CachedPaint := False ;
      GIS.Add( lAGL ) ;
      GIS.Add( lViewshed ) ;
      lAGL.Transparency := 50 ;
      lViewShed.Transparency := 50 ;
      lObservers.Move( -2 ) ;

      // apply (binary or frequency) color ramp to the viewshed layer
      makeViewshedRamp ;

      // apply color ramp to the AGL layer
      lAGL.Params.Pixel.GridShadow := False ;
      lAGL.GenerateRamp(
        TGIS_Color.FromARGB( 127, 0, 255, 0),
        TGIS_Color.None,
        TGIS_Color.FromARGB( 127, 255, 0, 0),
        0, 1,
        lAGL.MaxHeight, False,
        ( lAGL.MaxHeight - lAGL.MinHeight )/100,
        ( lAGL.MaxHeight - lAGL.MinHeight )/10,
        nil, False
      ) ;

      GIS.InvalidateWholeMap ;

    finally
      GIS.Unlock ;
    end ;
  end ;

  showComment ;
end ;

{ Reads viewshed frequency and AGL values at the cursor position and displays
  them in the status bar. }
procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
  cl : TGIS_Color ;
  vals : TGIS_DoubleArray ;
  transp : Boolean ;
  str : String ;
begin
  ptg := GIS.ScreenToMap( Point( x, y ) ) ;

  str := '' ;

  if Assigned( lViewshed ) and lViewshed.Locate( ptg, cl, vals, transp ) then begin
    if vals[0] <> lViewshed.NoDataValue then
      str := str + 'Frequency: ' + FloatToStr( vals[0] ) ;
  end;
  if Assigned( lAGL ) and lAGL.Locate( ptg, cl, vals, transp ) then begin
    if vals[0] <> lAGL.NoDataValue then
      str := str + 'Above-Ground-Level: ' + FloatToStr( Round( vals[0] ) ) ;
  end;

  StatusBar1.SimpleText := str ;

end;

{ Zooms the viewer to the full extent of all layers. }
procedure TfrmMain.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end ;

{ Removes the viewshed and AGL layers and reverts all observer points to reset
  the display. }
procedure TfrmMain.btnResetClick(Sender: TObject);
begin
  GIS.Lock ;
  if Assigned( GIS.Get( SAMPLE_VIEWSHED_NAME ) ) then begin
    GIS.Delete( lAGL.Name ) ;
    lAGL := nil ;
    GIS.Delete( lViewshed.Name ) ;
    lViewshed := nil ;
  end ;
  lObservers.RevertAll ;
  GIS.FullExtent ;
  GIS.Unlock ;
end ;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  Timer1.Enabled := True ;
end;

{ Switches the viewer to UserDefined mode for adding observer points. }
procedure TfrmMain.rbtnAddObserverClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.UserDefined ;
end ;

{ Switches the viewer to Zoom mode. }
procedure TfrmMain.rbtnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end ;

{ Refreshes the visible layer when the binary viewshed radio button changes. }
procedure TfrmMain.rbtnViewshedBinaryClick(Sender: TObject);
begin
  setLayerActive ;
end ;

{ Refreshes the visible layer when the frequency viewshed radio button changes. }
procedure TfrmMain.rbtnViewshedFreqClick(Sender: TObject);
begin
  setLayerActive ;
end ;

{ Refreshes the visible layer when the AGL radio button changes. }
procedure TfrmMain.rbtnAGLClick(Sender: TObject);
begin
  setLayerActive ;
end ;

end.
