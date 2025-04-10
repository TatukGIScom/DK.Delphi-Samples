//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//  How to create format converter
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#include <iostream>
#include <conio.h>
#include <utilcls.h>

#undef EOF
//#include "GisLicense.hpp"
#include "GisLayerVector.hpp"
#include "GisRegistredLayers.hpp"
#include "GisAllLayers.hpp"
#include "VCL.GisViewerBMP.hpp"
#include "GisConfigIni.hpp"
#include "GisConfigXml.hpp"
#include "GisConfig.hpp"
#include "GisFunctions.hpp"
#include "GisInternals.hpp"
#include "GisLayerPixel.hpp"
#include "GisLayerPixelStoreSqlite.hpp"
#include "GisLayerPixelSql.hpp"
#include "GisLayerSqlSqlite.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerVectorSql.hpp"
#include "GisRegistredLayers.hpp"
#include "GisResource.hpp"
#include "GisRtl.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisInterfaces.hpp"

#define  TTKLS L"[TatukGIS Layer]\nStorage=Native\nDialect=SQLITE\n" \
		  L"Layer=%s\nSqlite=%s\nENGINEOPTIONS=16\n"\
		  GIS_TTKLS_EXT

#pragma hdrstop
using namespace std;

//---------------------------------------------------------------------------

#pragma argsused
int main(int argc, char* argv[])
{
  TBitmap *bmp    ;
  TGIS_ViewerBmp *vwr    ;
  TGIS_LayerPixel *lp     ;
  TGIS_LayerVector *lv     ;
  TGIS_LayerVectorSqlAbstract *lsv    ;
  int i,p    ;
  String path  ;
  String sprj ;
  String dbf ;
  TGIS_Config *prj ;
  TStringList *lst ;
  TStringList *lsts ;
  bool embed ;
  String tmp ;

  CoInitialize( NULL );

  cout<< "TatukGIS Samples - Project->Sqlite converter." << endl;
  cout<< "Converts vector layers of a project into sqlite database." << endl;
  
  if ( ParamCount() < 2 ) {
    cout << "Usage : "<< endl ;
    cout << "  project2sqlite InputProject OutputProject [db embedded|ttkls] "<< endl ;
    cout << "Parameters:"<< endl ;
    cout << "  InputProject OutputProject - paths to project files (must have the same extension)"<< endl ;
    cout << "Optional parameters:"<< endl;
    cout << "  db - path to sqlite database"<< endl;
    cout << "  embedded|ttkls - use embedded path to database in project or create ttkls"<< endl ;
    cin.get();
    return 0 ;
  }

  bmp = new TBitmap() ;
  bmp->Width  = 128 ;
  bmp->Height = 128 ;
  vwr = new TGIS_ViewerBmp(bmp) ;
 try{
    try{
      vwr->Open( ParamStr(1) ) ;
      cout << " Opening project file: " ;
      cout << ParamStr(1).c_str();
      cout << " (" ;
      cout << IntToStr(vwr->Items->Count).c_str();
      cout << " layers)" ;
      sprj = ParamStr(2) ;
      path = GetFilePath( sprj ) ;
      if ( !DirectoryExists( path ) ){
        tmp.sprintf( L"### ERROR: Directory %s not found", path.c_str() ) ;
        cout << tmp.c_str() ;
        return 0 ;
      }

	  prj = TGIS_ConfigFactory::CreateConfig( NULL, sprj ) ;

      lst = new TStringList() ;
      if( vwr->ProjectFile != NULL){
		( ( TGIS_Config *)(vwr->ProjectFile) )->GetStrings( lst );

	  if (prj->ConfigFormat == TGIS_ConfigFormat::Ini) {
		( ( TGIS_ConfigProjectIni *)prj)->IniObj->SetStrings( lst )  ;
	  }
	  else {
		( ( TGIS_ConfigProjectXml *)prj)->ClearActiveSection() ;
        ( ( TGIS_ConfigProjectXml *)prj)->IniObj->SetStrings( lst ) ;
      }

      lst->Clear() ;
      lsts = new TStringList();

      dbf = ParamStr(3) ;
      if( IsStringEmpty( dbf ) ){
        dbf = "Layers.sqlite" ;
      }

      embed = ParamStr(4) != "ttkls" ;

      SetCurrentDir( path ) ;
      cout << "  Importing layers :"  ;
      for(int i = 0 ; i<vwr->Items->Count-1; i++ ){
        if( vwr->Items->Items[i]->InheritsFrom(__classid( TGIS_LayerVector ) ) ) {
          lv = ( TGIS_LayerVector *)( vwr->Items->Items[i] ) ;
          cout << "  -> " ;
          cout << lv->Name.c_str() ;
          cout << "..." ;

          p = lst->IndexOf( lv->Path ) ;
          if( p >=0 ){
            prj->SetLayer(lv);
			if (prj->ConfigFormat == TGIS_ConfigFormat::Ini) {
			  prj->WriteString( GIS_INI_PATH, lsts[p].ToString(), "" ) ;
            }
            else {
			( ( TGIS_ConfigProjectXml *)prj)->IniObj->SetLayer( lv->Name ) ;
			( ( TGIS_ConfigProjectXml *)prj)->IniObj->WriteAttribute( GIS_INI_PATH, lsts[p].ToString() ) ;
            }
          }
          else{
            lsv = new TGIS_LayerSqlSqlite();
            try{
              lsv->Name = lv->Name ;
              lsv->CS = lv->CS ;
              if( embed ){
                tmp.sprintf(  TTKLS,
							  TGIS_Utils::GisCanonicalSQLName(lv->Name).c_str(),
							  GetPathRelative( path, GetPathDirSep( path ) +
											dbf
							  ).c_str()
							 );
              lsv->Path = tmp ;
              }else{
                lsv->Path = GetPathDirSep( path ) +
                            GetFileNameNoExt( lv->Path ) + GIS_TTKLS_EXT ;

              lsv->SQLParameter[ "PRAGMA synchronous"  ] = "OFF" ;
              lsv->SQLParameter[ "PRAGMA journal_mode" ] = "OFF" ;
              lsv->ImportLayer( lv, lv->Extent, TGIS_ShapeType::Unknown, "", false ) ;

              prj->SetLayer(lv);
			  if (prj->ConfigFormat == TGIS_ConfigFormat::Ini) {
                prj->WriteString( GIS_INI_PATH, lsv->Path, "" ) ;
			  }
              else {
	        ( ( TGIS_ConfigProjectXml *)prj)->IniObj->SetLayer( lv->Name ) ;
			( ( TGIS_ConfigProjectXml *)prj)->IniObj->WriteAttribute( GIS_INI_PATH, lsv->Path ) ;
              }

              lst->Add( lv->Path ) ;
              lsts->Add( lsv->Path ) ;
              }
            }__finally{
              delete lsv;
            }
          }
          cout << "ok!" ;
        }
        else if( vwr->Items->Items[i]->InheritsFrom(__classid( TGIS_LayerPixel ))){
          lp =( TGIS_LayerPixel *)( vwr->Items->Items[i] ) ;
          cout << "  -> " ;
          cout << lp->Name.c_str() ;
          cout << "..." ;
          // TODO - make ImportLayer for pixelstore
          cout << "skipped!"  ;
        }

      }

      cout << " Saving new project: " ;
      cout << sprj.c_str();
      cin.get();
      prj->Save() ;
      delete prj ;
      delete lst ;
      delete lsts ;
      }
    }__finally{
      delete bmp ;
      delete vwr ;
    }
 }
  catch( Exception& e ){
    cout << e.Message.c_str() ;
  }
}
//---------------------------------------------------------------------------

