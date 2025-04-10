//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================


#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
		TGIS_ViewerWnd *GIS;
		TToolBar *ToolBar1;
		TStatusBar *StatusBar1;
		TTrackBar *TrackBar1;
		TToolButton *btnPlus;
		TToolButton *btnMinus;
		TImageList *ImageList1;
		void __fastcall btnMinusClick(TObject *Sender);
		void __fastcall btnPlusClick(TObject *Sender);
		void __fastcall TrackBar1Change(TObject *Sender);
		void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
		  int X, int Y);
private:	// User declarations
public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
		int shp_id ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
