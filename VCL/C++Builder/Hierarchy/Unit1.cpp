//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
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


void __fastcall TForm1::Button1Click(TObject *Sender)
{
  IGIS_HierarchyGroup *group  ;
  Integer i    ;
  TStrings *list  ;

  GIS->Close() ;
  GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Groups ;

  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\Poland\\DCW\\poland.ttkproject", False ) ;

  GIS->Hierarchy->ClearGroups() ;

  group = GIS->Hierarchy->CreateGroup( "My group" ) ;

  for (i = 0 ; i<((int)(GIS->Items->Count / 2 ) - 1) ;i++ )
    group->AddLayer(GIS->Items->Items[i] ) ;

  for ( i = 0 ; i<(GIS->Items->Count / 2 )- 1 ;i++ )
    group->DeleteLayer(GIS->Items->Items[i] ) ;

  group = GIS->Hierarchy->CreateGroup( "Root" ) ;
  group->CreateGroup( "Leaf" ) ;

  GIS->Hierarchy->Groups["Leaf"]->CreateGroup("node")->AddLayer( GIS->Get( "city1") ) ;

  GIS->Hierarchy->MoveGroup( "Root", "My group" ) ;

  group = GIS->Hierarchy->CreateGroup("Poland") ;
  group = group->CreateGroup("Waters") ;
  group->AddLayer( GIS->Get( "Lakes") ) ;
  group->AddLayer( GIS->Get( "Rivers") ) ;

  group = GIS->Hierarchy->Groups["Poland"]->CreateGroup("Areas") ;
  group->AddLayer( GIS->Get( "city") ) ;
  group->AddLayer( GIS->Get( "Country area") ) ;

  GIS->Hierarchy->AddOtherLayers() ;

  list = new TStringList;
  try
  {
    list->Add( "Poland\\Waters=Lakes;Rivers" ) ;
    list->Add( "Poland\\Areas=city;Country area" ) ;

    GIS->Hierarchy->ClearGroups() ;
    GIS->Hierarchy->ParseHierarchy( list, TGIS_ConfigFormat::Ini ) ;
  }
  __finally
  {
    delete list;
  };

  GIS_ControlLegend->Update() ;
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

