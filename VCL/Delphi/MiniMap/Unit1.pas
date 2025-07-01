//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to build minimap.
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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisEditor,
  GisLayerShp,
  GisLayerVector,
  GisRegistredLayers,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

const
  MINIMAP_R_NAME = 'minimap_rect';
  MINIMAP_O_NAME = 'minimap_rect_outline';

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    paLeft: TPanel;
    GISm: TGIS_ViewerWnd;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    gbCanvasInfo: TGroupBox;
    lbP1: TLabel;
    lbP2: TLabel;
    lbP3: TLabel;
    lbP4: TLabel;
    GIS: TGIS_ViewerWnd;
    PopupMenu1: TPopupMenu;
    Rectcolor1: TMenuItem;
    Outlinecolor1: TMenuItem;
    colorR: TMenuItem;
    colorO: TMenuItem;
    dlgColor: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnZoomClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure GISVisibleExtentChange(Sender: TObject);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISmMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISmMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GISmMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure colorRClick(Sender: TObject);
    procedure colorOClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    minishp         : TGIS_Shape ;              //minimap shape
    minishpo        : TGIS_Shape ;              //minimap shape outline
    fminiMove       : Boolean;                  //flag for move mini rectangle
    lP1,lP2,lP3,lP4 : TGIS_Point;               //large map extent points
    procedure miniMapRefresh(Sender: TObject);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}


procedure TfrmMain.FormCreate(Sender: TObject);
var
  llm : TGIS_LayerVector ;
  lv  : TGIS_LayerVector ;
  lw  : TGIS_LayerVector ;
begin

  GIS.Lock;
  GISm.Lock;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;

  GIS.SetCSByEPSG( 2180 );

  llm := TGIS_LayerVector(
           GisCreateLayer(
             'country',
             TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\country.shp'
           )
         ) ;
  llm.UseConfig := False ;
  llm.Params.Area.Color := TGIS_Color.White ;
  llm.Params.Area.OutlineColor := TGIS_Color.Silver ;
  GISm.Add(llm);                                //add to minimap
  llm.CachedPaint := False ;

  lv := TGIS_LayerVector.Create ;               //minimap transparent rectangle
  lv.Transparency := 30;
  lv.Params.Area.Color := TGIS_Color.Red;
  lv.Params.Area.OutlineWidth := -2;
  lv.Name := MINIMAP_R_NAME;
  lv.CS := llm.CS ;
  GISm.Add(lv);
  lv.CachedPaint := False ;

  minishp := TGIS_LayerVector( GISm.Get(MINIMAP_R_NAME) ).CreateShape( TGIS_ShapeType.Polygon );
  lw := TGIS_LayerVector.Create;
  lw.Params.Line.Color := TGIS_Color.Maroon;
  lw.Params.Line.Width := -2;
  lw.Name := MINIMAP_O_NAME;
  lw.CS := llm.CS ;
  GISm.Add(lw);
  minishpo := TGIS_LayerVector( GISm.Get(MINIMAP_O_NAME) ).CreateShape( TGIS_ShapeType.Arc );
  lw.CachedPaint := False ;

  GIS.Unlock;
  GISm.Unlock;

  GISm.FullExtent;
  GIS.FullExtent ;

  GISm.RestrictedExtent := GISm.Extent;
  minishp.Layer.Extent := GISm.Extent;
  GISm.Cursor := crDrag;
  fminiMove := false;

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

procedure TfrmMain.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;

procedure TfrmMain.btnSelectClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select;
end;

procedure TfrmMain.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

procedure TfrmMain.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;

  ptg := GIS.ScreenToMap( Point(x, y ) );
  StatusBar1.SimpleText := Format( 'x: %.2f   y: %.2f', [ptg.X, ptg.Y] ) ;
end;

procedure TfrmMain.miniMapRefresh(Sender: TObject);
var
  ptg1 : TGIS_Point ;
  ptg2 : TGIS_Point ;
  ptg3 : TGIS_Point ;
  ptg4 : TGIS_Point ;
  ex   : TGIS_Extent;
