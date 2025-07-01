//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to utilize the vector-to-grid generation methods.
}

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls,

  GisTypesUI,
  VCL.GisControlLegend,
  VCL.GisViewerWnd ;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    lblMethod: TLabel;
    rbtnIDW: TRadioButton;
    rbtnKriging: TRadioButton;
    rbtnSplines: TRadioButton;
    rbtnHeatMap: TRadioButton;
    btnGenerateGrid: TButton;
    pbProgress: TProgressBar;
    rbtnConcentrationMap: TRadioButton;
    lblSemivariance: TLabel;
    cmbSemivariance: TComboBox;
    procedure btnGenerateGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
    procedure doRbtnAnyClick(
          _sender : TObject
    ) ;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  GisRtl,
  GisTypes,
  GisFunctions,
  GisUtils,
  GisRegistredLayers,
  GisLayer,
  GisLayerVector,
  GisLayerPixel,
  GisCsFactory,
  GisInterpolation;

{$R *.dfm}

const
  FIELD_VALUE : String = 'TEMP' ;
  GRID_RESOLUTION : Integer = 400 ;

procedure TfrmMain.doBusyEvent(
      _sender : TObject ;
      _pos    : Integer ;
      _end    : Integer ;
  var _abort  : Boolean
) ;
begin
  case _pos of
    // initialize progress bar
    0  : begin
      pbProgress.Min := 0 ;
      pbProgress.Max := 100 ;
      pbProgress.Position := 0 ;
    end ;
    // end of progress - reset progress bar
    -1 : pbProgress.Position := 0 ;
  else
    pbProgress.Position := _pos ;
  end ;
end ;

procedure TfrmMain.doRbtnAnyClick(
  _sender : TObject
) ;
begin
  if rbtnKriging.Checked then begin
    lblSemivariance.Visible := True ;
    cmbSemivariance.Visible := True ;
  end
  else begin
    lblSemivariance.Visible := False ;
    cmbSemivariance.Visible := False ;
  end ;
end ;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\Interpolation\Interpolation.ttkproject' ) ;
  GIS.CS := TGIS_CSFactory.ByEPSG( 3395 ) ;
  GIS.FullExtent ;

  rbtnIDW.OnClick := doRbtnAnyClick ;
  rbtnKriging.OnClick := doRbtnAnyClick ;
  rbtnSplines.OnClick := doRbtnAnyClick ;
  rbtnHeatMap.OnClick := doRbtnAnyClick ;
  rbtnConcentrationMap.OnClick := doRbtnAnyClick ;
end;

