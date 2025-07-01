//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  How to tracking points.
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
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TButton *btnWithoutSnapping;
  TButton *btnWithSnapping;
  TGIS_ViewerWnd *GIS;
  TTimer *tmrWithoutSnapping;
  TTimer *tmrWithSnapping;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall FormDestroy(TObject *Sender);
  void __fastcall tmrWithoutSnappingTimer(TObject *Sender);
  void __fastcall btnWithSnappingClick(TObject *Sender);
  void __fastcall tmrWithSnappingTimer(TObject *Sender);
  void __fastcall btnWithoutSnappingClick(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
    TPicture    *pctPolice; // police car bitmap
    TGIS_Shape  *shpPolice; // police shape
    int         cntPoint;  // number of evaluated points
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
