//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  BitmapFill sample - demonstrates per-shape bitmap fill using a custom
  PaintShapeEvent callback.

  What the sample shows:
    - Loading a vector shapefile (California Counties) into the GIS viewer
    - Implementing custom shape rendering via PaintShapeEvent callback
    - Assigning per-shape bitmap textures based on attribute values
    - Using combo boxes to switch between different rendering criteria
      (population density vs. raw population)
    - Toggling feature labels (none, FIPS code, name) dynamically
    - Five different texture bitmaps demonstrating visual variety
    - Integration of bitmap resources with shape rendering pipeline

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerVector            - vector layer with custom paint callbacks
    TGIS_LayerSHP               - ESRI Shapefile layer (California Counties)
    PaintShapeEvent callback    - custom per-shape rendering hook
    TGIS_Shape                  - individual geographic feature
    TGIS_Params.Marker          - shape visualization parameters
    Bitmap resources            - texture fill patterns
    Shape attributes            - field-based rendering criteria
}

unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
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
  GisLayerVector,
  GisLayerSHP,
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
    Panel3: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    btnFullExtent: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PaintShape( _sender : TOBject; _shape : TGIS_Shape );
    procedure ComboLabelsChange(Sender: TObject);
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

{$R *.DFM}

{ Loads the California Counties shapefile and wires up the custom paint callback on startup. }
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\USA\States\California\Counties.shp' ;
  ll.UseConfig := False ;
  ll.Name := 'counties' ;

  //set custom painting routine
  ll.PaintShapeEvent := PaintShape ;
  GIS.Add(ll) ;

  GIS.FullExtent ;

  ComboStatistic.ItemIndex := 0 ;
  ComboLabels.ItemIndex := 0 ;
end;


{ Custom per-shape paint callback.  Assigns one of five texture bitmaps to the county fill
  based on the active statistic (population density or raw population), then calls
  _shape.Draw to render it with a dark-grey outline.

  Algorithm:
    1. Extract population and area values from shape attributes
    2. Skip shapes with zero area (invalid geometry)
    3. Save existing bitmap to avoid losing reference
    4. Create new bitmap container for this shape
    5. Set base rendering params: solid fill, dark outline
    6. Calculate factor based on selected statistic:
       - ComboStatistic.ItemIndex = 1: density (population/area)
       - ComboStatistic.ItemIndex = 0: raw population
    7. Map factor value to one of five texture bitmaps via threshold ranges
    8. Render shape with assigned texture
    9. Restore original bitmap reference
}
procedure TForm1.PaintShape( _sender : TObject; _shape : TGIS_Shape ) ;
var
  population : double ;  // Total population from shape attribute
  area       : double ;  // Land area from shape attribute
  factor     : double ;  // Computed value for texture selection (density or population)
  oldBitmap  : TBitmap ; // Saved reference to original bitmap
begin

  { Extract attribute values from shape fields }
  population := StrToFloat(_shape.GetField( 'population' ) ) ;
  area       := StrToFloat(_shape.GetField('area'));

  { Sanity check: skip invalid geometries with zero area }
  if area = 0 then Exit ;

  { Save existing bitmap reference to restore later }
  oldBitmap := nil;
  if assigned( _shape.Params.Area.Bitmap ) then
      if not ( _shape.Params.Area.Bitmap.IsEmpty ) then
          oldBitmap := _shape.Params.Area.Bitmap.NativeBitmap as TBitmap ;

  { Initialize new bitmap container for this shape }
  _shape.Params.Area.Bitmap := TGIS_Bitmap.Create ;
  _shape.Params.Area.Pattern := TGIS_BrushStyle.Solid ;
  _shape.Params.Area.Color := TGIS_Color.Red ;
  _shape.Params.Area.OutlineColor := TGIS_Color.DimGray ;
  _shape.Params.Area.OutlineWidth := 20 ;

  { Select statistic and calculate factor for texture assignment }
  if ComboStatistic.itemIndex = 1 then begin
    { Density mode: population per unit area (people/km²) }
    factor := population/area ;

    { Map density ranges to five texture bitmaps for visual classification }
    if      factor <      1 then _shape.Params.Area.Bitmap.NativeBitmap := Image1.Picture.Bitmap  { Lowest density }
    else if factor <      7 then _shape.Params.Area.Bitmap.NativeBitmap := Image2.Picture.Bitmap  { Low }
    else if factor <     52 then _shape.Params.Area.Bitmap.NativeBitmap := Image3.Picture.Bitmap  { Medium }
    else if factor <    380 then _shape.Params.Area.Bitmap.NativeBitmap := Image4.Picture.Bitmap  { High }
    else if factor <   3000 then _shape.Params.Area.Bitmap.NativeBitmap := Image5.Picture.Bitmap  { Highest }
  end
  else begin
    { Raw population mode: absolute population count }
    factor := population ;

    { Map population ranges to five texture bitmaps }
    if      factor <    5000 then _shape.Params.Area.Bitmap.NativeBitmap := Image1.Picture.Bitmap  { < 5k }
    else if factor <   22000 then _shape.Params.Area.Bitmap.NativeBitmap := Image2.Picture.Bitmap  { 5k-22k }
    else if factor <  104000 then _shape.Params.Area.Bitmap.NativeBitmap := Image3.Picture.Bitmap  { 22k-104k }
    else if factor <  478000 then _shape.Params.Area.Bitmap.NativeBitmap := Image4.Picture.Bitmap  { 104k-478k }
    else if factor < 2186000 then _shape.Params.Area.Bitmap.NativeBitmap := Image5.Picture.Bitmap; { > 478k }
  end;

  { Render the shape with assigned texture bitmap and outline }
  _shape.Draw;

  { Restore original bitmap reference to avoid memory leak }
  _shape.Params.Area.Bitmap.NativeBitmap := oldBitmap ;
end;


{ Toggles county labels between none, FIPS code (CNTYIDFP), and name (NAME). }
procedure TForm1.ComboLabelsChange(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  // set labels for states
  ll := TGIS_LayerVector( Gis.Get( 'counties' ) ) ;
  if ll <> nil then begin
    case ComboLabels.ItemIndex of
      1 : ll.Params.Labels.Field := 'CNTYIDFP' ;
      2 : ll.Params.Labels.Field := 'NAME' ;
    else  ll.Params.Labels.Field := '' ;
    end ;
  end ;

  GIS.InvalidateWholeMap ;
end;

{ Resets the map view to show all loaded layers. }
procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

{ Doubles the current zoom level. }
procedure TForm1.btnZoomInClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom * 2 ;
end;

{ Halves the current zoom level. }
procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  GIS.Zoom := GIS.Zoom / 2 ;
end;

end.

