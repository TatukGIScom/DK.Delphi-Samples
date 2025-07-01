//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "MatchesForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TFormMatches *FormMatches;
//---------------------------------------------------------------------------
__fastcall TFormMatches::TFormMatches(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void TFormMatches::ShowMatches ( TGIS_ObjectList *_resolvedAddresses,
                                 TGIS_ObjectList *_resolvedAddresses2
                               )
{
  int        i, j    ;
  TStrings  *strings ;

  memMatches->Clear() ;
  strings = new TStringList ;

  if ( _resolvedAddresses )
    for ( i=0; i<_resolvedAddresses->Count; i++ ) {
      if ( i!=0 )
        memMatches->Lines->Add( "------------------------" );
      strings = (TStrings *)( _resolvedAddresses->Items[i] ) ;
      for ( j=0; j<strings->Count; j++ )
        memMatches->Lines->Add( strings->Strings[j] );
    }
  if ( _resolvedAddresses2 )
    for ( i=0; i<_resolvedAddresses2->Count; i++ ) {
      if ( i == 0 )
        memMatches->Lines->Add( "========================" );
      else
        memMatches->Lines->Add( "------------------------" );
      strings = (TStrings *)( _resolvedAddresses->Items[i] ) ;
      for ( j=0; j<strings->Count; j++ )
        memMatches->Lines->Add( strings->Strings[j] );
     } ;
}
//---------------------------------------------------------------------------

