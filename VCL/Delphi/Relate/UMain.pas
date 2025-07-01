//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to compute relations between two shapes.
  Main form
}
unit UMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.Classes,
  System.Types,
  System.SysUtils,
  System.Variants,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ToolWin,
  Vcl.ImgList,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Buttons,
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
    Panel1: TPanel;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    btnCheck: TSpeedButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ShapeA: TLabel;
    ShapeB: TLabel;
    Relations: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCheckClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    shpA : TGIS_Shape ;
    shpB : TGIS_Shape ;
    currshape : TGIS_Shape ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // open project
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Topology\topology2.shp');

  // set style params
  with TGIS_LayerVector( GIS.Items[0] ) do
  begin
    ParamsList.Add ;
    Params.Style := 'selected' ;
    Params.Area.OutlineWidth := 1 ;
  end ;
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // let's locate a shape after click
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision

  if not Assigned( shp ) then exit;

  shp := shp.MakeEditable ;

  if Button=mbLeft then
  begin
    // if selected shapeA, deselect it
    if Assigned( shpA ) then
    begin
      shpA.Params.Area.color := TGIS_Color.Gray;
      shpA.Params.Labels.Value:='';
      shpA.Invalidate ;
      ShapeA.Caption := 'UnSelected';
    end ;

    shpA :=shp;
    shpA.Params.Area.color := TGIS_Color.Blue;
    shpA.Params.Labels.Value:='Shape A';
    shpA.Params.Labels.Position := [TGIS_LabelPosition.UpLeft] ;
    shpA.Invalidate ;
    ShapeA.Caption := 'Selected';
  end ;

  if (Button=mbRight)then
  begin
     // if selected shapeB, deselect it
    if Assigned( shpB ) then
    begin
      shpB.Params.Area.color := TGIS_Color.Gray;
      shpB.Params.Labels.Value:='';
      shpB.Invalidate ;
      ShapeB.Caption := 'UnSelected';
    end ;

    shpB :=shp;
    shpB.Params.Area.color := TGIS_Color.Red;
    shpB.Params.Labels.Value:='Shape B';
    shpB.Params.Labels.Position := [TGIS_LabelPosition.UpLeft] ;
    shpB.Invalidate ;
    ShapeB.Caption := 'Selected';
  end
end;

procedure TForm1.btnCheckClick(Sender: TObject);
begin
  Relations.Lines.Clear;

  if (not Assigned (shpA)) or (not Assigned(shpB)) then exit;

  // check all relations
  if shpA.Relate(shpB,RELATE_EQUALITY)       then Relations.Lines.Add('EQUALITY');
  if shpA.Relate(shpB,RELATE_DISJOINT)       then Relations.Lines.Add('DISJOINT');
  if shpA.Relate(shpB,RELATE_INTERSECT)      then Relations.Lines.Add('INTERSECT');
  if shpA.Relate(shpB,RELATE_INTERSECT1)     then Relations.Lines.Add('INTERSECT1');
  if shpA.Relate(shpB,RELATE_INTERSECT2)     then Relations.Lines.Add('INTERSECT2');
  if shpA.Relate(shpB,RELATE_INTERSECT3)     then Relations.Lines.Add('INTERSECT3');
  if shpA.Relate(shpB,RELATE_WITHIN)         then Relations.Lines.Add('WITHIN');
  if shpA.Relate(shpB,RELATE_CROSS)          then Relations.Lines.Add('CROSS');
  if shpA.Relate(shpB,RELATE_CROSS_LINE)     then Relations.Lines.Add('CROSS_LINE');
  if shpA.Relate(shpB,RELATE_TOUCH)          then Relations.Lines.Add('TOUCH');
  if shpA.Relate(shpB,RELATE_TOUCH_INTERIOR) then Relations.Lines.Add('TOUCH_INTERIOR');
  if shpA.Relate(shpB,RELATE_CONTAINS)       then Relations.Lines.Add('CONTAINS');
  if shpA.Relate(shpB,RELATE_OVERLAP)        then Relations.Lines.Add('OVERLAP');
  if shpA.Relate(shpB,RELATE_OVERLAP_LINE)   then Relations.Lines.Add('OVERLAP_LINE');
end;

end.
