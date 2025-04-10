//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to perform WKT operation.
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,

  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.Controls,
  Vcl.Graphics,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisTopology,
  GisTypesUI,
  GisUtils,
  GisViewer,
  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    ToolBar1: TToolBar;
    cbType: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
  private
    { Private declarations }
    layerObj : TGIS_LayerVector ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // create a layer
  layerObj := TGIS_LayerVector.Create ;
  layerObj.Name := 'output' ;
  layerObj.Params.Area.Color := TGIS_Color.Red ;

  GIS.Add( layerObj ) ;
  GIS.FullExtent ;
  Memo1.Text :='POLYGON( ( 5 5, 25 5, 25 25, 5 25, 5 5 ), ( 10 10, 10 20, 20 20, 20 10, 10 10 ) )' ;
  cbType.ItemIndex := 4 ;
  btnParseClick(Self) ;
end;


procedure TForm1.btnParseClick(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  try
    // add a shape to layer from WKT
    layerObj.RevertShapes ;
    shp := TGIS_Utils.GisCreateShapeFromWKT( Memo1.Text ) ;
    layerObj.AddShape( shp ) ;
    shp.Free ;
  except
    ShowMessage( 'Bad format' ) ;
  end ;
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.Memo1Change(Sender: TObject);
var
  shp : TGIS_Shape ;
begin
  try
    layerObj.RevertShapes ;
    shp := TGIS_Utils.GisCreateShapeFromWKT( Memo1.Text ) ;
    if Assigned( shp ) then
    begin
      layerObj.AddShape( shp ) ;
      shp.Free ;
    end
    else
      Abort ;
    Memo1.Font.Color := clBlack ;
  except
    Memo1.Font.Color := clRed ;
  end ;
  layerObj.RecalcExtent ;
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.cbTypeChange(Sender: TObject);
begin
 case cbType.ItemIndex of
     0 : Memo1.Text :='POINT (30 30)';
     1 : Memo1.Text :='MULTIPOINT (4 4, 5 5, 6 6 ,7 7)';
     2 : Memo1.Text :='LINESTRING (3 3, 10 10)';
     3 : Memo1.Text :='MULTILINESTRING ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))';
     4 : Memo1.Text :='POLYGON ((5 5, 25 5, 25 25, 5 25, 5 5), (10 10, 10 20, 20 20, 20 10, 10 10))';
     5 : Memo1.Text :='POINTZ (30 30 100)';
     6 : Memo1.Text :='MULTIPOINTZ (4 4 100, 5 5 100, 6 6 100, 7 7 100)';
     7 : Memo1.Text :='LINESTRINGZ (3 3 100, 10 10 100)';
     8 : Memo1.Text :='MULTILINESTRINGZ ((5 5 100, 25 5 100, 25 25 100, 5 25 100, 5 5 100), (10 10 100, 10 20 100, 20 20 100, 20 10 100, 10 10 100))';
     9 : Memo1.Text :='POLYGONZ ((5 5 100, 25 5 100, 25 25 100, 5 25 100, 5 5 100), (10 10 100, 10 20 100, 20 20 100, 20 10 100, 10 10 100))';
     10 : Memo1.Text :='GEOMETRYCOLLECTION (POINT (30 30), LINESTRING (3 3, 10 10) )';
 end;
 btnParseClick(Self)
end;

end.
