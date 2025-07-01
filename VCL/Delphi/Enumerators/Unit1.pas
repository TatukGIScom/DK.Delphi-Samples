//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to use enumerators.
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
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  //GisLicense,
  GisRegistredLayers,
  GisTypesUI,
  GisUtils,
  GisViewer,
  VCL.GisViewerWnd ;



type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Toolbar1: TToolBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    chkDrag: TCheckBox;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    btnEnumerate: TToolButton;
    ToolButton4: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure chkDragClick(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnEnumerateClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // add states layer
  GIS.Add(
    GisCreateLayer(
      'world',
      TGIS_Utils.GisSamplesDataDirDownload +
      '\World\Countries\USA\States\California\tl_2008_06_county.shp'
    )
  )  ;

  GIS.FullExtent ;
end;

procedure TForm1.chkDragClick(Sender: TObject);
begin
  // change viewer mode
  if chkDrag.Checked then
  begin
    GIS.Mode := TGIS_ViewerMode.Drag ;
  end
  else begin
    GIS.Mode := TGIS_ViewerMode.Select ;
  end
end;

procedure TForm1.btnEnumerateClick(Sender: TObject);
var
  shp         : TGIS_Shape ;
  cnt         : Integer ;
  max_cnt     : Integer ;
  lv          : TGIS_LayerVector ;
  tmpshp      : TGIS_Shape ;
  shpNbr      : TGIS_Shape ;
begin
  max_cnt := 0 ;

  lv := TGIS_LayerVector( GIS.Items[ 0 ] ) ;


  if lv.FindField( 'COUNT' ) < 0 then
    lv.AddField( 'COUNT', TGIS_FieldType.Number, 10, 0 );

  GIS.HourglassPrepare;

  try

    // mark all shapes that can be affected as editable
    // to keep the layer conststent after modyfying shapes
    // also compute numer of shape stah can be affected
    for shp in lv.Loop() do begin
      cnt := -1 ;
      for shpNbr in lv.Loop( shp.ProjectedExtent, '', shp, '****T', True ) do begin
        cnt := cnt + 1;
        GIS.HourglassShake
      end ;
      tmpshp := shp.MakeEditable ;
      tmpshp.SetField( 'COUNT', cnt ) ;
      if cnt > max_cnt then begin
        max_cnt := cnt ;
      end ;
    end;
  finally

    GIS.HourglassRelease ;

    lv.Params.Labels.Field      := 'COUNT' ;
    lv.Params.Render.Expression := 'COUNT' ;
    lv.Params.Render.MinVal     := 1 ;
    lv.Params.Render.MaxVal     := max_cnt ;
    lv.Params.Render.StartColor := TGIS_Color.White ;
    lv.Params.Render.EndColor   := TGIS_Color.Red ;
    lv.Params.Render.Zones      := 5 ;
    lv.Params.Area.Color        := TGIS_Color.RenderColor ;
    GIS.InvalidateWholeMap;
  end ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  // change viewer zoom
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  // change viewer zoom
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
