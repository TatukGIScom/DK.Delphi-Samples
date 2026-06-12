//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  DataSet sample — demonstrates TGIS_DataSet as a live bridge between a GIS vector layer
  and a standard data-aware grid (TDBGrid).

  What the sample shows:
    - Loading a vector shapefile (California Counties) into the GIS viewer
    - Creating a TGIS_DataSet bound to the layer's attribute table
    - Connecting the DataSet to a TDBGrid via TDataSource
    - Bidirectional synchronization: grid rows ↔ map selection
    - Scrolling the grid auto-pans and zooms the viewer to the selected county
    - Grid displays all shape attributes in editable columns
    - Splitter control allows resizing viewer and grid panes
    - Real-time map-to-grid and grid-to-map interaction

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - vector layer backing the data
    TGIS_DataSet                - attribute table bridge (implements TDataSet)
    TDataSource                 - VCL data binding connector
    TDBGrid                     - standard VCL data-aware grid control
    GIS_DataSet1AfterScroll     - selection change event
    TGIS_Extent                 - geographic bounding box for zoom-to
    Shape attributes            - grid columns bound to feature fields
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


{ Loads the California Counties shapefile, opens the DataSet on the layer, and binds it to the grid. }
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\tl_2008_06_county.shp' ) ;
  ll := TGIS_LayerVector(GIS.Items[0]);
  ll.Params.Labels.Field := 'GIS_UID';
  GIS_DataSet1.Open( TGIS_LayerVector( GIS.Items[0] ), GIS.Extent ) ;
end;

{ Pans and zooms the viewer to the county that was just scrolled to in the data set. }
procedure TForm1.GIS_DataSet1AfterScroll(DataSet: TDataSet);
begin
  if GIS_DataSet1.ActiveShape <> nil then
  GIS.Lock ;
  GIS.VisibleExtent := GIS_DataSet1.ActiveShape.Extent ;
  GIS.Zoom := GIS.Zoom * 0.8 ;
  GIS.Unlock ;
end;

end.
