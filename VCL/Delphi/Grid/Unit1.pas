//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to manipulate grid layer presentation
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,

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
  GisAllLayers,
  GisEditor,
  GisLayerPixel,
  GisLayerSHP,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

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
    btnClear: TButton;
    btnUserDefined: TButton;
    btnReloadIni: TButton;
    btnShadow: TButton;
    btnUserIni: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnUserDefinedClick(Sender: TObject);
    procedure btnReloadIniClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnShadowClick(Sender: TObject);
    procedure btnUserIniClick(Sender: TObject);
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
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload +
            '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf'
          ) ;
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

procedure TForm1.btnClearClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  ll.Params.Pixel.AltitudeMapZones.Clear ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnUserDefinedClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  ll.Params.Pixel.AltitudeMapZones.Clear ;
  ll.Params.Pixel.AltitudeMapZones.Add( '200,  400 , OLIVE , VERY LOW') ;
  ll.Params.Pixel.AltitudeMapZones.Add( '400,  700 , OLIVE , LOW'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '700,  900 , GREEN , MID'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '900,  1200, BLUE  , HIGH'    ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '1200, 1700, RED   , SKY'     ) ;
  ll.Params.Pixel.AltitudeMapZones.Add( '1700, 2200, YELLOW, HEAVEN'  ) ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnReloadIniClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  ll.ConfigName := TGIS_Utils.GisSamplesDataDirDownload +
                   '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf' ;
  ll.RereadConfig ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnShadowClick(Sender: TObject);
var
  ll : TGIS_LayerPixel  ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  ll.Params.Pixel.GridShadow := not ll.Params.Pixel.GridShadow ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.btnUserIniClick(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;
  ll.ConfigName := TGIS_Utils.GisSamplesDataDirDownload +
                   '\Samples\Projects\dem_ned.ini' ;
  ll.RereadConfig ;
  GIS.InvalidateWholeMap ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg     : TGIS_Point       ;
  ll      : TGIS_LayerPixel  ;
  rgb     : TGIS_Color     ;
  natives : TGIS_DoubleArray ;
  transp  : Boolean          ;
begin
  if GIS.InPaint then exit ;

  ptg := GIS.ScreenToMap( Point( X, Y ) ) ;
  ll := TGIS_LayerPixel( GIS.Items[ 0 ] ) ;

  if ll.Locate( ptg, rgb, natives, transp ) then
    StatusBar1.Panels[1].Text := FloatToStr( natives[0] )
  else
    StatusBar1.Panels[1].Text := 'Unknown' ;
end;

end.
