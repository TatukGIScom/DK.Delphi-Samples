unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

  GisLicense,

  Vcl.Forms,
  VCL.ComCtrls,
  VCL.GisViewerWnd,
  Vcl.StdCtrls,
  Vcl.Controls,
  VCL.GisControlAttributes,
  Vcl.ExtCtrls;

type
  TfrmGridToVector = class(TForm)
    pnl: TPanel;
    gbxData: TGroupBox;
    btnDem: TButton;
    btnLandCover: TButton;
    gbxGridToPolygon: TGroupBox;
    chkSplit: TCheckBox;
    btnGridToPolygon: TButton;
    gbxSelected: TGroupBox;
    GIS_ControlAttributes: TGIS_ControlAttributes;
    Panel1: TPanel;
    GIS: TGIS_ViewerWnd;
    progress: TProgressBar;
    gbxGridToPoint: TGroupBox;
    btnGridToPoints: TButton;
    gbsCommonParameters: TGroupBox;
    chkIgnoreNoData: TCheckBox;
    lblTolerance: TLabel;
    edtTolerance: TEdit;
    lblPointSpacing: TLabel;
    edtPointSpacing: TEdit;
    procedure FormShow(Sender: TObject);
    procedure GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure btnGridToPolygonClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnLandCoverClick(Sender: TObject);
    procedure btnDemClick(Sender: TObject);
    procedure btnGridToPointsClick(Sender: TObject);
  private
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
  end;

var
  frmGridToVector: TfrmGridToVector;

implementation

{$R *.dfm}

uses
  GisLayerPixel,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisVectorization,
  GisUtils,
  GisFunctions,
  GisRtl;

const
  LV_NAME = 'vector' ;
  LV_FIELD = 'value' ;

procedure TfrmGridToVector.doBusyEvent(
      _sender: TObject ;
      _pos   : Integer ;
      _end   : Integer ;
  var _abort : Boolean
) ;
begin
  case _pos of
    // initialize progress bar
    0  : begin
      progress.Min := 0 ;
      progress.Max := _end ;
      progress.Position := 0 ;
    end ;
    // end of progress - reset progress bar
    -1 : progress.Position := 0 ;
  else
    progress.Position := _pos ;
  end ;

  Application.ProcessMessages ;
end;

procedure TfrmGridToVector.btnLandCoverClick(Sender: TObject);
var
  path : String ;
begin
  path := TGIS_Utils.GisSamplesDataDirDownload +
    'World\Countries\Luxembourg\CLC2018_CLC2018_V2018_20_Luxembourg.tif' ;
  GIS.Open( path ) ;
  edtTolerance.Text := '1' ;
  edtPointSpacing.Text := '1000' ;

end;

procedure TfrmGridToVector.btnDemClick(Sender: TObject);
var
  path : String ;
  lp   : TGIS_LayerPixel ;
begin
  path := TGIS_Utils.GisSamplesDataDirDownload +
    'Samples\3D\elevation.grd' ;
  GIS.Open( path ) ;
  lp := TGIS_LayerPixel( GIS.Get( 'elevation') ) ;
  lp.GenerateRamp(
    TGIS_Color.Blue,
    TGIS_Color.Lime,
    TGIS_Color.Red,
    lp.MinHeight,
    ( lp.MinHeight + lp.MaxHeight ) / 2,
    lp.MaxHeight,
    True,
    ( lp.MaxHeight - lp.MinHeight ) / 100,
    ( lp.MaxHeight - lp.MinHeight ) / 10,
    nil,
    True,
    TGIS_ColorInterpolationMode.HSL
  ) ;
  lp.Params.Pixel.GridSmoothColors := True ;

  GIS.InvalidateWholeMap ;

  edtTolerance.Text := '10' ;
  edtPointSpacing.Text := '200' ;
end;

procedure TfrmGridToVector.btnGridToPointsClick(Sender: TObject);
var
  lp : TGIS_LayerPixel ;
  lv : TGIS_LayerVector ;
  grid_to_point : TGIS_GridToPoint ;
