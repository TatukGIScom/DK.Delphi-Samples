// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
{
  How to support synchronized, two-windows display.
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
  Vcl.StdCtrls,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisAllLayers,
  GisEditor,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisRendererDirect2D,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS_ViewerWnd1: TGIS_ViewerWnd;
    GIS_ViewerWnd2: TGIS_ViewerWnd;
    ToolBar1: TToolBar;
    Splitter1: TSplitter;
    Button1: TButton;
    CheckBox1: TCheckBox;
    ToolButton1: TToolButton;
    procedure Button1Click(Sender: TObject);
    procedure GIS_ViewerWnd2VisibleExtentChangeEvent(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GIS_ViewerWnd1ExtentChangeEvent(Sender: TObject);
  private
    bSentinel : Boolean ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  bSentinel := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // open the same project for two viewers
  GIS_ViewerWnd1.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  GIS_ViewerWnd1.Zoom := GIS_ViewerWnd1.Zoom * 3 ;
  GIS_ViewerWnd1.Mode := TGIS_ViewerMode.Zoom  ;

  GIS_ViewerWnd2.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  GIS_ViewerWnd2.Zoom := GIS_ViewerWnd2.Zoom * 4 ;
  GIS_ViewerWnd2.Mode := TGIS_ViewerMode.Zoom  ;
end;

procedure TForm1.GIS_ViewerWnd2VisibleExtentChangeEvent(Sender: TObject);
begin
  if bSentinel then // avoid circular calls
    exit ;
  bSentinel := True ;

  GIS_ViewerWnd1.Lock;

  GIS_ViewerWnd1.Center := GIS_ViewerWnd2.Center ;

  if checkBox1.Checked then
    GIS_ViewerWnd1.Zoom  := GIS_ViewerWnd2.Zoom;

  GIS_ViewerWnd1.Unlock;

  bSentinel := False;
end;

procedure TForm1.GIS_ViewerWnd1ExtentChangeEvent(Sender: TObject);
begin
  if bSentinel then // avoid circular calls
    exit ;
  bSentinel := True ;

  // synchronize two viewers
  GIS_ViewerWnd2.Lock;

  GIS_ViewerWnd2.Center := GIS_ViewerWnd1.Center ;

  if checkBox1.Checked then
    GIS_ViewerWnd2.Zoom  := GIS_ViewerWnd1.Zoom;

  GIS_ViewerWnd2.Unlock;

  bSentinel := False;
end;

end.
