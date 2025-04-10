//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to add layer to the map.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------



void __fastcall TForm1::FormCreate(TObject *Sender)
{
  FUDF = new TGIS_BufferedFileStream( GisSamplesDataDirDownload() + "\\Samples\\UDF\\places.txt", TGIS_StreamMode::Read );
  tkn  = new TGIS_Tokenizer ;

  GIS->Close() ;
  createUDFLayer() ;

  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::chkInMemoryClick(TObject *Sender)
{
  GIS->Close() ;
  createUDFLayer() ;

  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  delete FUDF ; 
  delete tkn ; 
}

void __fastcall  TForm1::createUDFLayer()
{
  TGIS_LayerVectorUDF *udf ;

  udf = new TGIS_LayerVectorUDF ;
  udf->Name = "UDF" ;
  udf->GetShapeGeometryEvent      = GetShapeGeometry;
  udf->GetLayerExtentEvent        = GetLayerExtent;
  udf->GetShapeFieldEvent         = GetShapeField ;
  udf->GetLayerStructureEvent     = LayerGetStructure;
  udf->LayerMoveFirstEvent        = LayerMoveFirst;
  udf->LayerMoveNextEvent         = LayerMoveNext ;
  udf->LayerEofEvent              = LayerEof ;
  udf->InMemory                   = chkInMemory->Checked ;

  udf->Params->Labels->Field = "NAME" ;

  GIS->Add( udf );
}

TGIS_Shape  * __fastcall TForm1::createShape()
{
    TGIS_ShapePoint *pt ;

  pt = new TGIS_ShapePoint ( NULL, NULL, false, -1, NULL, TGIS_DimensionType::XY ) ;
  pt->Reset() ;
  pt->Lock( TGIS_Lock::Projection );
  pt->AddPart() ;
  pt->AddPoint( GisPoint( DotStrToFloat( tkn->Result->Strings[ 1 ] ),
                          DotStrToFloat( tkn->Result->Strings[ 2 ] )
                         )
                  );
  pt->Unlock() ;
  return pt ;
}

void __fastcall TForm1::GetShapeGeometry(   TObject * _sender ,
                                          __int64 _uid        ,
                                          Boolean _inMemory   ,
                                          Integer _cursor     ,
                                          TGIS_Shape * &_shp
                                   )
{
  tkn->ExecuteEx( FUDFLine );

  if ( tkn->Result->Count == 0 ) return ;

  // we expect format : [0] - UID, [1] - X, [2] - Y, [3] - NAME

  currUID = StrToInt( tkn->Result->Strings[ 0 ] ) ;
  _shp    = createShape() ;
}

void __fastcall TForm1::GetLayerExtent  ( TObject * _sender ,
                                   TGIS_Extent  &_extent
                                       )
{
 _extent = GisExtent( 14.20182, 49.296146, 24.040955, 54.827629 );
}

void __fastcall TForm1::GetShapeField   ( TObject * _sender  ,
                                          String _field      ,
                                          __int64 _uid       ,
                                          Integer _cursor    ,
                                          Variant &_value
                                        )
{

  Boolean eof  ;

  // synchronise record
  if ( _uid != currUID ) {
    LayerMoveFirst( _sender, _cursor, GisWholeWorld(), "", NULL, "", False );
    LayerEof( NULL, _cursor, eof ) ;
    while ( ! eof ){
      tkn->ExecuteEx( FUDFLine );

      if ( tkn->Result->Count == 0 ) return ;

      currUID = StrToInt( tkn->Result->Strings[ 0 ] ) ;

      if ( currUID == _uid ) return ;

      LayerMoveNext( NULL, _cursor );
      LayerEof( NULL, _cursor, eof ) ;
    };
  };

  _value = (Variant) tkn->Result->Strings[ 3 ] ;
}

void __fastcall TForm1::LayerMoveFirst  ( TObject           * _sender    ,
                                          int                 _cursor    ,
                                          const TGIS_Extent & _extent    ,
                                          String              _query     ,
                                          TGIS_Shape        * _shape     ,
                                          String              _de9i      ,
                                          Boolean             _skipDeleted
                                         )
{
  FUDF->Position = 0 ;

  FUDFLine = "" ;
}

void __fastcall TForm1::LayerEof        ( TObject * _sender  ,
                                          Integer   _cursor ,
                                          Boolean & _eof
                                )
{
  _eof = FUDF->Eof() ;
}

void __fastcall TForm1::LayerMoveNext   ( TObject * _sender ,
                                          Integer   _cursor
                                        )
{
 FUDFLine = FUDF->ReadLine() ;
}


void __fastcall TForm1::LayerGetStructure( TObject * _sender
                                         )
{
 (( TGIS_LayerVector *)( _sender ))->AddField( "NAME", TGIS_FieldType::String, 1, 0 );
}


void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
 GIS->FullExtent() ;
}


void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
 GIS->Mode = TGIS_ViewerMode::Zoom ;
}


void __fastcall TForm1::btnDragClick(TObject *Sender)
{
 GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

