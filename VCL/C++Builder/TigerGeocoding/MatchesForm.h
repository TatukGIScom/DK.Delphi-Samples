//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef MatchesFormH
#define MatchesFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Contnrs.hpp>
#include <Forms.hpp>
#include <GisTypes.hpp>
//---------------------------------------------------------------------------
class TFormMatches : public TForm
{
__published:	// IDE-managed Components
        TMemo *memMatches;
private:	// User declarations
public:		// User declarations
        __fastcall TFormMatches(TComponent* Owner);
        void ShowMatches ( TGIS_ObjectList *_resolvedAddresses,
                           TGIS_ObjectList *_resolvedAddresses2 ) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TFormMatches *FormMatches;
//---------------------------------------------------------------------------
#endif
