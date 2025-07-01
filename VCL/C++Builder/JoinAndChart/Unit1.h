//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================


#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <utilcls.h>
#include <ADODB.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TToolBar *ToolBar1;
    TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TComboBox *cmbValues;
	TComboBox *cmbSize;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	TToolButton *btnZoomOut;
	TToolButton *ToolButton1;
	TToolButton *ToolButton2;
	TToolButton *ToolButton3;
	TComboBox *cmbStyle;
	TADOConnection *ADOConnection;
	TADOQuery *ADOQuery;
		void __fastcall FormDestroy(TObject *Sender);
		void __fastcall btnFullExtentClick(TObject *Sender);
		void __fastcall btnZoomInClick(TObject *Sender);
		void __fastcall btnZoomOutClick(TObject *Sender);
		void __fastcall cmbChange(TObject *Sender);
		void __fastcall FormCreate(TObject *Sender);
public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
