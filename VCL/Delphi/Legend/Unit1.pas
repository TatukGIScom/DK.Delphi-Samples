//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide Legend control
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
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisLegend,

  Vcl.GisControlLegend,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    ToolButton2: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    ToolButton1: TToolButton;
    Splitter1: TSplitter;
    GIS_ControlLegend1: TGIS_ControlLegend;
    SpeedButton1: TSpeedButton;
    TabControl1: TTabControl;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GISAfterPaint(_sender, _canvas: TObject);
    procedure TabControl1Change(Sender: TObject);
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
begin
  // open a file
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  // show full map
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // set zoom mode
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.btnDragClick(Sender: TObject);
begin
  // set drag mode
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if GIS.IsEmpty then exit ;

  // save the project
  GIS.SaveAll ;
end;

procedure TForm1.GISAfterPaint(_sender, _canvas: TObject);
begin
  StatusBar1.Panels[1].Text := GIS.ScaleAsText ;
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  if TabControl1.TabIndex = 0 then
    GIS_ControlLegend1.Mode := TGIS_ControlLegendMode.Layers
  else
    GIS_ControlLegend1.Mode := TGIS_ControlLegendMode.Groups ;
end;

end.
