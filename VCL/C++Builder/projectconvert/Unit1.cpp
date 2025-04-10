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
  TGIS_ViewerBmp *vwr  ;
  String path          ;

  CoInitialize( NULL );

  if ( ParamCount() != 1 ) {
    cout << "TatukGIS Samples - TTKGP -> TTKPROJECT converter" << endl ;
    cout << "Enter path of the TTKGP project. TTKPROJECT output will be placed in the same directory."<< endl ;
    cout << "TTKGP file will be kept in its place after conversion."<< endl ;
    cout << "Put directories with filenames and .TTKGP extension into parameters."<< endl;
    cin.get();
    return 0 ;
  }

  vwr = new TGIS_ViewerBmp() ;
  path = ParamStr(1);
  vwr->Open( path );
  path = TPath::ChangeExtension( path, ".ttkproject" );
  vwr->SaveProjectAs( path );
  delete vwr ;
}
//---------------------------------------------------------------------------
 
