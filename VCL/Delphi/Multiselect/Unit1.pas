//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to select several shapes
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
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

  GisLayerSHP,
  GisLayerVector,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisControlAttributes,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar: TStatusBar;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ImageList1: TImageList;
    Panel1: TPanel;
    GIS_Attributes: TGIS_ControlAttributes;
    lbSelected: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure GISMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  //GisLicense,
  GisTypes  ;

{$R *.DFM}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // open a file
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ) ;

  // and add a new parametr
  with TGIS_LayerVector( GIS.Items[0] ) do begin
    ParamsList.Add ;
    Params.Style := 'selected' ;
    Params.Area.OutlineWidth := 1 ;
    Params.Area.color := TGIS_Color.Blue ;
  end ;
end;

procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    ptg : TGIS_Point ;
    shp : TGIS_Shape ;
    tmp_shp,tmp2_shp : TGIS_Shape ;
    ll  : TGIS_LayerVector ;
    i : Integer ;
begin
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  ll := TGIS_LayerVector( GIS.Items[0] );

  // let's locate a shape after click
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ; // 5 pixels precision

  if shp <> nil then begin
    shp := shp.MakeEditable ;

    // if any found
    if ssCtrl in Shift then
    begin // multiple select
      // set it as selected
      shp.IsSelected := not shp.IsSelected ;
      shp.Invalidate ;

      lbSelected.Clear ;

      // find a selected shape
      tmp_shp := ll.FindFirst( TGIS_Utils.GisWholeWorld, 'GIS_SELECTED=True' ) ;

      // if not found clear attribute control
      if tmp_shp=nil then
        GIS_Attributes.Clear;

      // let's locate another one, if also found - show statistic attributes
      tmp2_shp := ll.FindNext;
      if tmp2_shp = nil then
        GIS_Attributes.ShowShape(tmp_shp)
      else
        GIS_Attributes.ShowSelected(ll);

      for i:=0 to ll.Items.Count - 1 do
      begin
        // we can do this because selected items are MakeEditable so
        // they exist on Items list
        tmp_shp := TGIS_Shape( ll.Items[i] );

        // add selected shapes to list
        if tmp_shp.IsSelected then
        begin
          lbSelected.Items.Add( tmp_shp.GetField( 'NAME' ) ) ;
        end ;
      end ;
    end
    else begin
      // deselect existing
      ll.DeselectAll();
      lbSelected.Clear ;
      lbSelected.Items.Add( shp.GetField( 'NAME' ) ) ;
      // set as selected this clicked
      shp.IsSelected := True ;
      shp.Invalidate ;
      // update attribute control
      GIS_Attributes.ShowShape( shp ) ;
    end ;
  end
  else begin
    // deselect existing
    ll.DeselectAll();
    lbSelected.Clear ;
    GIS_Attributes.Clear ;
  end ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
