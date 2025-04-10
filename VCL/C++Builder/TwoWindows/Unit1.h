//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to support synchronized, two-windows display.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

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
#include <ExtCtrls.hpp>
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS_ViewerWnd1 ;
        TGIS_ViewerWnd *GIS_ViewerWnd2 ;
        TToolBar *ToolBar1 ;
		TSplitter *Splitter1 ;
		TButton *Button1 ;
		TCheckBox *CheckBox1 ;
		TToolButton *ToolButton2 ;
		void __fastcall Button1Click(TObject *Sender);
	void __fastcall GIS_ViewerWnd1VisibleExtentChangeEvent(TObject *Sender);
	void __fastcall GIS_ViewerWnd2VisibleExtentChangeEvent(TObject *Sender);
private:	// User declarations
		bool bSentinel;
public:		// User declarations
		__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
