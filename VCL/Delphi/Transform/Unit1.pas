//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide simple layer transformation.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
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
  GisUtils,
  GisFunctions,
  GisLayerVector,
  GisGeometryFactory,
  GISLayerPixel,
  GisResource,
  GisTransform,
  GisTypesUI,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    pnl1: TPanel;
    btnTransform: TButton;
    btnCut: TButton;
    btnSave: TButton;
    btnLoad: TButton;
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure btnTransformClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnCutClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;
  trn := TGIS_TransformPolynomial.Create() ;

  trn.AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                True
               ) ;
  trn.AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 245859.524147727 ),
                2,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;

  trn.CuttingPolygon := 'POLYGON((421.508902077151 -320.017804154303,' +
                        '518.161721068249 -223.364985163205,' +
                        '688.725519287834 -210.572700296736,' +
                        '864.974777448071 -254.635014836795,' +
                        '896.244807121662 -335.652818991098,' +
                        '894.823442136499 -453.626112759644,' +
                        '823.755192878338 -615.661721068249,' +
                        '516.740356083086 -607.13353115727,' +
                        '371.761127596439 -533.222551928783,' +
                        '340.491097922849 -456.46884272997,' +
                        '421.508902077151 -320.017804154303))' ;

  trn.Prepare( TGIS_PolynomialOrder.First ) ;
  lp.Transform := trn ;
  lp.Transform.Active := True ;
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.btnLoadClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;

  trn := TGIS_TransformPolynomial.Create() ;
  trn.LoadFromFile( 'satellite.jpg' + GIS_TRN_EXT ) ;
  lp.Transform := trn ;
  lp.Transform.Active := True ;

  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;
  if assigned( lp.Transform ) then
    lp.Transform.SaveToFile( 'satellite.jpg' + GIS_TRN_EXT ) ;
end;

procedure TForm1.btnTransformClick(Sender: TObject);
var
  trn : TGIS_TransformPolynomial ;
  lp  : TGIS_LayerPixel ;
begin
  lp := GIS.Items[0] as TGIS_LayerPixel;

  trn := TGIS_TransformPolynomial.Create() ;

  trn.AddPoint( GisPoint( -0.5  , -944.5 ),
                GisPoint( 1273285.84090909, 239703.615056818 ),
                0,
                True
               ) ;
  trn.AddPoint( GisPoint( -0.5  , 0.5    ),
                GisPoint( 1273285.84090909, 244759.524147727 ),
                1,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, 0.5    ),
                GisPoint( 1279722.65909091, 245859.524147727 ),
                2,
                True
               ) ;
  trn.AddPoint( GisPoint( 1246.5, -944.5 ),
                GisPoint( 1279744.93181818, 239725.887784091 ),
                3,
                True
               ) ;
  trn.Prepare( TGIS_PolynomialOrder.First ) ;
  lp.Transform := trn ;
  lp.Transform.Active := True ;
  lp.SetCSByEPSG( 102748 ) ;

  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Rectify\satellite.jpg' ) ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;

  // let's locate our position on the map and display coordinates, zoom
  ptg := GIS.ScreenToMap( Point(X,Y) ) ;
  StatusBar1.SimpleText := Format( 'X : %.4f | Y : %.4f', [ptg.X, ptg.Y] ) ;
end;

end.
