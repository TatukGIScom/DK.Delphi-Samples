//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to provide editing functionality.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------

#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <Dialogs.hpp>
#include <ImgList.hpp>
#include <Menus.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
        TToolBar *tlbMain ;
        TGIS_ViewerWnd *GIS ;
        TStatusBar *stsBar ;
        TComboBox *cmbLayer ;
        TPrintDialog *dlgPrint ;
        TPopupMenu *mnuPopup ;
        TMenuItem *mnuAddPart ;
        TMenuItem *mnuDeletePart ;
        TComboBox *cmbSnap ;
        TToolButton *ToolButton1 ;
        TImageList *ImageList1 ;
        TToolButton *btnSave ;
        TToolButton *btnPrint ;
        TToolButton *ToolButton2 ;
        TToolButton *btnFullExtent ;
        TToolButton *btnZoom ;
        TToolButton *btnDrag ;
        TToolButton *btnSelect ;
        TToolButton *btnEdit ;
        TToolButton *ToolButton3 ;
        TToolButton *btnAddShape ;
        TToolButton *ToolButton4 ;
        TToolButton *btnUndo ;
        TToolButton *btnRedo ;
        TToolButton *btnRevert ;
        TToolButton *btnDelete ;
        TToolButton *btnWinding ;
        TToolButton *ToolButton5 ;
        TToolButton *btnShowInfo ;
        TToolButton *btnAutoCenter ;
        TToolButton *ToolButton6 ;
	TToolButton *ToolButton7;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
        void __fastcall GISEditorChange(TObject *Sender);
        void __fastcall GISKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall GISKeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall btnSaveClick(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall btnZoomClick(TObject *Sender);
        void __fastcall btnDragClick(TObject *Sender);
        void __fastcall btnSelectClick(TObject *Sender);
        void __fastcall btnEditClick(TObject *Sender);
        void __fastcall btnAddShapeClick(TObject *Sender);
        void __fastcall btnRedoClick(TObject *Sender);
        void __fastcall btnUndoClick(TObject *Sender);
        void __fastcall btnRevertClick(TObject *Sender);
        void __fastcall btnDeleteClick(TObject *Sender);
        void __fastcall btnShowInfoClick(TObject *Sender);
        void __fastcall btnAutoCenterClick(TObject *Sender);
        void __fastcall cmbLayerChange(TObject *Sender);
        void __fastcall btnPrintClick(TObject *Sender);
        void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift,
          int X, int Y);
        void __fastcall btnWindingClick(TObject *Sender);
        void __fastcall mnuAddPartClick(TObject *Sender);
        void __fastcall mnuDeletePartClick(TObject *Sender);
        void __fastcall cmbSnapChange(TObject *Sender);
    void __fastcall GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y);
	void __fastcall ToolButton7Click(TObject *Sender);
	void __fastcall GISAfterPaintEvent(TObject *Sender, TObject *_canvas);
private:	// User declarations
        Boolean vkControl ;
        TGIS_LayerAbstract *editLayer ;
        TGIS_Point menuPos ;
        void endEdit() ;
public:		// User declarations
        __fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