procedure TfrmMain.btnGenerateGridClick(Sender: TObject);
var
  src : TGIS_LayerVector ;
  dst : TGIS_LayerPixel ;
  plg : TGIS_LayerVector ;
  ext : TGIS_Extent ;
  rat : Double ;
  clr : TGIS_Color ;

  procedure doIDW ;
  var
    vtg : TGIS_InterpolationIDW ;
  begin
    vtg := TGIS_InterpolationIDW.Create ;
    try
      // for windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.
      // vtg.Windowed := True ;
      // vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // attach the event to automatically update the progress bar
      vtg.BusyEvent := doBusyEvent ;
      // set the exponent parameter of the IDW formula (default is 2.0,
      // 3.0 gives nice results in most cases)
      vtg.Exponent := 3.0 ;
      // generate the Inverse Distance Squared (IDW) interpolation grid
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  procedure doKriging ;
  var
    vtg : TGIS_InterpolationKriging ;
  begin
    vtg := TGIS_InterpolationKriging.Create ;
    try
      // for windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.
      // vtg.Windowed := True ;
      // vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // attach the event to automatically update the progress bar
      vtg.BusyEvent := doBusyEvent ;
      // set Semivarinace; default is Power Law (code for case 0 is not needed)
      case cmbSemivariance.ItemIndex of
        0 : vtg.Semivariance := TGIS_SemivariancePowerLaw.Create ;
        1 : vtg.Semivariance := TGIS_SemivarianceExponential.Create ;
        2 : vtg.Semivariance := TGIS_SemivarianceGaussian.Create ;
        3 : vtg.Semivariance := TGIS_SemivarianceSpherical.Create ;
        4 : vtg.Semivariance := TGIS_SemivarianceCircular.Create ;
        5 : vtg.Semivariance := TGIS_SemivarianceLinear.Create ;
      end ;
      // generate the Kriging interpolation grid
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  procedure doSplines ;
  var
    vtg : TGIS_InterpolationSplines ;
  begin
    vtg := TGIS_InterpolationSplines.Create ;
    try
      // for windowed version of this method you need to set Windowed=True
      // and at least the Radius, e.g.
      // vtg.Windowed := True ;
      // vtg.Radius := ( ext.XMax - ext.XMin )/5.0 ;

      // attach the event to automatically update the progress bar
      vtg.BusyEvent := doBusyEvent ;
      // set the tension parameter of Splines (value need to be adjusted for
      // the data)
      vtg.Tension := 1e-9 ;
      // generate the Completely Regularized Splines interpolation grid
      vtg.Generate( src, src.Extent, FIELD_VALUE, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

  procedure doHeatmap( const _concentration : Boolean ) ;
  var
    vtg : TGIS_GaussianHeatmap ;
    fld : String ;
  begin
    vtg := TGIS_GaussianHeatmap.Create ;
    try
      // for Concentration Map the coordinate must be None and source field
      // must be empty
      vtg.Coordinate := TGIS_VectorToGridCoordinate.None ;
      if _concentration then
        fld := ''
      else
        fld := FIELD_VALUE ;

      // attach the event to automatically update the progress bar
      vtg.BusyEvent := doBusyEvent ;
      // estimate the 3-sigma for Gaussian (can be set manually with Radius)
      vtg.EstimateRadius( src, src.Extent, dst ) ;
      // correct the Radius after estimation (if needed)
      vtg.Radius := vtg.Radius/2.0 ;
      // generate the Heat/Concentaration Map grid
      vtg.Generate( src, src.Extent, fld, dst, dst.Extent ) ;
    finally
      FreeObject( vtg ) ;
    end ;
  end ;

begin
  btnGenerateGrid.Enabled := False ;

  // obtain a handle to the source layer
  src := TGIS_LayerVector( GIS.Get( 'temperatures' ) ) ;
  // obtain a handle to the polygonal layer (largest extent)
  plg := TGIS_LayerVector( GIS.Get( 'country' ) ) ;

  // remove any previously created grid layer
  if Assigned( GIS.Get( 'grid' ) ) then
    GIS.Delete( 'grid' ) ;

  // get the source layer extent
  ext := plg.Extent ;

  // calculate the height/width ratio of the extent to properly set the grid
  // resolution
  rat := ( ext.YMax - ext.YMin )/( ext.XMax - ext.XMin ) ;

  // create and initialize the destination layer
  dst := TGIS_LayerPixel.Create ;
  dst.Name := 'grid' ;
  dst.Build( True, src.CS, ext, GRID_RESOLUTION, RoundS( rat*GRID_RESOLUTION ) ) ;
  dst.Params.Pixel.GridShadow := False ;

  // choose the start color of the grid ramp
  clr := TGIS_Color.Blue ;

  // find out which vector-to-grid has beeno chosen
  if rbtnIDW.Checked then begin
    // perform Inverse Distance Squared (IDW) interpolation
    doIDW ;
  end
  else
  if rbtnKriging.Checked then begin
    // perform Kriging interpolation
    doKriging ;
  end
  else
  if rbtnSplines.Checked then begin
    // perform Completely Regularized Splines interpolation
    doSplines ;
  end
  else
  if rbtnHeatMap.Checked then begin
    // perform Heat Map generation
    doHeatmap( False ) ;
    // choose the start color for the grid ramp with ALPHA=0 to make it
    // semitransparent
    clr := TGIS_Color.FromARGB( 0, 0, 0, 255 ) ;
  end
  else
  if rbtnConcentrationMap.Checked then begin
    // perform Concentration Map generation
    doHeatmap( True ) ;
    // choose the start color for the grid ramp with ALPHA=0 to make it
    // semitransparent
    clr := TGIS_Color.FromARGB( 0, 0, 0, 255 ) ;
  end ;

  // apply color ramp to the grid layer
  dst.GenerateRamp(
    clr, TGIS_Color.Lime, TGIS_Color.Red,
    dst.MinHeight, ( dst.MaxHeight - dst.MinHeight )/2, dst.MaxHeight, False,
    ( dst.MaxHeight - dst.MinHeight )/100,
    ( dst.MaxHeight - dst.MinHeight )/10,
    nil, False
  ) ;

  // limit the grid visibility only to the pixels contained within a polygon
  dst.CuttingPolygon := TGIS_ShapePolygon( plg.GetShape( 6 ).CreateCopy ) ;

  // add the grid layer to the viewer
  GIS.Add( dst ) ;
  // update the viewer to show the grid layer
  GIS.FullExtent ;

  // reset the progress bar
  pbProgress.Position := 0 ;

  btnGenerateGrid.Enabled := True ;
end;

end.
