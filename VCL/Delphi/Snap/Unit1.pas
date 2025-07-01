//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to tracking points.
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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    btnWithoutSnapping: TButton;
    btnWithSnapping: TButton;
    tmrWithSnapping: TTimer;
    tmrWithoutSnapping: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnWithoutSnappingClick(Sender: TObject);
    procedure tmrWithoutSnappingTimer(Sender: TObject);
    procedure btnWithSnappingClick(Sender: TObject);
    procedure tmrWithSnappingTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    shpPolice   : TGIS_Shape ; // police shape
    cntPoint    : Integer    ; // number of evaluated points
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
 ll : TGIS_LayerVector ;
begin
  // lets open streets
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload+
            '\World\Countries\USA\States\California\San Bernardino\TIGER\tl_2008_06071_edges_trunc.shp'
           ) ;
  GIS.Zoom := GIS.Zoom * 5 ;
  GIS.CenterViewport( TGIS_Utils.GisPoint( -117.0208, 34.0629) );
  // now create a points layer
  ll := TGIS_LayerVector.Create ;
  ll.Path := 'trackingpoints' ;
  ll.CS := GIS.CS ;
  GIS.Add( ll ) ;
  ll.Params.Labels.Allocator := False ;
  ll.CachedPaint := False ;
  GIS.Unlock;

  // and attach to it our test police-car point
  shpPolice := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shpPolice.Params.Marker.Symbol :=
            SymbolList.Prepare( TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\police.bmp?TRUE' ) ;
  shpPolice.Params.Marker.Size := -13 ;
  shpPolice.Params.Labels.OutlineWidth := 0  ;
  shpPolice.Params.Labels.Pattern      := TGIS_BrushStyle.Clear ;
  shpPolice.Params.Labels.Position     := [TGIS_LabelPosition.DownCenter] ;
  shpPolice.Params.Labels.Value        := '112' ;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  // close viewer - all layers and shapes will be free
  GIS.Close ;
end;


procedure TForm1.btnWithoutSnappingClick(Sender: TObject);
begin
  btnWithoutSnapping.Enabled := False ;
  btnWithSnapping.Enabled    := False ;

  // Let's travel from center of the screen
  shpPolice.SetPosition( Gis.Center, nil, 0 ) ;

  cntPoint := 0 ;
  tmrWithoutSnapping.Enabled := True ;
end;

procedure TForm1.tmrWithoutSnappingTimer(Sender: TObject);
var
  ptg : TGIS_Point ;
begin
  // to protect against circular calling
  tmrWithoutSnapping.Enabled := False ;

  // let's move in some aribtrary direction
  // normally you can read here a GPS position etc.
  ptg.X := shpPolice.Centroid.X - 0.00020 ;
  ptg.Y := shpPolice.Centroid.Y + 0.00010 ;

  // move icon over the map
  shpPolice.Lock( TGIS_Lock.Projection ) ;
  shpPolice.SetPosition( ptg, nil, 0 ) ;
  shpPolice.Unlock ;
  Inc( cntPoint ) ;

  // not end? - reenable the timer
  if cntPoint < 120 then
    tmrWithoutSnapping.Enabled := True
  else begin
    btnWithoutSnapping.Enabled := True ;
    btnWithSnapping.Enabled    := True ;
  end ;
end;


procedure TForm1.btnWithSnappingClick(Sender: TObject);
begin
  btnWithoutSnapping.Enabled := False ;
  btnWithSnapping.Enabled    := False ;

  shpPolice.SetPosition( Gis.Center, nil, 0 ) ;

  cntPoint := 0 ;
  tmrWithSnapping.Enabled := True ;
end;


procedure TForm1.tmrWithSnappingTimer(Sender: TObject);
var
  ptg : TGIS_Point ;
begin
  // to protect against circular calling
  tmrWithSnapping.Enabled := False ;

  // let's move in some aribtrary direction
  // normally you can read here a GPS position etc.
  ptg.X := shpPolice.Centroid.X - 0.00020  ;
  ptg.Y := shpPolice.Centroid.Y + 0.00010 ;
     // ptg.X := GIS.CS.FromWgs84( GisPoint( objGps.Longitude, objGps.Latitude ) ) ;

  // move icon over the map
     // is not elegant to access Items[0] but its only sample :>
  shpPolice.Lock( TGIS_Lock.Projection ) ;
  shpPolice.SetPosition( ptg,
                         TGIS_LayerVector( GIS.Items[0] ),
                         0.05 ) ;
  shpPolice.Unlock ;
  Inc( cntPoint ) ;
  // not end? - reenable the timer
  if cntPoint < 120 then
    tmrWithSnapping.Enabled := True
  else begin
    btnWithoutSnapping.Enabled := True ;
    btnWithSnapping.Enabled    := True ;
  end ;
end;


end.
