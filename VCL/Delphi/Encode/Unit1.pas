//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Encode sample — demonstrates transparent layer encoding using read/write callbacks.

  What the sample shows:
    - Loading a base world shapefile into the GIS viewer
    - Exporting layer data to a new file with custom encoding applied
    - Implementing XOR cipher encoding byte-by-byte using WriteEvent callback
    - Encoding process keyed on file position for deterministic cipher
    - Re-opening encoded file from disk
    - Transparently decoding data on-the-fly using ReadEvent callback
    - Same XOR cipher used in both read and write paths
    - Custom callbacks intercepting file I/O for encryption/decryption
    - Preserving shapefile structure and attributes through encode/decode cycle
    - Demonstrating round-trip data persistence with encryption

  Key TatukGIS API concepts shown here:
    TGIS_ViewerWnd              - main visual map control
    TGIS_LayerSHP              - vector layer for ESRI Shapefiles
    ReadEvent (callback)        - intercept layer read to decode data
    WriteEvent (callback)       - intercept layer write to encode data
    GIS.Add()                   - add layer to the viewer
    TGIS_LayerSHP.Open()       - open shapefile from disk
    TGIS_LayerSHP.SaveAs()     - export layer to new file
    Custom encoding algorithm   - XOR cipher (example of pluggable approach)
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
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    Toolbar1: TToolBar;
    btnOpenBase: TButton;
    btnEncode: TButton;
    btnOpenEncoded: TButton;
    btnCloseAll: TButton;
    procedure btnOpenBaseClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure btnOpenEncodedClick(Sender: TObject);
    procedure btnCloseAllClick(Sender: TObject);
  private
    { Private declarations }
    procedure doRead ( _sender : TObject ;
                       _pos    : Integer ;
                       _buffer : Pointer ;
                       _count  : Integer
                     ) ;
    procedure doWrite( _sender : TObject ;
                       _pos    : Integer ;
                       _buffer : Pointer ;
                       _count  : Integer
                     ) ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{ Opens the base world shapefile (WorldDCW) with country name labels. }
procedure TForm1.btnOpenBaseClick(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  GIS.Close ;

  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := TGIS_Utils.GisSamplesDataDirDownload +
             '\World\WorldDCW\world.shp' ;
  ll.Name := 'base';
  ll.Params.Labels.Field := 'NAME' ;
  GIS.Add(ll) ;
  GIS.FullExtent ;
end;

{ Exports the base layer to encoded.shp via ImportLayer.
  The WriteEvent callback applies an incrementing-XOR cipher to every byte as it is written. }
procedure TForm1.btnEncodeClick(Sender: TObject);
var
  ls : TGIS_LayerVector ;
  ld : TGIS_LayerSHP ;
begin
  if GIS.IsEmpty then begin
    ShowMessage( 'Open Base layer first' ) ;
    exit ;
  end ;

  ls := TGIS_LayerVector( GIS.Items[0] ) ;
  if ls.Name = 'encoded' then begin
    ShowMessage( 'This layer is alredy encoded, Open Base layer' ) ;
    exit ;
  end ;

  ld := TGIS_LayerSHP.Create ;
  try
    ld.ReadEvent := doRead ;
    ld.WriteEvent := doWrite ;
    ld.Path := 'encoded.shp' ;
    ld.ImportLayer( ls, GIS.Extent, TGIS_ShapeType.Polygon, '', False );
  finally
    ld.Free ;
  end;
end;

{ Opens the encoded shapefile with ReadEvent/WriteEvent wired so the XOR cipher is reversed
  transparently on every read.  The layer is tinted green. }
procedure TForm1.btnOpenEncodedClick(Sender: TObject);
var
  ll : TGIS_LayerSHP ;
begin
  GIS.Close ;

  // add states layer
  ll := TGIS_LayerSHP.Create ;
  ll.Path := 'encoded.shp' ;
  ll.Name := 'encoded' ;
  ll.ReadEvent := doRead ;
  ll.WriteEvent := doWrite ;
  ll.Params.Labels.Field := 'NAME' ;
  ll.Params.Area.Color := TGIS_Color.Green ;
  GIS.Add(ll) ;
  GIS.FullExtent ;
end;

{ Closes all loaded layers. }
procedure TForm1.btnCloseAllClick(Sender: TObject);
begin
  GIS.Close ;
end;

{ Decodes each byte by XOR-ing it with (position + index) mod 256, reversing the encoding. }
procedure TForm1.doRead( _sender : TObject ;
                         _pos    : Integer ;
                         _buffer : Pointer ;
                         _count  : Integer
                       ) ;
var
  i : Integer ;
begin
  for i:= 0 to _count -1 do
  begin
    PByte(NativeInt(_buffer) + i)^
      := PByte(NativeInt(_buffer) + i)^ xor ( Integer( _pos + i ) mod 256 ) ;
  end ;
end ;

{ Encodes each byte by XOR-ing it with (position + index) mod 256. }
procedure TForm1.doWrite( _sender : TObject ;
                          _pos    : Integer ;
                          _buffer : Pointer ;
                          _count  : Integer
                        ) ;
var
  i : Integer ;
begin
  for i:= 0 to _count -1 do
  begin
    PByte(NativeInt(_buffer) + i)^
      := PByte(NativeInt(_buffer) + i)^ xor  ( Integer( _pos + i ) mod 256 ) ;
  end ;
end ;


end.
