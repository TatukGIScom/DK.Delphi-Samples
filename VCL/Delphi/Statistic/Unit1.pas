//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provided simple statistical analyzes by overriding OnSPaintShape event.
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
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisParams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ComboLabels: TComboBox;
    ComboStatistic: TComboBox;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure ButtonZoomOutClick(Sender: TObject);
    procedure PaintShape( _sender : TOBject; _shape : TGIS_Shape );
    procedure ComboLabelsChange(Sender: TObject);
  private
    { Private declarations }
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
  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ;
  ll.Name := 'counties' ;

  // set custom paint procedure
  ll.PaintShapeEvent := PaintShape ;
  GIS.Add(ll) ;
  GIS.FullExtent ;

  ComboStatistic.ItemIndex := 0 ;
  ComboLabels.ItemIndex := 0 ;
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

procedure TForm1.PaintShape( _sender : TOBject; _shape : TGIS_Shape );
var
  population : double ;
  area       : double ;
  factor     : double ;
begin
  // calculate factors
  population := StrToFloat( _shape.GetField( 'population' ) ) ;
  area       := StrToFloat( _shape.GetField( 'area' ) ) ;

  if ComboStatistic.itemIndex = 1 then
  begin
    factor := area ;

    // assign different bitmaps for factor value
    if      factor <     40 then _shape.Params.Area.Color := TGIS_Color.FromRGB($0000F00C)
    else if factor <    130 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00AEFFB3)
    else if factor <    480 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00CCCCFF)
    else if factor <   2000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($003535FF)
    else if factor <  10000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($000000B3)
    else                         _shape.Params.Area.Color := TGIS_Color.FromRGB($003000B3) ;
  end
  else
  begin
    factor := population ;

    // assign different bitmaps for factor value
    if      factor <   5000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($0000F00C)
    else if factor <  22000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00AEFFB3)
    else if factor < 104000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00CCCCFF)
    else if factor < 478000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($003535FF)
    else if factor <2186000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($000000B3)
    else                         _shape.Params.Area.Color := TGIS_Color.FromRGB($003000B3) ;
  end;

  _shape.Draw;
end;

procedure TForm1.ComboLabelsChange(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  ll := TGIS_LayerVector( Gis.Get( 'counties' ) ) ;

  // change labels values
  if ll <> nil then
  begin
    case ComboLabels.ItemIndex of
      1 : ll.Params.Labels.Field := 'CNTYIDFP' ;
      2 : ll.Params.Labels.Field := 'NAME' ;
    else  ll.Params.Labels.Field := '' ;
    end ;
  end ;
  GIS.InvalidateWholeMap ;
end;

end.
