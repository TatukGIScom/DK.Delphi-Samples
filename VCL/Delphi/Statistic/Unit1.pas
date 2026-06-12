//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Statistic Sample — Demonstrates statistical analysis and choropleth visualization
  using custom shape painting and dynamic attribute-based coloring.

  Key concepts illustrated:
    - Custom rendering via PaintShapeEvent hook
    - Choropleth mapping: data-driven polygon coloring based on attribute values
    - Statistical classification: grouping data into ranges with different colors
    - Attribute field selection: switching between different data fields for analysis
    - Dynamic layer styling: modifying shape colors at render time based on data
    - Color graduation: visual representation of data intensity (light to dark)

  User workflow:
    1. Load California counties shapefile
    2. Choose statistic type (dropdown):
       - "Area": visualize by county area (size)
       - "Population": visualize by population count
    3. Switch label field (dropdown):
       - "None": no labels
       - "County ID": show CNTYIDFP
       - "County Name": show NAME field
    4. Counties colored by ranges: light colors (low values) to dark (high values)
    5. Use zoom buttons to explore data at different scales

  Statistical classification approach:
    - 6 color classes from light to dark green/blue
    - Each class represents a range of the chosen attribute (area or population)
    - Color intensity increases with data value: visual representation of magnitude
    - Example population ranges:
      Class 1: < 5,000 (light green)
      Class 2: 5,000-22,000 (light green)
      Class 3: 22,000-104,000 (cyan)
      Class 4: 104,000-478,000 (blue)
      Class 5: 478,000-2,186,000 (dark blue)
      Class 6: > 2,186,000 (dark purple)

  Data: California counties (Sacramento, San Francisco Bay, Southern California)

  Key API: TGIS_LayerVector.PaintShapeEvent - intercept and customize rendering
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

  //GisLicense,
  GisEditor,
  GisLayerSHP,
  GisLayerVector,
  GisParams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ComboLabels: TComboBox;
    ComboStatistic: TComboBox;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure ButtonZoomOutClick(Sender: TObject);
    procedure PaintShape( _sender : TOBject; _shape : TGIS_Shape );
    procedure ComboLabelsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{
  FormCreate
  Initializes the sample:
    1. Loads the California counties shapefile
    2. Hooks custom paint event for statistical coloring
    3. Sets default selections for statistics and labels
}
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  { Create and load the California counties shapefile }
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ;
  ll.Name := 'counties' ;

  { Hook the custom paint event to override default rendering.
    PaintShape will be called for each county before it's drawn,
    allowing us to set colors based on attribute values. }
  ll.PaintShapeEvent := PaintShape ;

  { Add the layer to the viewer }
  GIS.Add(ll) ;

  { Fit the viewport to show all counties }
  GIS.FullExtent ;

  { Set default dropdown selections }
  ComboStatistic.ItemIndex := 0 ;  { Default statistic: Population }
  ComboLabels.ItemIndex := 0 ;     { Default labels: None }
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
procedure TForm1.ButtonZoomOutClick(Sender: TObject);
begin
   GIS.Zoom := GIS.Zoom / 2 ;
end;

{
  PaintShape
  Custom shape rendering event handler: called before each county is drawn.
  Assigns color based on selected statistic (area or population) using
  choropleth classification: 6 color classes from light to dark.

  Algorithm:
    1. Read population and area values from shape attributes
    2. Select the factor based on combo selection (area or population)
    3. Classify the factor into 6 ranges
    4. Assign a color for each range (light green to dark purple)
    5. Draw the shape with the assigned color
}
procedure TForm1.PaintShape( _sender : TOBject; _shape : TGIS_Shape );
var
  population : double ;
  area       : double ;
  factor     : double ;
begin
  { Extract numeric values from the county's attribute fields }
  population := StrToFloat( _shape.GetField( 'population' ) ) ;
  area       := StrToFloat( _shape.GetField( 'area' ) ) ;

  { Determine which statistic to visualize based on combo selection }
  if ComboStatistic.itemIndex = 1 then
  begin
    { Visualize by area: assign factor to area value }
    factor := area ;

    { Classify area into 6 ranges and assign colors: light (small) to dark (large) }
    if      factor <     40 then _shape.Params.Area.Color := TGIS_Color.FromRGB($0000F00C)  { Light green: < 40 }
    else if factor <    130 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00AEFFB3)  { Light green: 40-130 }
    else if factor <    480 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00CCCCFF)  { Cyan: 130-480 }
    else if factor <   2000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($003535FF)  { Blue: 480-2,000 }
    else if factor <  10000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($000000B3)  { Dark blue: 2,000-10,000 }
    else                         _shape.Params.Area.Color := TGIS_Color.FromRGB($003000B3) ; { Dark purple: > 10,000 }
  end
  else
  begin
    { Visualize by population: assign factor to population value (default) }
    factor := population ;

    { Classify population into 6 ranges with colors: light (sparse) to dark (dense) }
    if      factor <   5000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($0000F00C)     { Light green: < 5,000 }
    else if factor <  22000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00AEFFB3)     { Light green: 5K-22K }
    else if factor < 104000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($00CCCCFF)     { Cyan: 22K-104K }
    else if factor < 478000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($003535FF)     { Blue: 104K-478K }
    else if factor <2186000 then _shape.Params.Area.Color := TGIS_Color.FromRGB($000000B3)     { Dark blue: 478K-2.2M }
    else                         _shape.Params.Area.Color := TGIS_Color.FromRGB($003000B3) ;   { Dark purple: > 2.2M }
  end;

  { Draw the shape with the assigned color }
  _shape.Draw;
end;

{
  ComboLabelsChange
  Handles label field selection change.
  Switches between no labels, county ID, and county name.
  Triggers a map refresh to show the new labels.
}
procedure TForm1.ComboLabelsChange(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  { Get the counties layer from the viewer }
  ll := TGIS_LayerVector( Gis.Get( 'counties' ) ) ;

  { Update the label field based on combo selection }
  if ll <> nil then
  begin
    case ComboLabels.ItemIndex of
      1 : ll.Params.Labels.Field := 'CNTYIDFP' ;  { Show county FIPS ID }
      2 : ll.Params.Labels.Field := 'NAME' ;      { Show county name }
    else  ll.Params.Labels.Field := '' ;           { No labels (default) }
    end ;
  end ;

  { Redraw the map to display the new labels }
  GIS.InvalidateWholeMap ;
end;

end.
