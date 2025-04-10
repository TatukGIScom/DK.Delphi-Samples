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
#include <utilcls.h>
#undef EOF
//#include "GisLicense.hpp"
#include "GisLayerVector.hpp"
#include "GisRegistredLayers.hpp"
#include "GisAllLayers.hpp"
#include "VCL.GisViewerBMP.hpp"

#pragma hdrstop
using namespace std;

//---------------------------------------------------------------------------

#pragma argsused
int main(int argc, char* argv[])
{
  TGIS_LayerVector  *lm   ;
  TGIS_LayerVector  *ll   ;
  TGIS_ShapeType  shape_type  ;

  CoInitialize( NULL );
  cout << "TatukGIS Samples: ANY->ANY converter ( Vector layers only )" << endl ;
  if ( ParamCount() != 3 ) {
	cout << "Usage: ANY2SQL source_file destination shape_type" << endl ;
    cout << "Where shape_type:"<< endl ;
    cout << " A - Arc"         << endl ;
    cout << " G - polyGon"     << endl ;
    cout << " P - Point"       << endl ;
    cout << " M - Multipoint"  << endl ;
    return 1 ;
  }

  try {
  	ll = NULL ; 
  	lm = NULL ;
    try {
      lm  = ( TGIS_LayerVector *)TGIS_Utils::GisCreateLayer( "", ParamStr(1) );
      if ( lm == NULL) {
        cout << "### ERROR: File " << ParamStr(1).c_str() << " not found" << endl;
        return 1;
      }
	  lm->Open() ;	
		
      switch ( ParamStr(3)[1] ) {
        case 'A' : {
                     shape_type = TGIS_ShapeType::Arc        ;
                     break ;
                   }
        case 'G' : {
                     shape_type = TGIS_ShapeType::Polygon    ;
                     break ;
                   }
        case 'P' : {
                     shape_type = TGIS_ShapeType::Point      ;
                     break ;
                   }
        case 'M' : {
                     shape_type = TGIS_ShapeType::MultiPoint ;
                     break ;
                   }
        default  : {
                     shape_type = TGIS_ShapeType::Unknown        ;
                     break ;
                   }
      }

      ll  = ( TGIS_LayerVector *)TGIS_Utils::GisCreateLayer( "", ParamStr(2) );
      if ( ll == NULL) {
        cout << "### ERROR: File " << ParamStr(2).c_str() << " not found" << endl;
        return 1;
      }
      ll->ImportLayer( lm,
                       lm->Extent,
                       shape_type,
                       "",
                       False
                      ) ;
    }
    __finally {
      delete ll ;
      delete lm ;
   }
  }
  catch( const Exception &E ) {
    cout << E.Message.c_str() << endl ;
    return 1;
  }

  return 0;
}
//---------------------------------------------------------------------------
 
