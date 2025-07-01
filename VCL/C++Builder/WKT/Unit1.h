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
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisGeometryFactory.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TMemo *Memo1;
        TGIS_ViewerWnd *GIS;
        TStatusBar *StatusBar1;
        TToolBar *ToolBar1;
        TComboBox *cbType;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall Memo1Change(TObject *Sender);
        void __fastcall cbTypeChange(TObject *Sender);
private:	// User declarations
  TGIS_LayerVector *layerObj ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
