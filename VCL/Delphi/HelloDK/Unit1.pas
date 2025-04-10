unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  VCL.GisViewerWnd,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,

  //GisLicense,
  GisLayerVector,
  GisTypes,
  GisTypesUI,
  GisUtils;

type
  TMainForm = class(TForm)
    ToolBar1: TToolBar;
    btnOpen: TSpeedButton;
    GIS: TGIS_ViewerWnd;
    btnZoom: TSpeedButton;
    btnSelect: TSpeedButton;
    btnDrag: TSpeedButton;
    btnCreate: TSpeedButton;
    btnFind: TSpeedButton;
    procedure btnOpenClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCreateClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.btnOpenClick(Sender: TObject);
begin
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\WorldDCW\world.shp');
end;

// button "Add Shape" click event
procedure TMainForm.btnCreateClick(Sender: TObject);
var
  ll  : TGIS_LayerVector ;
  shp : TGIS_Shape ;
begin
  // lets find if such layer already exists
  ll := TGIS_LayerVector( GIS.Get( 'edit layer' ) );
  if ll <> nil then
    exit ;

  // create a new layer and add it to the viewer
  ll := TGIS_LayerVector.Create ;
  ll.Name := 'edit layer' ;
  ll.CS := GIS.CS ; // same coordinate system as a viewer

  // in a previous sample we created a solid polygon
  // to make it nicer we need it to be transparent
  ll.Params.Area.OutlineColor := TGIS_Color.Blue ;
  ll.Params.Area.Pattern := TGIS_BrushStyle.Clear ;
  GIS.Add( ll );

  // create a new shape and immediately add it to the layer
  // create a shape and add it to polygon
  shp := ll.CreateShape( TGIS_ShapeType.Polygon ) ;

  // add some veritices

  // we group operation together
  shp.Lock( TGIS_Lock.Extent ) ;
  shp.AddPart ; // shape can have multiple parts like islands, holes


  shp.AddPoint( TGIS_Utils.GisPoint( 10, 10 ) );
  shp.AddPoint( TGIS_Utils.GisPoint( 10, 80 ) );
  shp.AddPoint( TGIS_Utils.GisPoint( 80, 90 ) );
  shp.AddPoint( TGIS_Utils.GisPoint( 90, 10 ) );

  shp.Unlock ; // unlock operation, close shape if necessary

  // and now refresh map
  GIS.InvalidateWholeMap ;
end;

// button "Drag" click event
procedure TMainForm.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag;
end;

// button "Add Shape" click event
procedure TMainForm.btnFindClick(Sender: TObject);
var
  ll     : TGIS_LayerVector ;
  selshp : TGIS_Shape ;
  lv     : TGIS_LayerVector ;
  tmpshp : TGIS_Shape ;
begin
  // lets find if such layer already exists
  ll := TGIS_LayerVector( GIS.Get( 'edit layer') );
  if ll = nil then
    exit ;

  // lets get a layer with world shape
  // names are constructed based on layer name
  lv := TGIS_LayerVector( GIS.Get( 'world' ) );

  // deselect all shapes on the map
  lv.DeselectAll;

  // and we need a created shape, with we want
  // to use as selection shape
  selshp := ll.GetShape(1); // just a first shape form the layer

  // for file based layer we should pin shape to memory
  // otherwise it should be discarded
  selshp := selshp.MakeEditable ;


  // we group operations together
  GIS.Lock;
  // so now we search for all shapes with DE9-IM relationship
  // which labels starts with 's' (with use of SQL syntax)
  // in this case we will fine "T*****FF*" contains relationship
  // which means that we will find only shapes inside the polygon
  for tmpshp in lv.Loop( selshp.Extent, 'label LIKE ''s%''', selshp, 'T*****FF*' ) do
  begin
    tmpshp.IsSelected := True ;
  end ;
  // unlock operation, close shape if necessary
  GIS.Unlock;

  // and now refresh map
  GIS.InvalidateWholeMap;
end;

 // button "Select" click event
procedure TMainForm.btnSelectClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Select;
end;

// button "Zoom" click event
procedure TMainForm.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom;
end;


// map TapSimple event
// event passes X, Y coordinates
procedure TMainForm.GISTapSimpleEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  shp       : TGIS_Shape ;
  ptg       : TGIS_Point ;
  precision : Double ;
  lv        : TGIS_LayerVector ;
begin
  // ignore clicking if mode is other then select
  if GIS.Mode <> TGIS_ViewerMode.Select then
    exit ;

   lv := TGIS_LayerVector( GIS.Get('world') );
  //deselect all shapes on the layer
   lv.DeselectAll;
  // convert screen coordinates to map coordinates
  ptg := GIS.ScreenToMap( Point( Round(X), Round(Y) ) );

  // calculate precision of location as 5 pixels
  precision := 5 / GIS.Zoom ;


  // let's try to locate a selected shape on the map
  shp := TGIS_Shape( GIS.Locate( ptg, precision ) );

  // not found?
  if shp = nil then exit ;

  // mark shape as selected
  shp.IsSelected := not shp.IsSelected ;

  // and refresh a map
  GIS.InvalidateWholeMap ;
end;

end.
