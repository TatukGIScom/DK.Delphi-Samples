//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to perform Topology operation.
}
unit Unit1;

interface

uses
  System.Classes,

  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    btnAplusB: TButton;
    btnAmultB: TButton;
    btnAminusB: TButton;
    btnBminusA: TButton;
    btnAxorB: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAplusBClick(Sender: TObject);
    procedure btnAmultBClick(Sender: TObject);
    procedure btnAminusBClick(Sender: TObject);
    procedure btnBminusAClick(Sender: TObject);
    procedure btnAxorBClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    topologyObj : TGIS_Topology ;
    layerObj : TGIS_LayerVector ;
    shpA : TGIS_ShapePolygon ;
    shpB : TGIS_ShapePolygon ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  topologyObj := TGIS_Topology.Create ;
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology.shp' ) ;

  ll := TGIS_LayerVector( GIS.Items[0] ) ;
  if not Assigned( ll ) then exit ;

  shpA := TGIS_ShapePolygon( ll.GetShape( 1 ).MakeEditable );
  if not Assigned( shpA ) then exit ;

  shpB := TGIS_ShapePolygon( ll.GetShape( 2 ).MakeEditable );
  if not Assigned( shpB ) then exit ;

  layerObj := TGIS_LayerVector.Create ;
  layerObj.Name := 'output' ;
  layerObj.Transparency := 50 ;
  layerObj.Params.Area.Color := TGIS_Color.Red ;

  GIS.Add( layerObj ) ;
  GIS.Unlock;
  GIS.FullExtent ;
end;

procedure TForm1.btnAplusBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Union ) ;
  if Assigned( tmp ) then
  begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnAmultBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Intersection ) ;
  if Assigned( tmp ) then
  begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnAminusBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.Difference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnBminusAClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpB, shpA, TGIS_TopologyCombineType.Difference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnAxorBClick(Sender: TObject);
var
  tmp : TGIS_Shape ;
begin
  layerObj.RevertShapes ;
  tmp := topologyObj.Combine( shpA, shpB, TGIS_TopologyCombineType.SymmetricalDifference ) ;
  if Assigned( tmp ) then begin
    layerObj.AddShape( tmp ) ;
    tmp.Free ;
  end ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(topologyObj) then topologyObj.Free;
end;

end.
