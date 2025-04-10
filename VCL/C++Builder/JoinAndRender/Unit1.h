//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to use JoinADO.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.Win.ComObj.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisViewer.hpp"
#include "GisUtils.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerSHP.hpp"
#include "GisTopology.hpp"
#include "GisParams.hpp"
#include "GisEditor.hpp"
#include "GisTypesUI.hpp"
#include "GisTypes.hpp"
#include "Vcl.GisControlLegend.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include <Data.DB.hpp>
#include <Data.Win.ADODB.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar1;
	TGIS_ViewerWnd *GIS;
	TStatusBar *StatusBar1;
	TComboBox *cmbSize;
	TImageList *ImageList1;
	TToolButton *btnFullExtent;
	TToolButton *btnZoomIn;
	TToolButton *btnZoomOut;
	TToolButton *ToolButton1;
	TGIS_ControlLegend *GIS_Legend;
	TToolButton *ToolButton2;
	TToolButton *ToolButton3;
	TTrackBar *scrTransparency;
	TColorDialog *dlgColor;
	TPanel *panColorStart;
	TPanel *panColorEnd ;
	TADOQuery *ADOQuery;
	TADOConnection *ADOConnection;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomInClick(TObject *Sender);
	void __fastcall btnZoomOutClick(TObject *Sender);
	void __fastcall cmbSizeChange(TObject *Sender);
	void __fastcall scrTransparencyChange(TObject *Sender);
	void __fastcall panColorStartClick(TObject *Sender);
	void __fastcall panColorEndClick(TObject *Sender);
private:	// User declarations
	Variant sqlDC ;
	Variant sqlRS ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
