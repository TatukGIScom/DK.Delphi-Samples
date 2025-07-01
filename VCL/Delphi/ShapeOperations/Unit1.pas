//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to transform a shape geometry.
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  //GisLicense,
  GisTypes,
  GisLayerSHP,
  GisLayerVector,
  GisViewer,
  GisTypesUI,
  GisUtils,
  Vcl.GisViewerWnd, Vcl.ExtCtrls ;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    GIS: TGIS_ViewerWnd;
    lblSelected: TLabel;
    rbRotate: TRadioButton;
    rbScale: TRadioButton;
    rbMove: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GISMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure pgc1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure rbRotateClick(Sender: TObject);
    procedure rbScaleClick(Sender: TObject);
    procedure rbMoveClick(Sender: TObject);
  private
    { Private declarations }
    handleMouseMove : boolean;
    prevPtg  : TGIS_Point;
    prevX    : Integer ;
    prevY    : Integer ;

    edtLayer : TGIS_LayerVector ;

    curShape : TGIS_Shape ;
    edtShape : TGIS_Shape ;

    procedure TransformSelectedShape( shape : TGIS_Shape; xx, yx, xy, yy, dx, dy : Double);
    procedure RotateSelectedShape   ( shape : TGIS_Shape; angle : Double);
    procedure ScaleSelectedShape    ( shape : TGIS_Shape; x_value, y_value : Double);
    procedure TranslateSelectedShape( shape : TGIS_Shape; x_value, y_value : Double);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Math,

  GisFunctions,
  GisRtl ;

procedure TForm1.TransformSelectedShape(shape : TGIS_Shape; xx, yx, xy, yy, dx, dy : Double);
var
  centroid : TGIS_Point;
begin
  if shape = nil then exit ;

  centroid := shape.Centroid;

  // transform
  // x' = x*xx + y*xy + dx
  // y' = x*yx + y*yy + dx
  // z' = z
  shape.Transform( GisPoint3DFrom2D( centroid ),
                   xx, yx, 0,
                   xy, yy, 0,
                    0,  0, 1,
                   dx, dy, 0,
                   False
                  );
  GIS.InvalidateTopmost;
end;

// rotate
procedure TForm1.RotateSelectedShape(shape : TGIS_Shape;angle : Double);
begin
  TransformSelectedShape(
    shape,
     Cos(angle), Sin(angle),
    -Sin(angle), Cos(angle),
             0 ,        0
  );
end;

// scale
procedure TForm1.ScaleSelectedShape(shape : TGIS_Shape;x_value, y_value : Double);
begin
  TransformSelectedShape(
    shape,
     x_value ,        0  ,
           0 ,   y_value ,
           0 ,        0
  );
end;

// translate
procedure TForm1.TranslateSelectedShape(shape : TGIS_Shape;x_value, y_value : Double);
begin
  TransformSelectedShape(
    shape,
         1 ,         0 ,
         0 ,         1 ,
    x_value,   y_value
  );
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  curShape := nil ;
  edtShape := nil ;
  handleMouseMove := False ;
  lblSelected.Caption := 'Select shape on the map to start transform' ;

  GIS.Lock;
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + 'Samples\3D\buildings.shp');

  edtLayer := TGIS_LayerVector.Create ;
  edtLayer.CS :=  GIS.CS ;
  edtLayer.CachedPaint := False ; // make tracking layer
  edtLayer.Params.Area.Pattern := TGIS_BrushStyle.Clear ;
  edtLayer.Params.Area.OutlineColor := TGIS_Color.Red ;
  GIS.Add( edtLayer );
  GIS.Unlock;
  GIS.Zoom := GIS.Zoom * 4 ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg : TGIS_Point ;
begin
  if edtShape = nil then exit ;

  // rotate
  if handleMouseMove then begin

    ptg := GIS.ScreenToMap( Point( X, Y ) ) ;

    if rbRotate.Checked = true then
      RotateSelectedShape(edtShape, DegToRad(X - prevX))
    else if rbScale.Checked = true then begin
      if (prevX <> 0) and (prevY <> 0) then
        ScaleSelectedShape(edtShape, X / prevX , Y / prevY)
    end
    else if rbMove.Checked = true then
      TranslateSelectedShape(edtShape, (ptg.X - prevPtg.X), (ptg.Y - prevPtg.Y) );

    prevPtg.X := ptg.X ;
    prevPtg.Y := ptg.Y ;
    prevX     := X ;
    prevY     := Y ;
  end
end;

procedure TForm1.GISMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp : TGIS_Shape ;
  ptg : TGIS_Point ;
begin
  if GIS.InPaint then exit ;

  lblSelected.Caption := 'No selected shape.Select shape';

  if Assigned(curShape) then
  begin
    curShape.CopyGeometry( edtShape );
    edtLayer.RevertAll ;
    curShape := nil ;
    edtShape := nil ;
    GIS.InvalidateWholeMap ;
    handleMouseMove := false ;
    exit ;
  end;

  // if there is no layer or we are not in select mode, exit
  if GIS.IsEmpty then exit ;
  if GIS.Mode <> TGIS_ViewerMode.Select then exit ;

  ptg := GIS.ScreenToMap( Point( X, Y ) ) ;
  // let's try to locate a selected shape on the map
  shp := TGIS_Shape( GIS.Locate( ptg, 5 / GIS.Zoom ) ) ;
  if not Assigned( shp ) then exit ;


  curShape := shp.MakeEditable ;

  edtShape := edtLayer.AddShape( curShape.CreateCopy ) ;

  lblSelected.Caption := Format( 'Selected shape : %d. Click to commit changes.',
                                 [curShape.Uid]
                                ) ;
  prevPtg.X := ptg.X;
  prevPtg.Y := ptg.Y;
  prevX     := X ;
  prevY     := Y ;

  handleMouseMove := not handleMouseMove;
end;

procedure TForm1.GISMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
begin
  if GIS.IsEmpty then exit ;

  pt := GIS.ScreenToClient( MousePos ) ;

  GIS.ZoomBy( 9/8, pt.X, pt.Y );

  Handled := True ;
end;

procedure TForm1.GISMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  pt : TPoint ;
begin
  if GIS.IsEmpty then exit ;

  pt := GIS.ScreenToClient( MousePos ) ;

  GIS.ZoomBy( 8/9, pt.X, pt.Y );

  Handled := True ;
end;

procedure TForm1.pgc1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  handleMouseMove := False;
end;

procedure TForm1.rbMoveClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start moving' ;

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost ;
    curShape := nil ;
    handleMouseMove := false ;
    exit ;
  end;
end;

procedure TForm1.rbRotateClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start rotationg' ;

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost ;
    curShape := nil ;
    handleMouseMove := false ;
    exit ;
  end;
end;

procedure TForm1.rbScaleClick(Sender: TObject);
begin
  lblSelected.Caption := 'Select shape to start scaling' ;

  if Assigned(curShape) then
  begin
    GIS.InvalidateTopmost ;
    curShape := nil ;
    handleMouseMove := false ;
    exit ;
  end;
end;

end.

