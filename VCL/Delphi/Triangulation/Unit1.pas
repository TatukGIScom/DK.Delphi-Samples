//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Generates a Voronoi diagram/Delaunay triangulation.
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
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes,
  Vcl.GisControlLegend,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ImageList1: TImageList;
    Panel1: TPanel;
    GIS_Attributes: TGIS_ControlAttributes;
    grpbxResult: TGroupBox;
    rdbtnVoronoi: TRadioButton;
    rdbtnDelaunay: TRadioButton;
    btnGenerate: TButton;
    lblName: TLabel;
    edtName: TEdit;
    GIS_ControlLegend1: TGIS_ControlLegend;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure rdbtnVoronoiClick(Sender: TObject);
    procedure rdbtnDelaunayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  GisTriangulation ;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // open a file
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\city.shp' ) ;

  // and add a new parametr
  with TGIS_LayerVector( GIS.Items[0] ) do
  begin
    Params.Marker.Color         := TGIS_Color.FromRGB($4080FF) ;
    Params.Marker.OutlineWidth  := 2 ;
    Params.Marker.Style         := TGIS_MarkerStyle.Circle ;

    ParamsList.Add ;
    Params.Style := 'selected' ;
    Params.Area.OutlineWidth := 1 ;
    Params.Area.color := TGIS_Color.Blue ;
  end ;
   GIS_ControlLegend1.Update ;
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
  if shp <> nil then
    GIS_Attributes.ShowShape(shp) ;
end;

procedure TForm1.rdbtnDelaunayClick(Sender: TObject);
begin
  edtName.Text := 'Delaunay' ;
end;

procedure TForm1.rdbtnVoronoiClick(Sender: TObject);
begin
  edtName.Text := 'Voronoi' ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnGenerateClick(Sender: TObject);
var
  lVrn : TGIS_LayerVector ;
begin
  if gis.Get( edtName.Text ) <> nil then
  begin
    ShowMessage( 'Result layer already exists. Use different name.') ;
    exit ;
  end ;

  if rdbtnVoronoi.Checked then
    lVrn := TGIS_LayerVoronoi.Create
  else
    lVrn := TGIS_LayerDelaunay.Create ;

  lVrn.Name := edtName.Text ;
  lVrn.ImportLayer( TGIS_LayerVector( GIS.Items[ 0 ] ), GIS.Extent,
                    TGIS_ShapeType.Unknown, '', False
                   ) ;
  lVrn.Transparency := 60 ;

  lVrn.Params.Render.Expression := 'GIS_AREA' ;
  lVrn.Params.Render.MinVal     := 10000000 ;
  lVrn.Params.Render.MaxVal     := 1300000000 ;
  lVrn.Params.Render.StartColor := TGIS_Color.White ;
  if rdbtnVoronoi.Checked then
    lVrn.Params.Render.EndColor  := TGIS_Color.Red
  else
    lVrn.Params.Render.EndColor := TGIS_Color.Blue ;
  lVrn.Params.Render.Zones      := 10 ;
  lVrn.Params.Area.Color        := TGIS_Color.RenderColor ;
  lVrn.CS := GIS.CS ;

  GIS.Add( lVrn ) ;
  GIS.InvalidateWholeMap ;
  GIS_ControlLegend1.Update ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
