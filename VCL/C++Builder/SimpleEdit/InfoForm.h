//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to provide editing functionality.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef InfoFormH
#define InfoFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Grids.hpp>
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "VCL.GisControlAttributes.hpp"

//---------------------------------------------------------------------------
class TfrmInfo : public TForm
{
__published:	// IDE-managed Components
        TGIS_ControlAttributes *GISAttributes;
private:	// User declarations
        TGIS_Shape *shpObj ;
        TGIS_LayerVector *layerObj ;
public:		// User declarations
        __fastcall TfrmInfo(TComponent* Owner);
    void ShowInfo( TGIS_Shape * const _shp ) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmInfo *frmInfo;
//---------------------------------------------------------------------------
#endif
