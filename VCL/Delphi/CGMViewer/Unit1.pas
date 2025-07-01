//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
 Sample CGM Viewer
 How to rotate a symbol
}

unit Unit1;

interface

uses
  System.Classes,
  System.Math,

  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.FileCtrl,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.ToolWin,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    GIS: TGIS_ViewerWnd;
    Panel1: TPanel;
    FileList: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    ToolBar1: TToolBar;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure FileListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    shp : TGIS_Shape ;
    procedure drawSymbol ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisSymbol,
  GisTypes ;

{$R *.DFM}


procedure TForm1.drawSymbol ;
var
  w,h  : Integer ;
begin
  if not Assigned(shp) then exit;

  // create a symbol list
  shp.Params.Marker.Symbol := SymbolList.Prepare( FileList.FileName ) ;

  // calculate symbol size
  if Assigned( shp.Params.Marker.Symbol ) then
  begin
    shp.Params.Marker.Size := - Min( GIS.Width, Gis.Height ) * 2 div 3 ;

    // prepare to obtain computed width/height
    shp.Params.Marker.Symbol.Prepare( GIS, -5, TGIS_Color.Black, TGIS_Color.Black, 0, 0,  TGIS_LabelPosition.MiddleCenter, True ) ;
    w := shp.Params.Marker.Symbol.Width  ;
    h := shp.Params.Marker.Symbol.Height ;
    shp.Params.Marker.Symbol.Unprepare ;

    if h < w then
      shp.Params.Marker.Size :=  shp.Params.Marker.Size  * h div w;
  end
  else
    shp.Params.Marker.Size := 0 ;

  // set attributes
  shp.Params.Marker.Color := TGIS_Color.RenderColor ;
  shp.Params.Marker.OutlineColor := TGIS_Color.RenderColor ;
  GIS.InvalidateWholeMap ;
end ;


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  DirectoryListBox1.Directory := TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\' ;
  // new layer as a grid
  ll := TGIS_LayerVector.Create  ;
  GIS.Add( ll ) ;
  ll.Extent := TGIS_Utils.GisExtent( -90, -90, 90, 90 ) ;
  GIS.FullExtent ;

  // add coordinate layout
  shp := ll.CreateShape( TGIS_ShapeType.Arc ) ;
  shp.Params.Line.Width := 1 ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( -90, 0 ) ) ;
  shp.AddPoint( TGIS_Utils.GisPoint(  90, 0 ) ) ;

  shp := ll.CreateShape( TGIS_ShapeType.Arc ) ;
  shp.Params.Line.Width := 1 ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0, -90 ) ) ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0,  90 ) ) ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0, 0 ) ) ;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  drawSymbol ;
end;

procedure TForm1.DirectoryListBox1Change(Sender: TObject);
begin
  FileList.Directory := DirectoryListBox1.Directory ;
end;

procedure TForm1.FileListClick(Sender: TObject);
begin
  StatusBar1.SimpleText := FileList.FileName ;
  drawSymbol ;
end ;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // rotate symbol
  shp.Params.Marker.SymbolRotate := shp.Params.Marker.SymbolRotate+Pi/2 ;
  shp.Invalidate ;
end;

end.

