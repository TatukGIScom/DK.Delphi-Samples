//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide a join to external database and how to cutom rendering.
}

unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Win.ComObj,

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
  Vcl.Dialogs,

  //GisLicense,
  GisViewer,
  GisUtils,
  GisLayerVector,
  GisLayerSHP,
  GisTopology,
  GisParams,
  GisEditor,
  GisTypesUI,
  GisTypes,

  Vcl.GisControlLegend,
  Vcl.GisViewerWnd, System.ImageList;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    cmbSize: TComboBox;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    GIS_Legend: TGIS_ControlLegend;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    scrTransparency: TTrackBar;
    dlgColor: TColorDialog;
    panColorStart: TPanel;
    panColorEnd: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure ButtonZoomOutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbChange(Sender: TObject);
    procedure scrTransparencyChange(Sender: TObject);
    procedure panColorStartClick(Sender: TObject);
    procedure panColorEndClick(Sender: TObject);
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

  // create Ado objects and make connection to database
  sqlDC := CreateOleObject( 'ADODB.Connection' ) ;
  sqlRS := CreateOleObject( 'ADODB.Recordset' ) ;
  sqlDC.Open( Format( 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb',
                      [ TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\Statistical\']
                    )
            ) ;

  // create a layer, set render and label params
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
  ll.Params.Render.StartSize  := 350  ;
  ll.Params.Render.EndSize    := 1000 ;

  GIS.Add(ll) ;
  GIS.FullExtent ;

  cmbChange(Self) ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if sqlRS.State<>0 then sqlRS.Close ;
  if sqlDC.State<>0 then sqlDC.Close ;
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
  vmin    : Double ;
  vmax    : Double ;
  q  : _Recordset ;
  _query  : OleVariant ;
begin
  ll := TGIS_LayerVector( GIS.Items[0] );
  if not Assigned( ll ) then
    exit ;

  vsize   := cmbSize.Items  [ cmbSize.ItemIndex   ] ;

  if sqlRS.State <> 0 then
    sqlRS.Close ;

  // find min, max values for table
  sqlRS.Open( Format( 'SELECT min(%s) AS mini, max(%s) AS maxi FROM ce2000t',
                      [ vsize, vsize ]
                    ),
              sqlDC
            ) ;

  // remember them
  vmin := sqlRS.Fields[ 'mini' ].Value ;
  vmax := sqlRS.Fields[ 'maxi' ].Value ;
  sqlRS.Close ;

  // create a dataset
  _query := 'select * FROM ce2000t ORDER BY fips';
  sqlRS.Open( _query, sqlDC ) ;

  // connect layer with query results
  if (IUnknown(sqlRS).QueryInterface(_Recordset, q) = S_OK) then
    ll.JoinADO := q;

  // set indexes
  ll.JoinPrimary := 'cntyidfp' ;
  ll.JoinForeign := 'fips'   ;

  // and render params
  ll.Params.Render.Expression := vsize ;
  ll.Params.Render.Zones      := 10 ;
  ll.Params.Render.MinVal     := vmin ;
  ll.Params.Render.MaxVal     := vmax ;
  ll.Params.Render.StartColor := TGIS_Color.FromBGR (panColorStart.Color );
  ll.Params.Render.EndColor   := TGIS_Color.FromBGR (panColorEnd.Color   )   ;
  ll.Params.Area.Color        := TGIS_Color.RenderColor ;
  ll.Params.Area.ShowLegend   := True ;

  GIS.InvalidateWholeMap ;
end;

procedure TForm1.scrTransparencyChange(Sender: TObject);
var
  ll      : TGIS_LayerVector ;
begin
  ll := TGIS_LayerVector( GIS.Items[0] );
  if not Assigned( ll ) then exit ;

  // change transparency
  ll.Transparency := scrTransparency.Position ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.panColorStartClick(Sender: TObject);
begin
  if not dlgColor.Execute then exit;

  panColorStart.Color := dlgColor.Color;
  cmbChange(Self) ;
end;

procedure TForm1.panColorEndClick(Sender: TObject);
begin
  if not dlgColor.Execute then exit;

  panColorEnd.Color := dlgColor.Color;
  cmbChange(Self) ;
end;

end.
