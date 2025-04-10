//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to measure length and area of the shape.
}
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
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,

  //GisLicense,
  GisTypes,
  GisTypesUI,
  GisAllLayers,
  GisCSBase,
  GisLayer,
  GisLayerVector,
  GisUtils,

  FMX.GisViewerWnd ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    edtArea: TEdit;
    edtLength: TEdit;
    ToolBar1: TToolBar;
    btnMeasureLine: TSpeedButton;
    btnMeasurePol: TSpeedButton;
    Panel1: TPanel;
    lblLength: TLabel;
    lblArea: TLabel;
    btnClear: TSpeedButton;
    btnMetrical: TButton;
    btnImperial: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnMeasureLineClick(Sender: TObject);
    procedure btnMeasurePolClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure GISEditorChangeEvent(Sender: TObject);
    procedure btnMetricalClick(Sender: TObject);
    procedure btnImperialClick(Sender: TObject);
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    layer     : TGIS_LayerVector ;
    isLine    : Boolean ;
    isPolygon : Boolean ;
    unitMsr   : TGIS_CSUnits ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses System.IOUtils  ;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.btnMeasureLineClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  isPolygon := False ;
  isLine := True ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TForm1.btnMeasurePolClick(Sender: TObject);
begin
  GIS.Editor.DeleteShape;
  GIS.Editor.EndEdit ;
  edtArea.Text := '' ;
  edtLength.Text := '' ;
  isPolygon := True ;
  isLine := False ;
  GIS.Mode := TGIS_ViewerMode.Select ;
end;

procedure TForm1.btnMetricalClick(Sender: TObject);
begin
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904201 );
  GISEditorChangeEvent(Self);
end;

procedure TForm1.btnImperialClick(Sender: TObject);
begin
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904202 );
  GISEditorChangeEvent(Self);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  str : String ;
begin
  str := '' ;
  {$IF Defined(WIN32) or Defined(WIN64)}
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\WorldDCW\world.shp' );
  {$ELSEIF Defined(MACOS) and not Defined(IOS) }
    str := TDirectory.GetParent( TDirectory.GetParent( ParamStr(0) ) ) ;
    GIS.Open( str + '/Data/world.shp' );
  {$ELSEIF Defined(MACOS) and Defined(IOS)}
    GIS.Open( TPath.GetDocumentsPath + PathDelim + 'world.shp' ) ;
  {$ELSE ANDROID}
    GIS.Open( TPath.GetDocumentsPath + PathDelim + 'world.shp' ) ;
  {$ENDIF}
  GIS.Mode := TGIS_ViewerMode.Drag;
  layer := TGIS_LayerVector.Create ;
  layer.Params.Line.Color := TGIS_Color.Red ;
  layer.Params.Line.Width := 25 ;
  layer.SetCSByEPSG( 4326 ) ;
  if not Assigned( layer ) then
    exit ;
  GIS.Add( layer ) ;
  GIS.RestrictedExtent := GIS.Extent ;
  isLine := False ;
  isPolygon := False ;
  unitMsr := TGIS_Utils.CSUnitsList.ByEPSG( 904201 ) ;
  GIS.Editor.EditingLinesStyle.PenWidth := 10 ;
end;


procedure TForm1.GISEditorChangeEvent(Sender: TObject);
begin
  if Assigned( GIS.Editor.CurrentShape ) then
    if isLine then
      edtLength.Text := unitMsr.asLinear( TGIS_Shape( GIS.Editor.CurrentShape ).LengthCS, True )
    else if isPolygon then
    begin
      edtLength.Text := unitMsr.asLinear( TGIS_Shape( GIS.Editor.CurrentShape ).LengthCS, True ) ;
      edtArea.Text := unitMsr.AsAreal( TGIS_Shape( GIS.Editor.CurrentShape ).AreaCS, True, '%s²' ) ;
    end
end;

procedure TForm1.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  ptg : TGIS_Point;
begin
  if GIS.Mode = TGIS_ViewerMode.Edit then
    exit ;
  ptg := GIS.ScreenToMap( Point( Round(x), Round(y) ) ) ;
  if isLine then
  begin
    GIS.Editor.CreateShape( layer, ptg, TGIS_ShapeType.Arc ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;
  end
  else if isPolygon then
  begin
    GIS.Editor.CreateShape( layer, ptg, TGIS_ShapeType.Polygon ) ;
    GIS.Mode := TGIS_ViewerMode.Edit ;
  end ;
end;

end.
