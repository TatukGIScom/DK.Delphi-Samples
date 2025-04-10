//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to provide WMTS Layer support.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef formWMTSH
#define formWMTSH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "GisFileWFS.hpp"
#include "GisFunctions.hpp"
#include "GisTypes.hpp"
#include "GisClasses.hpp"
#include "GisResource.hpp"
#include "GisLayerWMTS.hpp"
#include "GisCsSystems.hpp"
#include "GisCsFactory.hpp"
//---------------------------------------------------------------------------
class TfrmWMTS : public TForm
{
__published:	// IDE-managed Components
	TLabel *lbl5;
	TComboBox *cbLayers;
	TButton *btnAdd;
	TLabel *lbl4;
	TComboBox *cbServers;
	TButton *btnConnect;
	TCheckBox *cbInvertAxis;
	void __fastcall btnConnectClick(TObject *Sender);
	void __fastcall btnAddClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
private:	// User declarations
	TGIS_Tokenizer *tkn ;
public:		// User declarations
	__fastcall TfrmWMTS(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmWMTS *frmWMTS;
//---------------------------------------------------------------------------
#endif
