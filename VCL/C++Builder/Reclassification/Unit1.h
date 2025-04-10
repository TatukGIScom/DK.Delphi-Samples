//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Reclassification.
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
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "GisClassification.hpp"
#include <System.ImageList.hpp>
#include "VCL.GisControlLegend.hpp"
#include <Vcl.Grids.hpp>

//---------------------------------------------------------------------------
class TfrmReclassification : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GISLegend;
	TProgressBar *progress;
	TGroupBox *grpbReclassification;
	TLabel *lblReclassTable;
	TLabel *lblNoData;
	TLabel *lblAltitudeZones;
	TStringGrid *sgrdReclassTable;
	TCheckBox *chkNodata;
	TButton *btnReclassify;
	TButton *btnUseTable;
	TButton *btnUseAltitudeZones;
	void __fastcall FormShow(TObject *Sender);
	void __fastcall btnUseTableClick(TObject *Sender);
	void __fastcall btnUseAltitudeZonesClick(TObject *Sender);
	void __fastcall btnReclassifyClick(TObject *Sender);
	void __fastcall chkNodataClick(TObject *Sender);

private:	// User declarations
	bool useAltitudeMapZones;
	void __fastcall OpenSampleForReclassTable();
	void __fastcall OpenSampleForUseAltitudeZones();
	void __fastcall ApplyUniqueStyle(TGIS_LayerPixel* _lp, AnsiString _colorRampName );
	void __fastcall ApplyNaturalBreaksStyle(TGIS_LayerPixel* _lp, AnsiString _colorRampName );
	void __fastcall doBusyEvent(TObject* _sender, int _pos, int _end, bool &_abort);
public:		// User declarations
        __fastcall TfrmReclassification(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmReclassification *frmReclassification;
//---------------------------------------------------------------------------
#endif