begin
  lp := TGIS_LayerPixel( GIS.Items[0] ) ;

  if GIS.Get( LV_NAME ) <> nil then
    GIS.Delete( LV_NAME ) ;

  lv := TGIS_LayerVector.Create ;
  lv.Name := LV_NAME ;
  lv.Open ;
  lv.CS := lp.CS ;
  lv.DefaultShapeType := TGIS_ShapeType.Point ;
  lv.AddField( LV_FIELD, TGIS_FieldType.Float, 0, 0 ) ;
  lv.Params.Marker.Color := TGIS_Color.Black ;
  lv.Params.Marker.Style := TGIS_MarkerStyle.Circle ;
  lv.Params.Marker.SizeAsText := 'SIZE:4pt' ;
  lv.Transparency := 75 ;

  grid_to_point := TGIS_GridToPoint.Create ;
  try
    // common parameters
    grid_to_point.BusyEvent := doBusyEvent ;
    grid_to_point.IgnoreNoData := chkIgnoreNoData.Checked ;
    grid_to_point.Tolerance := StrToFloat( edtTolerance.Text ) ;
    grid_to_point.PointSpacing := StrToFloat( edtPointSpacing.Text ) ;

    grid_to_point.Generate( lp, lv, LV_FIELD ) ;
  finally
    FreeObject( grid_to_point ) ;
  end ;

  GIS.Add( lv ) ;
  GIS.InvalidateWholeMap ;
end;

procedure TfrmGridToVector.btnGridToPolygonClick(Sender: TObject);
var
  lp : TGIS_LayerPixel ;
  lv : TGIS_LayerVector ;
  polygonizer : TGIS_GridToPolygon ;
begin
  lp := TGIS_LayerPixel( GIS.Items[0] ) ;

  if GIS.Get( LV_NAME ) <> nil then
    GIS.Delete( LV_NAME ) ;

  lv := TGIS_LayerVector.Create ;
  lv.Name := LV_NAME ;
  lv.Open ;
  lv.CS := lp.CS ;
  lv.DefaultShapeType := TGIS_ShapeType.Polygon ;
  lv.AddField( LV_FIELD, TGIS_FieldType.Float, 0, 0 ) ;
  lv.Transparency := 50 ;
  lv.Params.Area.OutlineColor := TGIS_Color.Black;

  polygonizer := TGIS_GridToPolygon.Create ;
  try
    // common parameters
    polygonizer.BusyEvent := doBusyEvent ;
    polygonizer.IgnoreNoData := chkIgnoreNoData.Checked ;
    polygonizer.Tolerance := StrToFloat( edtTolerance.Text ) ;

    // GridToPolygon parameter
    polygonizer.SplitShapes := chkSplit.Checked ;

    polygonizer.Generate( lp, lv, LV_FIELD ) ;
  finally
    FreeObject( polygonizer ) ;
  end ;

  GIS.Add( lv ) ;
  GIS.InvalidateWholeMap ;
end;

procedure TfrmGridToVector.FormShow(Sender: TObject);
begin
  btnLandCoverClick( Sender ) ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TfrmGridToVector.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp : TGIS_Shape ;
begin
  shp := TGIS_Shape(
    GIS.Locate( GIS.ScreenToMap( Point( X,  Y ) ), 5 / GIS.Zoom )
  ) ;

  if not Assigned( shp ) then
    exit ;

  shp.Layer.DeselectAll ;
  shp.IsSelected := not shp.IsSelected ;

  GIS_ControlAttributes.ShowShape( shp ) ;
end;

procedure TfrmGridToVector.GISMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
begin
  if GIS.IsEmpty then
    exit;

  pt := GIS.ScreenToClient( MousePos ) ;
  GIS.ZoomBy( 1/2, pt.X, pt.Y ) ;
end;

procedure TfrmGridToVector.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
begin
  if GIS.IsEmpty then
    exit;

  pt := GIS.ScreenToClient( MousePos ) ;
  GIS.ZoomBy( 2/1, pt.X, pt.Y ) ;
end;
end.
