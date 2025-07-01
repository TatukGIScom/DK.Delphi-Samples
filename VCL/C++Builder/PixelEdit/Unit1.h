//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  Use TGIS_LayerPixel.Lock & Loop to edit pixel content.
//
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <Math.hpp>

#include "GisAllLayers.hpp"
#include "GisUtils.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "GisCsFactory.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisLayerJpg.hpp"
#include "GisLayerGrd.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisControlLegend.hpp" ;

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS ;
	TToolBar *ToolBar1 ;
	TMemo *Memo1 ;
	TButton *btnProfile ;
	TButton *btnMinMax ;
	TButton *btnAvargeColor ;
	TButton *btnCreateBitmap ;
	TButton *btnCreateGrid ;
	TGIS_ControlLegend *GIS_Legend ;
	void __fastcall btnAvargeColorClick(TObject *Sender);
	void __fastcall btnCreateBitmapClick(TObject *Sender);
	void __fastcall btnCreateGridClick(TObject *Sender);
	void __fastcall btnMinMaxClick(TObject *Sender);
	void __fastcall btnProfileClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	double __fastcall trunc(double d) ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
