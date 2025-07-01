//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to override OnPaintShapeLabel.
}

unit Unit1;


interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,

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
  GisLayerVector,
  GisLayerSHP,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PaintLabel( _sender : TObject; _shape : TGIS_Shape );
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


procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  // add some layers
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ;
  ll.Name := 'counties' ;
  ll.Params.Labels.Position := [  TGIS_LabelPosition.MiddleCenter,
                                  TGIS_LabelPosition.Flow
                               ] ;

  ll.PaintShapeLabelEvent := PaintLabel ;

  GIS.Add(ll) ;
  GIS.FullExtent ;
end;

procedure TForm1.PaintLabel( _sender : TOBject ;
                             _shape : TGIS_Shape ) ;
begin
  // set label value and draw
  _shape.Layer.Params.Labels.Value := 'My:<BR><B>' +
                                      _shape.GetField('NAME') +  '</B><BR><U>'+
                                      FloatToStr( _shape.GetField('POPULATION' ) ) +
                                      '</U>' ;
  _shape.DrawLabel ;
end;


procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
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
