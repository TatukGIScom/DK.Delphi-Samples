//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provied a join to external database and how to provide charts.
}
unit Unit1;

interface

uses

  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  System.Variants,

  Winapi.Windows,
  Winapi.AdoInt,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerVector,
  GisLayerSHP,
  GisParams,
  GisTopology,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd, System.ImageList;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    cmbValues: TComboBox;
    cmbSize: TComboBox;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    cmbStyle: TComboBox;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure ButtonZoomOutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbChange(Sender: TObject);
  private
    { Private declarations }
    sqlDC : Variant ;
    sqlRS : Variant ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  cmbSize.ItemIndex   := 0 ;
  cmbValues.ItemIndex := 0 ;
  cmbStyle.ItemIndex  := 0 ;

  // create ADO objects - one for keeping connection, second for data
  sqlDC := CreateOleObject('ADODB.Connection') ;
  sqlRS := CreateOleObject('ADODB.Recordset') ;

  // connect to database
  sqlDC.Open( Format( 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb',
                      [ TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\Statistical\']
                    )
            ) ;

  // use layer to display charts
  ll      := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\tl_2008_06_county.shp' ;
  ll.Name := 'tl_2008_06_county';

  ll.UseConfig                  := False ;
  ll.Params.Labels.Field        :='name';
  ll.Params.Labels.Pattern      := TGIS_BrushStyle.Clear ;
  ll.Params.Labels.OutlineWidth := 0 ;
  ll.Params.Labels.Font.Color   := TGIS_Color.White ;
  ll.Params.Labels.Color        := TGIS_Color.Black ;
  ll.Params.Labels.Position     := [ TGIS_LabelPosition.MiddleCenter,  TGIS_LabelPosition.Flow] ;

  GIS.Add(ll) ;
  GIS.FullExtent ;

  cmbChange(Self) ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  sqlRS.Close ;
  sqlDC.Close ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
   GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.ButtonZoomOutClick(Sender: TObject);
begin
   GIS.Zoom := GIS.Zoom / 2 ;
end;


procedure TForm1.cmbChange(Sender: TObject);
var
  ll      : TGIS_LayerVector ;
  vsize   : String ;
  vvalues : String ;
  vstyle  : String ;
  vmin    : Double ;
  vmax    : Double ;
   q       : _Recordset ;
  _query  : OleVariant ;
begin
  ll := TGIS_LayerVector(GIS.Items[0]) ;
  if not Assigned( ll ) then exit ;

  // get params
  vsize   := cmbSize.Items  [ cmbSize.ItemIndex   ] ;
  vvalues := cmbValues.Items[ cmbValues.ItemIndex ] ;
  vstyle  := cmbStyle.Items [ cmbStyle.ItemIndex  ] ;

  if sqlRS.State <> 0 then
    sqlRS.Close ;

  // find min, max values for shapes
  sqlRS.Open( Format( 'SELECT min(%s) AS mini, max(%s) AS maxi FROM ce2000t',
                      [ vsize, vsize ]
                    ),
              sqlDC
            ) ;

  vmin := sqlRS.Fields[ 'mini' ].Value ;
  vmax := sqlRS.Fields[ 'maxi' ].Value ;
  sqlRS.Close ;

  // let's load data to recordset
  _query := 'select * FROM ce2000t ORDER BY fips';
  sqlRS.Open( _query, sqlDC ) ;

  // connect layer with query results
  if (IUnknown(sqlRS).QueryInterface(_Recordset, q) = S_OK) then
      ll.JoinADO := q;

  // set primary and foreign keys
  ll.JoinPrimary := 'cntyidfp' ;
  ll.JoinForeign := 'fips'   ;

  // Set the chart style: "Pie" or "Bar"
  ll.Params.Chart.Style       := ParamChart( vstyle, TGIS_ChartStyle.Pie ) ;

  // The chart size will be set by Render in the range of 350 to 1000
  // depending on the value of the "vsize" field
  ll.Params.Chart.Size        := GIS_RENDER_SIZE ;
  ll.Params.Render.StartSize  := 350  ;
  ll.Params.Render.EndSize    := 1000 ;
  ll.Params.Render.Expression := vsize ;

  // The Renderer will create 10 zones to group field values,
  // starting from "vmin" and edning with "vmax"
  ll.Params.Render.Zones      := 10 ;
  ll.Params.Render.MinVal     := vmin ;
  ll.Params.Render.MaxVal     := vmax ;

  // For 'Bar' chart you can replace '0:0' by 'min:max' to set custom Y-axis limits.
  // 'vvalues' contains list of values displayed on the chart.
  // In this sample field names are used, e.g. 'male2000:female2000'.
  // Values need to be divided by a colon ':'.
  ll.Params.Render.Chart      := '0:0:' + vvalues ;

  // If necessary, the chart can also be included in the legend
  ll.Params.Chart.Legend      := ll.Params.Render.Chart ;
  ll.Params.Chart.ShowLegend  := True ;

  GIS.InvalidateWholeMap ;
end;

end.
