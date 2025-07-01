//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to encode SHP Layer.
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

procedure TForm1.btnCloseAllClick(Sender: TObject);
begin
  GIS.Close ;
end;

// do decoding with incrementing XOR value
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

// do encoding with incrementing XOR value
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
