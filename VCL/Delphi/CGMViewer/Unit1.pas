//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  CGMViewer sample — demonstrates rendering CGM (Computer Graphics Metafile) symbol files (Delphi/VCL).

  What the sample shows:
    - Loading CGM (Computer Graphics Metafile) symbol files
    - Displaying available symbols from TatukGIS symbol library
    - Rendering CGM symbols as point markers on the map
    - Using TGIS_Utils.SymbolList to enumerate symbol resources
    - Creating point shapes with symbol markers
    - Rotating symbols programmatically (90° increments)
    - Scaling symbols to fit viewer extents
    - Interactive symbol selection via file listbox
    - Displaying symbols centered on crosshair layer
    - Symbol preview and visualization
    - Supporting multiple symbol size and rotation parameters

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_Utils.SymbolList       - enumerate CGM symbol resources
    TGIS_LayerVector            - vector layer for symbol markers
    TGIS_Shape (point)          - point geometry for symbol placement
    TGIS_Params.Marker          - point symbol rendering parameters
    CGM symbols                 - Computer Graphics Metafile vector symbols
    Symbol rotation             - angle-based marker orientation
    Symbol scaling              - size adjustment for display
    Symbol library              - TatukGIS built-in symbol collection
    Interactive selection       - listbox-based symbol picking
}

unit Unit1;

interface

uses
  System.Classes,
  System.Math,

  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.FileCtrl,
  Vcl.ComCtrls,
  Vcl.Graphics,
  Vcl.ToolWin,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    GIS: TGIS_ViewerWnd;
    Panel1: TPanel;
    FileList: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    ToolBar1: TToolBar;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure FileListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    shp : TGIS_Shape ;
    procedure drawSymbol ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GisSymbol,
  GisTypes ;

{$R *.DFM}


{ drawSymbol - Load and render CGM symbol file

  Algorithm:
    1. Guard: exit if shape pointer invalid
    2. Load CGM file from FileList selection into SymbolList cache
    3. Calculate target symbol size as 2/3 of smaller viewer dimension
    4. Query symbol's actual width/height dimensions after rendering
    5. Preserve aspect ratio by scaling down the larger dimension
    6. Set rendering colors (markers to render color)
    7. Trigger map redraw to display updated symbol

  Technical details:
    - SymbolList.Prepare: loads CGM file, caches in symbol library
    - Negative size: -N means N pixels at current zoom level (absolute size)
    - Symbol.Prepare/Unprepare: queries rendered dimensions
    - Aspect ratio correction: scale to fit box while maintaining proportions
}
procedure TForm1.drawSymbol ;
var
  w,h  : Integer ;  { Rendered width and height of symbol in pixels }
begin
  { Guard: exit if shape not initialized }
  if not Assigned(shp) then exit;

  { Load the selected CGM file and cache it in SymbolList }
  shp.Params.Marker.Symbol := SymbolList.Prepare( FileList.FileName ) ;

  { Calculate symbol size to fit two-thirds of the smaller viewer dimension }
  if Assigned( shp.Params.Marker.Symbol ) then
  begin
    { Negative size = fixed pixel size (not zoom-dependent) }
    shp.Params.Marker.Size := - Min( GIS.Width, Gis.Height ) * 2 div 3 ;

    { Prepare symbol for rendering to query its actual dimensions }
    shp.Params.Marker.Symbol.Prepare( GIS, -5, TGIS_Color.Black, TGIS_Color.Black, 0, 0,  TGIS_LabelPosition.MiddleCenter, True ) ;
    w := shp.Params.Marker.Symbol.Width  ;  { Get rendered width }
    h := shp.Params.Marker.Symbol.Height ;  { Get rendered height }
    shp.Params.Marker.Symbol.Unprepare ;    { Release rendering resources }

    { Preserve aspect ratio: scale down the larger dimension to fit the box }
    if h < w then
      shp.Params.Marker.Size :=  shp.Params.Marker.Size  * h div w;
  end
  else
    { Symbol load failed: set size to zero (invisible) }
    shp.Params.Marker.Size := 0 ;

  { Set rendering colors for the marker symbol }
  shp.Params.Marker.Color := TGIS_Color.RenderColor ;
  shp.Params.Marker.OutlineColor := TGIS_Color.RenderColor ;

  { Force complete map redraw to display updated symbol }
  GIS.InvalidateWholeMap ;
end ;


{ Creates the crosshair vector layer (horizontal line, vertical line, centre point) on startup
  and navigates the FileListBox to the Symbols directory. }
procedure TForm1.FormCreate(Sender: TObject);
var
  ll : TGIS_LayerVector ;
begin
  DirectoryListBox1.Directory := TGIS_Utils.GisSamplesDataDirDownload + '\Symbols\' ;
  // new layer as a grid
  ll := TGIS_LayerVector.Create  ;
  GIS.Add( ll ) ;
  ll.Extent := TGIS_Utils.GisExtent( -90, -90, 90, 90 ) ;
  GIS.FullExtent ;

  // add coordinate layout
  shp := ll.CreateShape( TGIS_ShapeType.Arc ) ;
  shp.Params.Line.Width := 1 ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( -90, 0 ) ) ;
  shp.AddPoint( TGIS_Utils.GisPoint(  90, 0 ) ) ;

  shp := ll.CreateShape( TGIS_ShapeType.Arc ) ;
  shp.Params.Line.Width := 1 ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0, -90 ) ) ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0,  90 ) ) ;

  shp := ll.CreateShape( TGIS_ShapeType.Point ) ;
  shp.AddPart ;
  shp.AddPoint( TGIS_Utils.GisPoint( 0, 0 ) ) ;
end;

{ Redraws the symbol at the new size whenever the form is resized. }
procedure TForm1.FormResize(Sender: TObject);
begin
  drawSymbol ;
end;

{ Synchronises the FileListBox to the directory selected in DirectoryListBox1. }
procedure TForm1.DirectoryListBox1Change(Sender: TObject);
begin
  FileList.Directory := DirectoryListBox1.Directory ;
end;

{ Redraws the symbol when a different CGM file is selected in the file list. }
procedure TForm1.FileListClick(Sender: TObject);
begin
  StatusBar1.SimpleText := FileList.FileName ;
  drawSymbol ;
end ;

{ Rotates the displayed symbol by 90 degrees (Pi/2 radians) each click. }
procedure TForm1.Button1Click(Sender: TObject);
begin
  // rotate symbol
  shp.Params.Marker.SymbolRotate := shp.Params.Marker.SymbolRotate+Pi/2 ;
  shp.Invalidate ;
end;

end.

