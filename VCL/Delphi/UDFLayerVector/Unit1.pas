//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide UDF Layer support.
}
unit Unit1;

interface

uses
  System.SysUtils,
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

  //GisLicense,
  GisTypes,
  GisClasses,
  GisEditor,
  GisLayerVector,
  GisLayerVectorUDF,
  GisRtl,
  GisStreams,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    GIS: TGIS_ViewerWnd;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    btnFullExtent: TToolButton;
    ToolButton2: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    chkInMemory: TCheckBox;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkInMemoryClick(Sender: TObject);
  private
    { Private declarations }
    FUDF      : TGIS_BufferedFileStream ;
    FUDFLine  : String ;
    tkn       : TGIS_Tokenizer ;
    currUID   : Integer ;

    procedure createUDFLayer ;
    function  createShape  : TGIS_Shape ;
  public
    procedure GetShapeGeometry (      _sender   : TObject ;
                                      _uid      : TGIS_Uid ;
                                      _inMemory : Boolean ;
                                      _cursor   : Integer ;
                                  var _shp      : TGIS_Shape
                               ) ;
    procedure GetLayerExtent   (      _sender   : TObject ;
                                  var _extent   : TGIS_Extent
                               ) ;
    procedure GetShapeField    (      _sender   : TObject ;
                                      _field    : String  ;
                                      _uid      : TGIS_Uid ;
                                      _cursor   : Integer ;
                                  var _value    : Variant
                               ) ;
    procedure LayerMoveFirst   (      _sender      : TObject ;
                                      _cursor      : Integer          ;
                                const _extent      : TGIS_Extent      ;
                                      _query       : String = ''      ;
                                      _shape       : TGIS_Shape = nil ;
                                      _de9i        : String = ''      ;
                                      _skipDeleted : Boolean = True
                               ) ;
    procedure LayerEof         (      _sender   : TObject ;
                                      _cursor   : Integer ;
                                  var _eof      : Boolean
                               ) ;
    procedure LayerMoveNext    (      _sender   : TObject ;
                                      _cursor   : Integer
                               ) ;
    procedure LayerGetStructure(      _sender  : TObject
                               ) ;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.chkInMemoryClick(Sender: TObject);
begin
  GIS.Close ;
  createUDFLayer ;

  GIS.FullExtent ;
end;

procedure TForm1.createUDFLayer;
var
  udf : TGIS_LayerVectorUDF ;
begin
  udf := TGIS_LayerVectorUDF.Create ;
  udf.Name := 'UDF' ;
  udf.GetShapeGeometryEvent      := GetShapeGeometry;
  udf.GetLayerExtentEvent        := GetLayerExtent;
  udf.GetShapeFieldEvent         := GetShapeField ;
  udf.GetLayerStructureEvent     := LayerGetStructure;
  udf.LayerMoveFirstEvent        := LayerMoveFirst;
  udf.LayerMoveNextEvent         := LayerMoveNext ;
  udf.LayerEofEvent              := LayerEof ;
  udf.InMemory                   := chkInMemory.Checked ;

  udf.Params.Labels.Field := 'NAME' ;

  GIS.Add( udf );
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  FUDF := TGIS_BufferedFileStream.Create( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\UDF\places.txt', TGIS_StreamMode.Read );
  tkn  := TGIS_Tokenizer.Create ;

  GIS.Close ;
  createUDFLayer ;

  GIS.FullExtent ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FUDF.Free ;
  tkn.Free ;
end;

procedure TForm1.GetLayerExtent(_sender: TObject;
  var _extent: TGIS_Extent);
begin
  _extent := TGIS_Utils.GisExtent( 14.20182, 49.296146, 24.040955, 54.827629 );
end;


procedure TForm1.GetShapeField(      _sender     : TObject ;
                                     _field      : String  ;
                                     _uid        : TGIS_Uid ;
                                     _cursor     : Integer ;
                                 var _value      : Variant
                              ) ;
var
  eof : Boolean ;
begin
  // synchronise record
  if _uid <> currUID then
  begin
    LayerMoveFirst( _sender, _cursor, TGIS_Utils.GisWholeWorld );
    LayerEof( nil, _cursor, eof ) ;
    while not eof do
    begin
      tkn.ExecuteEx( FUDFLine );

      if Tkn.Result.Count = 0 then exit ;

      currUID := StrToInt( tkn.Result[ 0 ] ) ;

      if currUID = _uid then
        break ;

      LayerMoveNext( nil, _cursor );
      LayerEof( nil, _cursor, eof ) ;
    end;
  end;

  _value := tkn.Result[ 3 ] ;
end;

function TForm1.createShape: TGIS_Shape;
begin
  Result := TGIS_ShapePoint.Create;
  Result.Reset ;
  Result.Lock( TGIS_Lock.Projection );
  Result.AddPart ;
  Result.AddPoint( TGIS_Utils.GisPoint( DotStrToFloat( tkn.Result[ 1 ] ),
                             DotStrToFloat( tkn.Result[ 2 ] )
                            )
                  );
  Result.Unlock ;
end;

procedure TForm1.GetShapeGeometry(     _sender   : TObject ;
                                       _uid      : TGIS_Uid ;
                                       _inMemory : Boolean ;
                                       _cursor   : Integer ;
                                   var _shp      : TGIS_Shape
                                 ) ;
begin
  tkn.ExecuteEx( FUDFLine );

  if Tkn.Result.Count = 0 then exit ;

  // we expect format : [0] - UID, [1] - X, [2] - Y, [3] - NAME

  currUID := StrToInt( tkn.Result[ 0 ] ) ;
  _shp    := createShape ;
end;

procedure TForm1.LayerEof(      _sender    : TObject ;
                                _cursor    : Integer ;
                            var _eof       : Boolean
                          ) ;
begin
  _eof := FUDF.Eof ;
end;

procedure TForm1.LayerGetStructure( _sender: TObject );
begin
  TGIS_LayerVector( _sender ).AddField( 'NAME', TGIS_FieldType.String, 1, 0 );
end;

procedure TForm1.LayerMoveFirst(       _sender      : TObject          ;
                                       _cursor      : Integer          ;
                                 const _extent      : TGIS_Extent      ;
                                       _query       : String = ''      ;
                                       _shape       : TGIS_Shape = nil ;
                                       _de9i        : String = ''      ;
                                       _skipDeleted : Boolean = True
                               ) ;
begin
  FUDF.Position := 0 ;

  FUDFLine := '' ;
end;

procedure TForm1.LayerMoveNext( _sender : TObject ;
                                _cursor   : Integer
                              );
begin
  FUDFLine := FUDF.ReadLine ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;


procedure TForm1.btnDragClick(Sender: TObject);
begin
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

end.
