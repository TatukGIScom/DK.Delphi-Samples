//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Info window.
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
#include <ExtCtrls.hpp>
#include "VCL.GisControlAttributes.hpp"
//---------------------------------------------------------------------------
class TfrmInfo : public TForm
{
__published:	// IDE-managed Components
  TGIS_ControlAttributes *GIS_ControlAttributes;
private:	// User declarations
  TGIS_Shape *shpObj;
public:		// User declarations
  __fastcall TfrmInfo(TComponent* Owner);
  void __fastcall ShowInfo( TGIS_Shape *_shp );
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmInfo *frmInfo;
//---------------------------------------------------------------------------
#endif