begin
  if GIS.IsEmpty then exit;

  ex := GISm.CS.ExtentFromCS( GIS.CS, GIS.VisibleExtent ) ;
  ex := GIS.UnrotatedExtent( ex ) ;

  if ( ex.XMin < -360 ) and
     ( ex.XMax > 360 )  and
     ( ex.YMin < -180 )  and
     ( ex.YMax > 180 )
  then exit ;

  ptg1 := TGIS_Utils.GisPoint( ex.XMin, ex.YMin ) ;
  ptg2 := TGIS_Utils.GisPoint( ex.XMax, ex.YMin ) ;
  ptg3 := TGIS_Utils.GisPoint( ex.XMax, ex.YMax );
  ptg4 := TGIS_Utils.GisPoint( ex.XMin, ex.YMax );
  if Assigned( minishp ) then begin
    minishp.Reset;
    minishp.Lock( TGIS_Lock.Extent ) ;
    minishp.AddPart ;
    minishp.AddPoint( ptg1 );
    minishp.AddPoint( ptg2 );
    minishp.AddPoint( ptg3 );
    minishp.AddPoint( ptg4 );
    minishp.Unlock ;
  end;

  if Assigned( minishpo ) then begin
    minishpo.Reset;
    minishp.Lock( TGIS_Lock.Extent ) ;
    minishpo.AddPart ;
    minishpo.AddPoint( ptg1 );
    minishpo.AddPoint( ptg2 );
    minishpo.AddPoint( ptg3 );
    minishpo.AddPoint( ptg4 );
    minishpo.AddPoint( ptg1 );
    minishpo.Unlock ;
  end;


  GISm.InvalidateWholeMap ;
end;

procedure TfrmMain.GISVisibleExtentChange(Sender: TObject);
var
  ex : TGIS_Extent;
begin
  ex := GIS.VisibleExtent;
  lP1 := TGIS_Utils.GisPoint( ex.XMin, ex.YMin ) ;
  lP2 := TGIS_Utils.GisPoint( ex.XMax, ex.YMin ) ;
  lP3 := TGIS_Utils.GisPoint( ex.XMax, ex.YMax );
  lP4 := TGIS_Utils.GisPoint( ex.XMin, ex.YMax );
  lbP1.Caption := Format( 'P1 : x: %.2f   y: %.2f', [ lP1.X, lP1.Y] ) ;
  lbP2.Caption := Format( 'P2 : x: %.2f   y: %.2f', [ lP2.X, lP2.Y] ) ;
  lbP3.Caption := Format( 'P3 : x: %.2f   y: %.2f', [ lP3.X, lP3.Y] ) ;
  lbP4.Caption := Format( 'P4 : x: %.2f   y: %.2f', [ lP4.X, lP4.Y] ) ;
  miniMapRefresh(self);
end;

procedure TfrmMain.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  miniMapRefresh(self);
end;

procedure TfrmMain.GISmMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
  p1,p2,p3,p4 : TGIS_Point;
begin
  if GIS.IsEmpty then exit ;

  if not fminiMove then exit ;

  ptg := GISm.ScreenToMap( Point( X, Y ) );

  minishp.SetPosition( ptg, nil, 1 );

  GISm.InvalidateWholeMap ;
  fminiMove := false;

  p1 := minishp.GetPoint(0,0);
  p2 := minishp.GetPoint(0,1);
  p3 := minishp.GetPoint(0,2);
  p4.X := p1.X + (p2.X - p1.X)/2;
  p4.Y := p1.Y + (p3.Y - p2.Y)/2;
  GIS.Center := GISm.CS.ToCS( GIS.CS, p4 ) ;
end;

procedure TfrmMain.GISmMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg   : TGIS_Point ;
begin
  if GIS.IsEmpty then exit ;

  if ( (not fminiMove) and (not (ssCtrl in Shift)) ) then exit;
  ptg := GISm.ScreenToMap( Point( X, Y ) );
  minishp.SetPosition( ptg, nil, 1 );

  if ( ssShift in Shift ) then begin
    fminiMove := True ;
    GISmMouseUp( Sender, TMouseButton(0), Shift, X,Y );
  end ;
end;

procedure TfrmMain.GISmMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  if (Button = mbRight) then exit;
  fminiMove := true;
end;

procedure TfrmMain.colorRClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  if not dlgColor.Execute then exit;
  lv := TGIS_LayerVector( GISm.Get(MINIMAP_R_NAME) );
  lv.Params.Area.Color := TGIS_Color.FromBGR(dlgColor.Color);
  GISm.InvalidateWholeMap ;
end;

procedure TfrmMain.colorOClick(Sender: TObject);
var
  lv  : TGIS_LayerVector ;
begin
  if not dlgColor.Execute then exit;
  lv := TGIS_LayerVector( GISm.Get(MINIMAP_O_NAME) );
  lv.Params.Line.Color := TGIS_Color.FromBGR(dlgColor.Color);
  GISm.InvalidateWholeMap ;
end;

end.
