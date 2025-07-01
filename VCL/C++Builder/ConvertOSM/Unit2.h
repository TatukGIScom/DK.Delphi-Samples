//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to convert OSM file.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit2H
#define Unit2H
//---------------------------------------------------------------------------
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.Graphics.hpp>
#include "FileCtrl.hpp"
#include <Winapi.Windows.hpp>
#include <Winapi.Messages.hpp>
#include "GisLayerVector.hpp"
#include "GisLayerOSM.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerSqlAdo.hpp"
#include "GisLayerSqlSqlite.hpp"
#include "GisInternals.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "Vcl.GisViewerBmp.hpp"
#include "ShlObj.hpp"
#include "System.hpp"
#include <windowsx.h>
#include <math.h>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TStatusBar *stat1 ;
	TMemo       *mmolog ;
	TGroupBox   *grpTTKLS ;
	TButton     *btnOSM ;
	TEdit       *edtOSMPath ;
	TGroupBox   *grp1 ;
	TButton     *btnSelectFolder ;
	TEdit       *edExportDir ;
	TGroupBox   *grp2 ;
	TCheckBox   *cbel ;
	TCheckBox   *cbep ;
	TCheckBox   *cbepp ;
	TButton     *btnConvert ;
	TRadioGroup *rgLayerFormat ;
	TOpenDialog *dlgOpenOSM ;

	void __fastcall btnConvertClick(TObject *Sender);
	void __fastcall btnOSMClick(TObject *Sender);
	void __fastcall btnSelectFolderClick( TObject *Sender );
private:	// User declarations
  TGIS_ViewerBmp* vwr ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	TGIS_LayerVector* __fastcall CreateLayer(int _ltype,
											String _ext );
	String __fastcall BrowseDialog();
	void __fastcall doBusy( TObject *_sender, int _pos, int _end, bool &_abort ) ;
	void __fastcall doLog ( const String _txt ) ;
	void __fastcall convertOSM( const String _osmPath, const String _exportPath, const int _ltype ) ;
    double __fastcall trunc(double d);

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
