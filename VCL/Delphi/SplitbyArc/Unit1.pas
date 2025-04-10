//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to split shapes by arc.
}

unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  //GisLicense,
  GisAllLayers,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTopology,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    paLeft: TPanel;
    GIS: TGIS_ViewerWnd;
    btnLine: TButton;
    btnSplit: TButton;
    gboxResult: TGroupBox;
    lbInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnSplitClick(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    layerObj      : TGIS_LayerVector ;    //layer for new shapes
    shpPolygon    : TGIS_ShapePolygon;    //shape for split
    shpArc        : TGIS_ShapeArc;        //shape for line
    layerPolygon  : TGIS_LayerVector ;
    layerArc      : TGIS_LayerVector ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology3.shp' );

  layerPolygon := TGIS_LayerVector( GIS.Items[0] );
  shpPolygon := TGIS_ShapePolygon( layerPolygon.GetShape( 1 ).MakeEditable ) ;
  if not Assigned( shpPolygon ) then exit ;

  layerArc := TGIS_LayerVector.Create ;     //create layer for line
  layerArc.Params.Line.Color := TGIS_Color.Red;
  layerArc.Params.Line.Width := 25;
  if not Assigned( layerArc ) then exit ;
  GIS.Add( layerArc );

  shpArc := TGIS_ShapeArc(TGIS_LayerVector( GIS.Items[1] ).CreateShape( TGIS_ShapeType.Arc ));
  if not Assigned( shpArc ) then exit ;
  shpArc.AddPart ;

  layerObj := TGis_LayerVector.Create;      //create layer for new shapes - after split
  layerObj.Name := 'Splits' ;
  GIS.Add( layerObj );
  GIS.Unlock;

  GIS.FullExtent ;
  GIS.RestrictedExtent := GIS.Extent;
end;

procedure TForm1.btnLineClick(Sender: TObject);
begin
  layerObj.RevertShapes ;        //clear layer with new polygons
  shpArc.Reset;               //clear line
  shpArc.AddPart ;            //initiate for new points
  lbInfo.Caption := '...';
  GIS.InvalidateWholeMap;
  btnSplit.Enabled := false;
end;

procedure TForm1.btnSplitClick(Sender: TObject);
var
  n : Integer;
  shape_list: TGIS_ObjectList;
  topology_obj : TGIS_Topology ;
begin
  layerObj.RevertShapes ;
  topology_obj := TGIS_Topology.Create ;
  try
    shape_list := topology_obj.SplitByArc(shpPolygon, shpArc, True);
    if Assigned( shape_list ) then
    begin
     lbInfo.Caption := IntToStr( shape_list.Count ) ;
     Randomize ;
     for n := 0 to shape_list.Count - 1 do
     begin
       TGIS_Shape( shape_list.Items[ n ] ).Params.Area.Color := TGIS_Color.FromRGB(Random( 255 ) * 256 * 256 + Random( 255 ) * 256 + Random( 256 )) ;
       layerObj.AddShape( TGIS_Shape(shape_list.Items[ n ]) ) ;
     end;
    shape_list.Free;
    end;
  finally
    topology_obj.Free ;
  end ;

  GIS.InvalidateWholeMap ;
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg   : TGIS_Point ;
begin                          //add point to line
  if GIS.IsEmpty then exit ;

  ptg := GIS.ScreenToMap( Point(x, y ) );
  shpArc.Lock( TGIS_Lock.Extent ) ;
  shpArc.AddPoint( ptg );
  shpArc.Unlock ;
  GIS.InvalidateWholeMap ;
  if shpArc.Intersect( shpPolygon ) then
    btnSplit.Enabled := true;
end;

procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg   : TGIS_Point ;
begin                          //add point to line
  if GIS.IsEmpty then exit ;

  ptg := GIS.ScreenToMap( Point(x, y ) );
  shpArc.Lock( TGIS_Lock.Extent ) ;
  shpArc.AddPoint( ptg );
  shpArc.Unlock ;
  GIS.InvalidateWholeMap;
  if shpArc.Intersect( shpPolygon ) then
    btnSplit.Enabled := true;
end;

end.
