//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform Circle/Rectangle buffer operation.
}

unit Unit1;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.Buttons,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,
  GisClasses,
  GisCSBase,

  Vcl.GisViewerWnd, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    GIS         : TGIS_ViewerWnd  ;
    StatusBar1  : TStatusBar      ;
    ToolBar1    : TToolBar        ;
    btnClear    : TButton         ;
    btnPolygon  : TButton         ;
    btnLine     : TButton         ;
    Panel1      : TPanel          ;
    lblLength   : TLabel          ;
    lblArea     : TLabel          ;
    edtLength   : TEdit           ;
    edtArea     : TEdit           ;

    procedure FormCreate(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnPolygonClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure GISEditorChangeEvent(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    ll        : TGIS_LayerVector  ;
    isLine    : Boolean           ;
    isPolygon : Boolean           ;
    units     : TGIS_CSUnits      ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisAllLayers ;

{$R *.DFM}


procedure TForm1.btnClearClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  edtArea.Text := '';
  edtLength.Text := '';

  GIS.Mode := TGIS_ViewerMode.Drag;
end;

procedure TForm1.btnLineClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  edtArea.Text := '';
  edtLength.Text := '';

  isPolygon := False;
  isLine := True;

  GIS.Mode := TGIS_ViewerMode.Select;
end;

procedure TForm1.btnPolygonClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit;

  edtArea.Text := '';
  edtLength.Text := '';

  isPolygon := True;
  isLine := False;

  GIS.Mode := TGIS_ViewerMode.Select;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock();
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\WorldDCW\world.shp');

  ll := TGIS_LayerVector.create;
  ll.Params.Line.Color := TGIS_Color.Red;
  ll.Params.Line.Width := 25;
  ll.SetCSByEPSG( 4326 );

  GIS.Add(ll);
  GIS.RestrictedExtent := GIS.Extent;

  GIS.Unlock();

  units := TGIS_Utils.CSUnitsList.ByEPSG( 904201 );

  isLine := False;
  isPolygon := False;

  GIS.Editor.EditingLinesStyle.PenWidth := 10;
  GIS.Editor.Mode := TGIS_EditorMode.AfterActivePoint;
end;


procedure TForm1.GISEditorChangeEvent(Sender: TObject);
begin
  if Assigned(GIS.Editor.CurrentShape) then
  begin
    if isLine then
    begin
      edtLength.Text := units.AsLinear(TGIS_Shape(GIS.Editor.CurrentShape).LengthCS, True)
    end
    else if isPolygon then
    begin
      edtLength.Text := units.AsLinear(TGIS_Shape(GIS.Editor.CurrentShape).LengthCS, True) ;
      edtArea.Text := units.AsAreal( TGIS_Shape( GIS.Editor.CurrentShape ).AreaCS, True, '%s²' ) ;
    end;
  end;

end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if GIS.Mode = TGIS_ViewerMode.Edit then
    exit ;
  ptg := GIS.ScreenToMap( Point( x, y ) ) ;
  if isLine then
  begin
    GIS.Editor.CreateShape( ll, ptg, TGIS_ShapeType.Arc ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;
  end
  else if isPolygon then
  begin
    GIS.Editor.CreateShape( ll, ptg, TGIS_ShapeType.Polygon ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;
  end ;
end;

end.
