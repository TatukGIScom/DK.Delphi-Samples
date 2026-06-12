//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Multiselect Sample — Demonstrates multiple feature selection with different selection modes
  and displaying selected feature attributes in a list and attributes panel.

  Key concepts illustrated:
    - Single selection: click to select one feature (deselects others)
    - Multiple selection: Ctrl+click to toggle individual feature selection
    - Selection state: TGIS_Shape.IsSelected property tracks if shape is selected
    - Visual feedback: selected shapes highlighted in blue (from ParamsList style)
    - Feature queries: FindFirst/FindNext to iterate selected features
    - Attribute display: showing attributes in list and attributes control
    - Selection statistics: displaying single vs. multiple selection attributes

  User workflow:
    1. Click on a county to select it (single selection)
       - County highlights in blue
       - Attributes shown in attributes panel
       - County name added to "Selected" list
    2. Hold Ctrl and click other counties to add to selection (multiple selection)
       - Toggles selection (Ctrl+click again to deselect)
       - Shows all selected county names in list
       - Shows aggregated attributes in attributes panel
    3. Click empty space to deselect all
    4. Use zoom buttons to zoom in/out

  Selection modes:
    - Single click: deselect all, then select clicked feature
    - Ctrl+click: toggle clicked feature while keeping others selected
    - Selection tracked via GIS_SELECTED field and IsSelected property
    - Visual indication: selected shapes rendered in blue (from style)

  Data display:
    - Selected list: shows NAME field of all selected counties
    - Attributes panel: shows single feature attributes or aggregated statistics
    - Real-time update: list and attributes refresh with each selection change

  Data: California counties
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


{
  FormCreate
  Initializes the sample by loading the counties shapefile and configuring
  the layer's visual style for selected features.

  Steps:
    1. Load California counties shapefile
    2. Add a second parameter style for selected feature visualization
    3. Configure selected features to render in blue
}
procedure TForm1.FormCreate(Sender: TObject);
begin
  { Load California counties shapefile }
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ) ;

  { Configure the layer's selected feature style (blue highlight) }
  with TGIS_LayerVector( GIS.Items[0] ) do begin
    { Add a second parameter set for the 'selected' style }
    ParamsList.Add ;
    { Use the 'selected' style for visual distinction of selected features }
    Params.Style := 'selected' ;
    { Set outline width for clarity }
    Params.Area.OutlineWidth := 1 ;
    { Color selected features in blue }
    Params.Area.color := TGIS_Color.Blue ;
  end ;
end;

{
  GISMouseDown
  Handles mouse clicks on the map to select/deselect features.
  Supports two modes: single selection (click) and multiple selection (Ctrl+click).

  Algorithm:
    1. Locate the feature at the click position
    2. If Ctrl+click: toggle selection of that feature (multiple selection mode)
       - Find all selected features
       - Show aggregated attributes if multiple selected, single if one
       - Update selected list with all selected feature names
    3. If regular click: single selection mode
       - Deselect all other features
       - Select only the clicked feature
       - Show attributes for that one feature
    4. If clicked on empty space: deselect all
}
procedure TForm1.GISMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    ptg : TGIS_Point ;
    shp : TGIS_Shape ;
    tmp_shp,tmp2_shp : TGIS_Shape ;
    ll  : TGIS_LayerVector ;
    i : Integer ;
begin
  { Guard: skip if no layers loaded or painting in progress }
  if GIS.IsEmpty then exit ;
  if GIS.InPaint then exit ;

  { Get the vector layer being edited }
  ll := TGIS_LayerVector( GIS.Items[0] );

  { Convert screen pixel to map coordinate and find shape at that location }
  ptg := GIS.ScreenToMap( Point(x, y ) );
  shp := TGIS_Shape( GIS.Locate( ptg, 5/GIS.Zoom ) ) ;  { 5 pixels precision }

  { Process the click }
  if shp <> nil then begin
    { Make the shape editable so we can access its properties }
    shp := shp.MakeEditable ;

    { Multiple selection mode: Ctrl+click toggles the clicked feature }
    if ssCtrl in Shift then
    begin
      { Toggle selection state: selected becomes unselected and vice versa }
      shp.IsSelected := not shp.IsSelected ;
      { Redraw the shape with its new selection state }
      shp.Invalidate ;

      { Clear the selected list and rebuild it with all selected features }
      lbSelected.Clear ;

      { Find the first selected feature in the layer }
      tmp_shp := ll.FindFirst( TGIS_Utils.GisWholeWorld, 'GIS_SELECTED=True' ) ;

      { If no selected features found, clear the attributes panel }
      if tmp_shp=nil then
        GIS_Attributes.Clear;

      { Check if there's a second selected feature }
      tmp2_shp := ll.FindNext;
      { If only one selected: show that one shape's attributes }
      if tmp2_shp = nil then
        GIS_Attributes.ShowShape(tmp_shp)
      { If multiple selected: show aggregated statistics }
      else
        GIS_Attributes.ShowSelected(ll);

      { Iterate all features and add selected ones to the list }
      for i:=0 to ll.Items.Count - 1 do
      begin
        tmp_shp := TGIS_Shape( ll.Items[i] );

        { Add the NAME field of selected features to the list }
        if tmp_shp.IsSelected then
        begin
          lbSelected.Items.Add( tmp_shp.GetField( 'NAME' ) ) ;
        end ;
      end ;
    end
    else begin
      { Single selection mode: regular click }
      { Deselect all other features }
      ll.DeselectAll();
      { Clear the selected list }
      lbSelected.Clear ;
      { Add only the clicked feature to the list }
      lbSelected.Items.Add( shp.GetField( 'NAME' ) ) ;
      { Select only the clicked feature }
      shp.IsSelected := True ;
      { Redraw to show the selection }
      shp.Invalidate ;
      { Show attributes for the selected feature }
      GIS_Attributes.ShowShape( shp ) ;
    end ;
  end
  else begin
    { Clicked on empty space: deselect all }
    ll.DeselectAll();
    lbSelected.Clear ;
    { Clear the attributes panel }
    GIS_Attributes.Clear ;
  end ;
end;

{ Fit viewport to show all counties (full extent) }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ Zoom in: doubles the current zoom factor }
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ Zoom out: halves the current zoom factor }
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.
