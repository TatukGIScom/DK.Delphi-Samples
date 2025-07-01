//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide WFS Layer support.
}
unit formMain;

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
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.ImgList,
  GisViewer,
  GisTypesUI,
  Vcl.GisViewerWnd,
  Vcl.GisControlLegend;

type
  TfrmMain = class(TForm)
    GIS_ControlLegend1: TGIS_ControlLegend;
    GIS: TGIS_ViewerWnd;
    tlb1: TToolBar;
    stat1: TStatusBar;
    il1: TImageList;
    btn2: TToolButton;
    btn3: TToolButton;
    btn4: TToolButton;
    btn5: TToolButton;
    btn9: TToolButton;
    btn10: TToolButton;
    btn1: TToolButton;
    procedure btn10Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AppendCoverage( const _path : String ) ;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  //GisLicense,
  GisFunctions,
  GisTypes,
  GisLayerWFS,
  GisLayer,
  GisRtl,
  GisRegistredLayers,
  formWFS;

procedure TfrmMain.AppendCoverage(const _path: String);
var
  ll : TGIS_Layer;
begin
  try
    // create a new layer
    ll := GisCreateLayer(ExtractFileName(_path),_path);
    // and add it to the viewer
    if Assigned (ll) then begin
      ll.ReadConfig;
      try
        GIS.Add(ll);
      except
        FreeObject( ll );
      end;
    end;

    GIS_ControlLegend1.GIS_Layer := ll ;

    if GIS.Items.Count = 1 then
      GIS.FullExtent
    else
      GIS.InvalidateWholeMap ;
  except
    on E : Exception do
      ShowMessage( 'File can''t be open'#13 + E.Message ) ;
  end ;
end;

procedure TfrmMain.btn10Click(Sender: TObject);
begin
  frmWFS.Show ;
end;

procedure TfrmMain.btn2Click(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TfrmMain.btn3Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TfrmMain.btn4Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TfrmMain.btn5Click(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TfrmMain.btn9Click(Sender: TObject);
begin
  GIS.Close ;
end;

end.
