//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  PixelLocate Sample — Demonstrates reading pixel values from raster layers and
  displaying pixel data including RGB colors and native channel values.

  Key concepts illustrated:
    - Loading raster datasets: ArcInfo Binary Grid (.adf) and JPEG images
    - Pixel value queries: reading pixel data at cursor position
    - TGIS_LayerPixel.Locate: queries both rendered RGB and raw native values
    - RGB color display: showing mapped color as a panel and RGB values
    - Native channel values: displaying raw data from each raster band
    - Brightness adjustment: dynamically modifying raster appearance
    - Coordinate conversion: screen-to-map transformation for pixel lookup

  User workflow:
    1. Load a raster layer:
       - "Load Image" - loads a JPEG aerial photo (DOQ)
       - "Load Grid" - loads a DEM elevation grid (ADF format)
    2. Hover mouse over the raster to see:
       - Color panel showing rendered pixel color
       - RGB values (R, G, B components)
       - Native channel values (raw data values for each band)
    3. For images only: adjust brightness trackbar
    4. Displayed values update in real-time as you move the cursor

  Data types:
    - JPEG image: DOQ (Digital Orthophoto Quad) aerial photography
    - Grid: NED (National Elevation Dataset) DEM in ArcInfo format

  Raster operations:
    - TGIS_LayerPixel.Locate(point, rgb, nativeValues, transparent)
      Returns both the rendered RGB color and native band values
    - RGB color: result of color mapping and rendering pipeline
    - Native values: raw pixel data from source (before color scaling)
    - TGIS_LayerPixel.Params.Pixel.Brightness: brightness adjustment
}

unit Unit1;

interface

uses
  System.Classes,
  System.Types,
  System.SysUtils,
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
  GisLayerADF,
  GisLayerSHP,
  GisLayerVector,
  GisLayerJPG,
  GisLayerPixel,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    paTop: TPanel;
    gbOriginal: TGroupBox;
    gbChannels: TGroupBox;
    lbRGBValueC: TLabel;
    paColorC: TPanel;
    GroupBox1: TGroupBox;
    tbBrightness: TTrackBar;
    Memo1: TMemo;
    btnImage: TButton;
    btnGrid: TButton;
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbBrightnessChange(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure btnGridClick(Sender: TObject);
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
  btnGridClick
  Loads a Digital Elevation Model (DEM) grid in ArcInfo Binary Format (.adf).
  Disables brightness adjustment since DEMs don't use color mapping.
}
procedure TForm1.btnGridClick(Sender: TObject);
begin
  { Load the National Elevation Dataset (NED) DEM grid file (ADF format) }
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf') ;

  { Disable brightness control: DEMs don't support brightness adjustment in same way as RGB images }
  tbBrightness.Enabled := false ;
  { Reset brightness to default }
  tbBrightness.Position := 0 ;
end;

{
  btnImageClick
  Loads a JPEG aerial photograph (Digital Orthophoto Quad - DOQ).
  Enables brightness adjustment since RGB images support it.
}
procedure TForm1.btnImageClick(Sender: TObject);
begin
  { Load the aerial photograph (DOQ JPEG format) }
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\Countries\USA\States\California\San Bernardino\DOQ\37134877.jpg') ;

  { Enable brightness control: RGB images support brightness adjustment }
  tbBrightness.Enabled := true ;
  { Reset brightness to default }
  tbBrightness.Position := 0 ;
end;

{
  GISMouseMove
  Called continuously as mouse moves over the map.
  Queries pixel data at the cursor position and displays RGB and native values.

  Algorithm:
    1. Convert screen coordinates to map coordinates
    2. Use TGIS_LayerPixel.Locate to query pixel at that location
    3. Get both mapped RGB color and native raw values
    4. Display RGB color in panel and show numeric RGB values
    5. Show all native channel values in memo (CH0, CH1, etc.)
}
procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg         : TGIS_Point ;
  ll          : TGIS_LayerPixel ;
  rgbMapped   : TGIS_Color ;
  nativesVals : TGIS_DoubleArray ;
  bT          : Boolean;
  i           : Integer;
begin
  { Guard: skip if no layers loaded }
  if GIS.IsEmpty then exit ;

  { Only process if in Select mode (not Zoom or Drag) }
  if GIS.Mode <> TGIS_ViewerMode.Select then exit;

  { Convert screen pixel coordinates to geographic map coordinates }
  ptg := GIS.ScreenToMap( Point(x, y ) );

  { Get the raster layer from the viewer }
  ll := TGIS_LayerPixel( GIS.Items[0] );
  if not Assigned(ll) then exit;

  { Only query pixel data if not currently painting (avoid performance issues) }
  if not GIS.InPaint then begin
    { Query the pixel at the map coordinate.
      Returns both mapped RGB color and native band values.
      rgbMapped: color as rendered (after brightness, color mapping, etc.)
      nativesVals: raw values from each raster band
      bT: transparency flag }
    if ll.Locate( ptg, rgbMapped, nativesVals, bT) then
      begin
        { Display the mapped RGB color in the color panel }
        paColorC.Color := RGB(rgbMapped.R,
                                     rgbMapped.G,
                                     rgbMapped.B);

        { Show the RGB numeric values as text }
        lbRGBValueC.Caption := Format( 'RGB :  %d , %d , %d ',
                                      [ rgbMapped.R, rgbMapped.G, rgbMapped.B ]
                                       );

        { Display native (raw) channel values }
        Memo1.Clear;
        { List each band's native value (CH0, CH1, etc.) }
        for i:= 0 to (Length(nativesVals) - 1) do
          Memo1.Lines.Add( Format( 'CH%d =  %.0f', [ i, nativesVals[i] ] ) );
      end;
  end;
end;

{
  tbBrightnessChange
  Called when brightness trackbar is moved.
  Adjusts the raster layer brightness in real-time.
}
procedure TForm1.tbBrightnessChange(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  { Get the raster layer from the viewer }
  ll := TGIS_LayerPixel( GIS.Items.Items[0] );
  if not Assigned(ll) then exit;

  { Apply the new brightness value from the trackbar.
    Brightness values typically range from -100 to +100 }
  ll.Params.Pixel.Brightness := tbBrightness.Position;

  { Redraw the map to apply the brightness change }
  GIS.InvalidateWholeMap;
end;

end.
