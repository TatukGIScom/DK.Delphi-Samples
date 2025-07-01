//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to use TGIS_DataSet.
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
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.StdCtrls,
  Vcl.FileCtrl,
  Vcl.ExtCtrls,
  Vcl.DBCtrls,

  Data.DB,

  //GisLicense,
  GisAllLayers,
  GisDataSet,
  GisEditor,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,
  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    GIS: TGIS_ViewerWnd;
    Splitter1: TSplitter;
    GIS_DataSet1: TGIS_DataSet;
    DBGrid1: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure GIS_DataSet1AfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\tl_2008_06_county.shp' ) ;
  ll := TGIS_LayerVector(GIS.Items[0]);
  ll.Params.Labels.Field := 'GIS_UID';
  GIS_DataSet1.Open( TGIS_LayerVector( GIS.Items[0] ), GIS.Extent ) ;
end;

procedure TForm1.GIS_DataSet1AfterScroll(DataSet: TDataSet);
begin
  if GIS_DataSet1.ActiveShape <> nil then
  GIS.Lock ;
  GIS.VisibleExtent := GIS_DataSet1.ActiveShape.Extent ;
  GIS.Zoom := GIS.Zoom * 0.8 ;
  GIS.Unlock ;
end;

end.
