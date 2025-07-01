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
#include <ExtCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <Buttons.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS;
        TTimer *Timer1;
        TStatusBar *StatusBar1;
        TTrackBar *TrackBar1;
        TMemo *Memo1;
        TToolBar *ToolBar1;
        TToolButton *btnMinus;
        TToolButton *btnPlus;
        TImageList *ImageList1;
        void __fastcall btnMinusClick(TObject *Sender);
        void __fastcall btnPlusClick(TObject *Sender);
        void __fastcall TrackBar1Change(TObject *Sender);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
