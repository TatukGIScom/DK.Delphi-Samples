//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Reclassification sample — demonstrates data reclassification and categorization (C++Builder/VCL).
//
// What the sample shows:
//   - Loading vector or raster layers with numeric attribute data
//   - Creating custom classification schemes to group values into classes
//   - Defining class boundaries and ranges manually
//   - Assigning colors to each class for visual distinction
//   - Applying reclassification to vector layer attributes
//   - Reclassifying raster pixel values into discrete categories
//   - Using TGIS_ClassificationAbstract for different layer types
//   - Creating lookup tables for categorical attribute mapping
//   - Recoding field values based on expression rules
//   - Updating layer symbology to reflect new classification
//   - Displaying classified results in legend control
//   - Creating thematic maps from continuous data
//   - Persisting classification definitions for reuse
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerVector            - vector layer for feature classification
//   TGIS_LayerPixel             - raster layer for pixel reclassification
//   TGIS_ClassificationAbstract - base class for classification engines
//   TGIS_ClassificationVector   - vector data classification
//   TGIS_ClassificationPixel    - raster data classification
//   Class definitions            - boundaries, ranges, colors
//   TGIS_Params                 - rendering parameters per class
//   TGIS_ControlLegend          - legend showing classes and colors
//   Attribute mapping           - field value to class assignment
//   Thematic visualization      - color-coded feature display
//   Reclassification.

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
