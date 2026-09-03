//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  WindAnimation Main Form — demonstrates real-time animated wind visualization (Delphi/VCL).

  What the sample shows:
    - Main application window hosting the wind visualization layer
    - Loading base map imagery (satellite/raster data) as background
    - Creating and configuring the custom wind animation layer
    - Loading meteorological wind data from JSON files
    - Real-time particle animation using OnTimer callbacks
    - Integration of custom layers with standard GIS viewers
    - Disabling layer caching for smooth real-time rendering
    - Viewport synchronization (FullExtent zooming)

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main map visualization control
    TGIS_LayerJPG               - raster/image layer for base map
    TGIS_LayerWind              - custom animated wind particle layer
    GIS.Add()                   - add layers to viewer
    GIS.InvalidateTopmost()     - refresh topmost layer only (efficient update)
    CachedPaint                 - layer caching control (False = no cache)
    TTimer                      - frame animation trigger
}
unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  VCL.GisViewerWnd,
  GisTypesUI ;

type
  TFormMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  GisFunctions,
  GISLayerWind,
  GisLayerJPG,
  GisUtils ;

{ FormShow
  Initializes the wind visualization sample. Loads satellite imagery as base map,
  creates the wind animation layer with JSON meteorological data, and starts the
  animation timer for real-time particle updates.

  Algorithm:
    1. Load world satellite imagery (VisibleEarth 8km base map).
    2. Create wind animation layer and set meteorological JSON data path.
    3. Disable layer caching to ensure smooth real-time rendering.
    4. Add wind layer to viewer and zoom to full extent.
    5. Enable timer for frame-by-frame animation. }
procedure TFormMain.FormShow(Sender: TObject);
var
  lv : TGIS_LayerWind ;
begin
  // Load base map imagery
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg') ;

  // Create and configure wind animation layer
  lv := TGIS_LayerWind.Create ;
  lv.Path := 'wind-global.json' ;
  lv.CachedPaint := False ;
  GIS.Add( lv ) ;
  GIS.FullExtent ;
  Timer1.Enabled := True ;
end;

{ Timer1Timer
  Animation frame callback. Refreshes the topmost (wind) layer each frame.
  Called repeatedly while animation is running to advance particle positions. }
procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  GIS.InvalidateTopmost ;
end;

end.
