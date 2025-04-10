//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to select several shapes
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
#include <DB.hpp>
#include "VCL.GisControlAttributes.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTriangulation.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS ;
	TImageList *ImageList1;
	TPanel *Panel1;
	TGIS_ControlAttributes *GIS_Attributes;
	TGroupBox *grpbxResult;
	TLabel *lblName;
	TRadioButton *rdbtnVoronoi;
	TRadioButton *rdbtnDelaunay;
	TEdit *edtName;
	TButton *btnGenerate;
	TGIS_ControlLegend *GIS_ControlLegend1;
	TStatusBar *StatusBar1;
	TToolBar *ToolBar1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	TToolButton *btnZoomOut;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnFullExtentClick(TObject *Sender);
        void __fastcall GISMouseDown(TObject *Sender, TMouseButton Button,
          TShiftState Shift, int X, int Y);
        void __fastcall btnZoomInClick(TObject *Sender);
        void __fastcall btnZoomOutClick(TObject *Sender);
	void __fastcall btnGenerateClick(TObject *Sender);
	void __fastcall rdbtnVoronoiClick(TObject *Sender);
	void __fastcall rdbtnDelaunayClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
