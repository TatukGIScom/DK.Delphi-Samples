//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to show map hints : data fields from shape file
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
  Vcl.ImgList,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayer,
  GisLayerShp,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    btnHints: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnHintsClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    hintField   : String;
    hintLayer   : String;
    hintDisplay : Boolean;
    hintColor   : TColor;
    hintColorStd: TColor;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  frmHint;

{$R *.DFM}


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  hintDisplay := true;
  hintColor   := clYellow;
  hintField   := 'PPPTNAME';
  hintLayer   := 'city1';
  hintColorStd:= Application.HintColor;
  Application.ShowHint := true;           //definitions for hints
  Application.HintPause := 50;            //default : 500
  Application.HintShortPause := 50;       //default : 50
  Application.HintHidePause := 2000;      //default : 2500
  Application.HintColor := hintColor;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
end;

procedure TfrmMain.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent;
end;

procedure TfrmMain.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TfrmMain.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

// Show Hints properties window
procedure TfrmMain.btnHintsClick(Sender: TObject);
begin
  if frmHints.ShowModal = mrCancel then exit ;

  hintDisplay := frmHints.chkShow.Checked;
  hintColor   := frmHints.paColor.Color;
  hintField   := frmHints.lbFields.Items[frmHints.lbFields.ItemIndex];
  hintLayer   := frmHints.cbLayers.Items[frmHints.cbLayers.ItemIndex];
end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
  shp : TGIS_Shape ;
  str : String;
  la  : TGIS_Layer ;
  lv  : TGIS_LayerVector   ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  la := TGIS_Layer(GIS.Get( hintLayer )) ;

  if la = nil then exit ;
  if not (la is TGIS_LayerVector ) then exit ;

  lv := la as TGIS_LayerVector ;

  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( lv.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision

  if shp = nil then
  begin
    GIS.Hint := '';
    GIS.ShowHint := false;
  end
  else if hintDisplay then
  begin
    Application.HintColor := hintColor;
    str := shp.GetField(hintField);
    GIS.Hint := str;
    GIS.ShowHint := true;
    Application.ActivateHint( ClientToScreen( Point(X + 10,Y - 10) ) );
    str := Format( 'x: %.4f   y: %.4f', [ptg.X, ptg.Y] ) ;
    StatusBar1.SimpleText := str;
  end;
end;

procedure TfrmMain.ToolBar1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Application.HintColor := hintColorStd;
end;

end.
