//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to add layers to the map.
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
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisUtils,
  GisTypesUI,
  GisViewer,

  Vcl.GisViewerWnd, System.ImageList;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Toolbar1: TToolBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton4: TToolButton;
    chkDrag: TCheckBox;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure chkDragClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
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
  GisRegistredLayers ;

procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\country.shp' ;
  ll.Name := 'country' ;
  ll.Params.Area.Color := TGIS_Color.LightGray ;
  GIS.Add(ll) ;

  // add rivers layer, set line params
  ll := TGIS_LayerSHP( GisCreateLayer( 'rivers',
                                       TGIS_Utils.GisSamplesDataDirDownload +
                                       '\World\Countries\Poland\DCW\lwaters.shp'
                                      )
                       ) ;
  ll.UseConfig := False ;
  ll.Params.Line.OutlineWidth := 0 ;
  ll.Params.Line.Width := 3 ;
  ll.Params.Line.Color := TGIS_Color.Blue ;
  GIS.Add(ll) ;
  GIS.FullExtent ;
end;

procedure TForm1.chkDragClick(Sender: TObject);
begin
  // change viewer mode
  if chkDrag.Checked then begin
     GIS.Mode := TGIS_ViewerMode.Drag ;
  end else begin
     GIS.Mode := TGIS_ViewerMode.Select ;
  end
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
   // change viewer zoom
   GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
   // change viewer zoom
   GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
