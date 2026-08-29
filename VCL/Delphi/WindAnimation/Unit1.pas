{
  Provides the wind engine and particle system for rendering animated wind maps.
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  VCL.GisViewerWnd,
  GisTypesUI ;

type
  TFormMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  GisFunctions,
  GISLayerWind,
  GisLayerJPG,
  GisUtils ;

procedure TFormMain.FormShow(Sender: TObject);
var
  lv : TGIS_LayerWind ;
begin
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg') ;

  lv := TGIS_LayerWind.Create ;
  lv.Path := 'wind-global.json' ;
  lv.CachedPaint := False ;
  GIS.Add( lv ) ;
  GIS.FullExtent ;
  Timer1.Enabled := True ;
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  GIS.InvalidateTopmost ;
end;

end.
