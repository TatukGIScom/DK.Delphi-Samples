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
#include <DB.hpp>
#include "GisTopology.hpp"
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
    TButton *btnAplusB;
    TButton *btnAmultB;
    TButton *btnAminusB;
    TButton *btnBminusA;
    TButton *btnAxorB;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnAplusBClick(TObject *Sender);
        void __fastcall btnAmultBClick(TObject *Sender);
        void __fastcall btnAminusBClick(TObject *Sender);
        void __fastcall btnBminusAClick(TObject *Sender);
        void __fastcall btnAxorBClick(TObject *Sender);
private:	// User declarations
    TGIS_Topology  *topologyObj ;
    TGIS_LayerVector  *layerObj ;
    TGIS_ShapePolygon  *shpA ;
    TGIS_ShapePolygon  *shpB ;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
