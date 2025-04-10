unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Controls.Presentation,

  //GisLicense,
  FMX.GisViewerWnd,
  GisUtils,
  GisTypes,
  GisTypesUI,
  GisViewer,
  GisLayerVector ;

type
  TForm3 = class(TForm)
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    GIS: TGIS_ViewerWnd;
    btnFullExtent: TButton;
    btnZoom: TButton;
    btnDrag: TButton;
    Label1: TLabel;
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure GISMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}

procedure TForm3.FormCreate(Sender: TObject);
begin
  GIS.Open(  TGIS_Utils.GisSamplesDataDirDownload() +
             'World\Countries\Poland\DCW\poland.ttkproject');
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;

procedure TForm3.GISMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
var
  pt : TPointF ;
begin
  if GIS.IsEmpty then exit ;

  // a trick how to obtain mouse position, which is not provided in
  // FMX MouseWheel event, ralative to GIS control.
  pt := GIS.AbsoluteToLocal( GIS.Scene.ScreenToLocal( Screen.MousePos ) ) ;

  if WheelDelta > 0 then
    GIS.ZoomBy( 4/5, Round(pt.X), Round(pt.Y) )
  else
    GIS.ZoomBy( 5/4, Round(pt.X), Round(pt.Y) ) ;
  Handled := True ;
end;

procedure TForm3.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm3.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;

procedure TForm3.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

end.
