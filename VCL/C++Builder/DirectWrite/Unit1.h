//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

/*
 * DirectWrite sample - demonstrates five sequential low-level write techniques on TGIS_LayerSHP:
 * Build (AddShape loop + SaveData), ImportLayerEx (spatial CONTAINS filter), MergeLayerEx
 * (DISJOINT filter), TGIS_LayerVectorDirectWriteHelper (sequential high-performance write), and
 * TGIS_LayerVectorMergeHelper (batch-commit write).  Buttons unlock in sequence; output files go
 * into a numbered Shapes{n} directory.
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisTypesUI.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "GisTypes.hpp"
#include "GisUtils.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerVector.hpp"
#include "GisGeometryFactory.hpp"
#include "GisRtl.hpp"
#include "GisTopology.hpp"


//---------------------------------------------------------------------------
/* Main form for the DirectWrite sample.
   Demonstrates five sequential write techniques for creating and populating
   vector layers: BuildLayer, AddShape loop, SaveData, ImportLayerEx, and
   MergeLayerEx operations. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TToolBar *Toolbar1;
	TButton *btnImportLayer ;
	TButton *btnMergeLayer;
	TButton *btnDirectMerge;
	TButton *btnBuild;
	TButton *btnDirectWrite ;
	void __fastcall btnBuildClick(TObject *Sender);       /* Build SHP + AddShape loop + SaveData */
	void __fastcall btnImportLayerClick(TObject *Sender);  /* ImportLayerEx with CONTAINS polygon */
	void __fastcall btnMergeLayerClick(TObject *Sender);   /* MergeLayerEx with DISJOINT relation */
	void __fastcall btnDirectWriteClick(TObject *Sender);  /* TGIS_LayerVectorDirectWriteHelper sequential write */
	void __fastcall btnDirectMergeClick(TObject *Sender);  /* TGIS_LayerVectorMergeHelper batch-commit write */
	void __fastcall FormCreate(TObject *Sender);           /* Find next unused Shapes{n} directory */
private:	// User declarations
  int number ;
  bool exist ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
