//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide SQL Layer advanced support.
//  Edit gistest.ttkls to provied your database access
//  You can use *.ttkls as any other layer (for example open in editor)
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnOpenProjectClick(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject" ) ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

String __fastcall TForm1::getGISTESTPath( const bool _useLogging ){

  String str;
  AnsiString strtmp ;

  if( _useLogging )
    str = "\nLogging=True\n" ;
  else
    str = "" ;

  return strtmp.sprintf( "[TatukGIS Layer]\n"
                         "Storage=Native\n"
                         "LAYER=GISTEST\n"
                         "DIALECT=SQLITE\n"
                         "Sqlite=%sgistest.sqlite\n"
                         "ENGINEOPTIONS=16%s\n.ttkls",
                         currDir.c_str(), str.c_str()
                   ) ;

}

void __fastcall TForm1::btnWriteProjectClick(TObject *Sender)
{
  TGIS_LayerVectorSqlAbstract *lv  ;
  TStrings *lst;
  int i  ;
  TGIS_Layer *la ;
  TGIS_Config *cfg  ;
  AnsiString str ;

  if ( GIS->IsEmpty ) return ;

  lst = new TStringList ;
  try{
    for( i = 0 ; i<= GIS->Items->Count-1 ; i++ ){
      la = ( TGIS_Layer *)( GIS->Items->Items[i] ) ;
      la->Path = str.sprintf( "[TatukGIS Layer]\\nStorage=Native\\n"
                         "Sqlite=<#PATH#>gistest.sqlite\\n"
                         "Dialect=SQLITE\\nLayer=%s\\nStyle=%s\\n.ttkls",
                         TGIS_Utils::GisCanonicalSQLName( la->Name ).c_str(), TGIS_Utils::GisCanonicalSQLName( la->Name).c_str()
                        ) ;
    }
    cfg = TGIS_ConfigFactory::CreateConfig( NULL, "test.ttkproject" ) ;
    try
    {
      GIS->SaveProjectAsEx( cfg, "" ) ;
      cfg->GetStrings( lst );
    }
    __finally {
      delete cfg ;
    }

    lv = new TGIS_LayerSqlSqlite ;
    lv->Path =  getGISTESTPath( false ) ;
    GIS->Add( lv ) ;
    lv->CreateProjectTable() ;
    lv->WriteProject( "POLAND", "Map of Poland", lst->Text ) ;
  }
  __finally{
    delete lst ;
  }
}

//---------------------------------------------------------------------------

void __fastcall TForm1::btnWriteStylesClick(TObject *Sender)
{
  TGIS_LayerVectorSqlAbstract *lv  ;
  TStrings *lst ;
  TGIS_LayerAbstract *la  ;
  TGIS_Layer *lp ;
  TGIS_Config *cnf ;

  if ( GIS->IsEmpty ) return;

  lv = ( TGIS_LayerVectorSqlAbstract *)( GIS->Get("GISTEST") ) ;
  lv->CreateStyleTable() ;

  lst = new TStringList ;
  try{
    for( int i = 0; i< GIS->Items->Count ; i++ ){
      la = GIS->Items->Items[i];
      lp = ( TGIS_Layer *)( la ) ;
      cnf = (TGIS_Config *)(GIS->ProjectFile) ;
      cnf->SetLayer( lp ) ;
      lst->Clear() ;
      lp->ParamsList->SaveToStrings( lst ) ;
      lv->WriteStyle( TGIS_Utils::GisCanonicalSQLName( lp->Name ), lp->Caption, lst->Text ) ;
    }
  }
  __finally{
    delete lst ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnReadStylesClick(TObject *Sender)
{
  TGIS_LayerVectorSqlAbstract *lv ;
  TStrings *lst ;

  lv = ( TGIS_LayerVectorSqlAbstract *)( GIS->Get("GISTEST") ) ;
  if( lv == NULL ){
    lv = new TGIS_LayerSqlSqlite ;
    lv->Path =  getGISTESTPath( false ) ;
    GIS->Add( lv ) ;
  }

  lst = lv->GetAvailableStyles() ;
  try{
    cbbStyles->Items->AddStrings( lst );
  }
  __finally {
    delete lst ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnLoggingClick(TObject *Sender)
{
  TGIS_LayerSqlSqlite *lsql ;
  int i ;
  TGIS_Shape *shp  ;
  TStrings *logs ;

  GIS->Close() ;

  lsql = new TGIS_LayerSqlSqlite;
  lsql->Path =  getGISTESTPath( true ) ;
  lsql->SetCSByEPSG( 4326 ) ;
  lsql->Build( lsql->Path,
              TGIS_Utils::GisExtent( 14, 49, 24, 55),
              TGIS_ShapeType::Point,
              TGIS_DimensionType::XY
             ) ;
  GIS->Add( lsql ) ;
  for(  i=1 ; i<=10 ; i++ ){
    shp = lsql->CreateShape( TGIS_ShapeType::Point, TGIS_DimensionType::XY ) ;
    shp->AddPart() ;
    shp->AddPoint( TGIS_Utils::GisPoint( 14+Random(10),49+Random(6) ) ) ;
  }
  GIS->SaveData() ;
  GIS->FullExtent() ;
  GIS->InvalidateWholeMap() ;

  logs = lsql->GetLogs() ;
  try{
    mmoLog->Lines->AddStrings( logs ) ;
  }
  __finally{
    delete logs ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnWriteLayersClick(TObject *Sender)
{
  int i     ;
  TGIS_LayerVector *la  ;
  TGIS_LayerSqlSqlite *lsql ;
  AnsiString str ;

  if( GIS->IsEmpty ) return ;

  for( i=0 ; i<=GIS->Items->Count-1 ; i++ ){
    la = ( TGIS_LayerVector * )( GIS->Items->Items[i] ) ;

    lsql = new TGIS_LayerSqlSqlite ;
    try{
      lsql->Path = str.sprintf( "[TatukGIS Layer]\n"
                           "Storage=Native\n"
                           "LAYER=%s\n"
                           "DIALECT=SQLITE\n"
                           "Sqlite=%sgistest.sqlite\n"
                           "ENGINEOPTIONS=16\n.ttkls",
                           TGIS_Utils::GisCanonicalSQLName( la->Name ).c_str(), currDir.c_str()
                    ) ;

      lsql->SetCSByEPSG( la->CS->EPSG ) ;
      lsql->ImportLayer( la, la->Extent, TGIS_ShapeType::Unknown, "", false ) ;
    }
    __finally{
      delete lsql;
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnApplyStyleClick(TObject *Sender)
{
    TGIS_LayerVectorSqlAbstract *lv ;

    if (GIS->IsEmpty) {
        return;
    }
    lv = ( TGIS_LayerVectorSqlAbstract *)(GIS->Get("GISTEST") );
    if(lv == NULL) return;

    lv->ApplyStyle( lv->ReadStyle(cbbStyles->Items[cbbStyles->ItemIndex].ToString() ) );
    GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnReadProjectsClick(TObject *Sender)
{
    TGIS_LayerVectorSqlAbstract *lv ;
    TStrings *lst ;

    lv = ( TGIS_LayerVectorSqlAbstract *)( GIS->Get("GISTEST") ) ;
    if (lv == NULL) {
        lv = new TGIS_LayerSqlSqlite();
        lv->Path = getGISTESTPath( false ) ;
        GIS->Add( lv ) ;
    }

    lst = lv->GetAvailableProjects() ;
    try{
        cbbProjects->Items->AddStrings( lst ) ;
    }
    __finally{
        delete lst ;
    }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnGetProjectClick(TObject *Sender)
{
  TGIS_LayerVectorSqlAbstract *lv ;
  TStringList *tkn  ;
  String name ;

  lv = ( TGIS_LayerVectorSqlAbstract *)( GIS->Get("GISTEST") ) ;
  if (lv == NULL ) return ;

  tkn = new TStringList() ;
  try {
    tkn->Add( "PATH=" + ConstructParamString( currDir ) ) ;
    name = cbbProjects->Items[cbbProjects->ItemIndex].ToString() ;
    if ( name == "" )
      name = "POLAND";
    GIS->OpenEx( lv->GetProject(name, tkn), ".ttkproject" ) ;
  } __finally{
    delete tkn ;
  }

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::traceLog(const String S){
    mmoLog->Lines->Add(S);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAttachTraceLogClick(TObject *Sender)
{
  TGIS_LayerSqlSqlite *lsql  ;

  GIS->Close() ;

  lsql = new TGIS_LayerSqlSqlite() ;
  lsql->Path = getGISTESTPath( false ) ;
  lsql->SQLExecuteEvent = traceLog ;

  GIS->Add( lsql ) ;
  GIS->FullExtent() ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnBuildLayerClick(TObject *Sender)
{
    TGIS_LayerSqlSqlite *lsql ;

    lsql = new TGIS_LayerSqlSqlite();
    try {
        lsql->SetCSByEPSG( 4326 ) ;
        lsql->Path = getGISTESTPath( false ) ;
        lsql->Build( lsql->Path, TGIS_Utils::GisExtent( 14, 49, 24, 55),
                TGIS_ShapeType::Point, TGIS_DimensionType::XY
               ) ;
    }catch(Exception &exception){
    // layer can exist
    }

  GIS->Add( lsql ) ;
  GIS->FullExtent() ;
  GIS->InvalidateWholeMap() ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnDragClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
    currDir = GetPathDirSep( GetFilePath( Application->ExeName ) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
    GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

