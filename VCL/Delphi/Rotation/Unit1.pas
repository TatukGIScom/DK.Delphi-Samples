//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to rotate the map.
  Main form
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
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes,
  Vcl.GisControlLegend,
  Vcl.GisViewerWnd,
  VCL.GisControlNorthArrow;

type
  TForm1 = class (TForm)
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    Button1: TButton;
    GIS: TGIS_ViewerWnd;
    ImageList1: TImageList;
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    CheckBox1: TCheckBox;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    decreaseBtn: TButton;
    rotationTB: TTrackBar;
    increaseBtn: TButton;
    degLabel: TLabel;
    GIS_ControlNorthArrow1: TGIS_ControlNorthArrow;
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton; Shift:
                           TShiftState; X, Y: Integer);
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btnFullExtentClick(Sender: TObject);
    procedure decreaseBtnClick(Sender: TObject);
    procedure increaseBtnClick(Sender: TObject);
    procedure rotationTBChange(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  rotationTB.Position := 0;
end;

procedure TForm1.decreaseBtnClick(Sender: TObject);
begin
  rotationTB.Position := rotationTB.Position - 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // clear rotation angle
  GIS.RotationAngle := 0 ;

  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;

  // show layers in the viewer and set a rotation point in central point of extent
  GIS.FullExtent ;
  GIS.Zoom := GIS.Zoom * 2  ;
  GIS.RotationPoint := TGIS_Utils.GisCenterPoint( GIS.Extent ) ;
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
begin
  if GIS.IsEmpty then exit ;

  // if clicked change a rotation point and move viewport
  GIS.RotationPoint := GIS.ScreenToMap( Point( X, Y ) );

  if CheckBox1.Checked then
    GIS.Center := GIS.ScreenToMap( Point( X, Y ) );
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X, Y:
        Integer);
var
  ptg: TGIS_Point;
  shp: TGIS_Shape;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  // show coordinates
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 picels precision

  if shp = nil then
     StatusBar.Panels[1].Text := ''
  else
     StatusBar.Panels[1].Text := shp.GetField('name');
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.RecalcExtent ;
  GIS.FullExtent ;
end;

procedure TForm1.increaseBtnClick(Sender: TObject);
begin
  rotationTB.Position := rotationTB.Position + 1;
end;

procedure TForm1.rotationTBChange(Sender: TObject);
begin
  GIS.RotationAngle := DegToRad(rotationTB.Position);
  GIS.InvalidateWholeMap;
  degLabel.Caption := 'Degree: ' + IntToStr ( rotationTB.Position ) ;
end;

end.
