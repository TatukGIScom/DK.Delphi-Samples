/*
 * DynamicAggregation sample — demonstrates TGIS_DynamicAggregatorFactory for real-time point
 * clustering on a GIS layer.
 *
 * What the sample shows:
 *   - Loading a TatukGIS project (Aggregation.ttkproject) with "cities" point layer
 *   - Creating a left control panel with three aggregation parameters:
 *     * Aggregation method (Off or factory-registered name)
 *     * Radius: clustering distance threshold
 *     * Threshold: minimum cluster size
 *   - Real-time cluster visualization: changing any control triggers changeAggregation
 *   - Installing/removing TGIS_DynamicAggregator via CreateInstance
 *   - Factory-based aggregator registration and instantiation
 *   - Dynamic legend updates showing clustered vs. individual point rendering
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_DynamicAggregatorFactory  - factory for registered aggregator types
 *   TGIS_DynamicAggregator         - clustering algorithm instance
 *   TGIS_LayerVector               - vector layer with dynamic aggregation support
 *   TGIS_ViewerWnd                 - main visual map control with auto-refresh
 *   CreateInstance                 - factory method for aggregator creation
 *   Factory.Names                  - enumeration of registered aggregator names
 */
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "GisLayerVector.hpp"
#include "GisAllLayers.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm10 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TPanel *pMenu;
	TLabel *lblMethod;
	TLabel *lblRadius;
	TLabel *lblThreshhold;
	TComboBox *cbxMethod;
	TComboBox *cbxRadius;
	TComboBox *cbxThreshhold;
	void __fastcall FormCreate(TObject *Sender);        /* Open project; populate method combo */
	void __fastcall cbxMethodChange(TObject *Sender);   /* Reset default radius; apply aggregator */
	void __fastcall cbxRadiusChange(TObject *Sender);   /* Re-apply aggregator with new radius */
	void __fastcall cbxThreshholdChange(TObject *Sender); /* Re-apply aggregator with new threshold */
private:	// User declarations
	void __fastcall readDefaultValues();   /* Set default radius index for chosen method */
	void __fastcall changeAggregation();   /* Install/remove TGIS_DynamicAggregator; redraw map */
	TStringList *names;
public:		// User declarations
	__fastcall TForm10(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm10 *Form10;
//---------------------------------------------------------------------------
#endif
