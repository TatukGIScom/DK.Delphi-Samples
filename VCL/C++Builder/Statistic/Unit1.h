//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to provied simple statistical analyzes by overriding OnSPaintShape event.
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
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TToolBar *ToolBar1 ;
        TGIS_ViewerWnd *GIS ;
        TStatusBar *StatusBar1 ;
        TComboBox *ComboLabels ;
        TComboBox *ComboStatistic ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoomIn ;
        TToolButton *btnZoomOut ;
        TImageList *ImageList1 ;
        TToolButton *ToolButton1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall PaintShape( TObject * _sender, TGIS_Shape * _shape  ) ;
        void __fastcall ComboChange(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomInClick(TObject *Sender);
		void __fastcall btnZoomOutClick(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
