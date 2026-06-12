//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * Reproject sample — demonstrates coordinate system transformation and
 * reprojetion of geospatial data.
 *
 * What the sample shows:
 *   - Querying the CsProjList registry of all available map projections
 *   - Building a projected coordinate system from components:
 *     Geographic coordinate system (datum and ellipsoid)
 *     Projection method (UTM, Mercator, etc.)
 *     Units of measurement (meters, feet, etc.)
 *   - Assigning a coordinate system to the viewer and layer
 *   - Automatic coordinate transformation when rendering with a new CS
 *   - Exporting reprojected data to a new shapefile
 *
 * User workflow:
 *   1. Select a map projection from the dropdown (populated from TatukGIS
 *      projection registry)
 *   2. The viewer automatically reprojects and displays the data in the new CS
 *   3. Click "Save As..." to export the reprojected layer to a new file
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_CSProjList                    - global registry of map projections
 *   TGIS_CSProjectedCoordinateSystem   - user-defined projection with datum, units
 *   TGIS_CSGeographicCoordinateSystem  - geographic datum/ellipsoid (EPSG 4030)
 *   GIS.CS property                    - assign CS and trigger automatic reprojection
 *   TGIS_LayerVector.CS                - layer-specific coordinate system
 *   GIS.FullExtent()                   - recalculate extent in new CS
 */
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
#include <Dialogs.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
/* Reproject sample — demonstrates coordinate system transformation and reprojection of geospatial data.
   Loads a shapefile and allows users to select a target map projection (e.g., UTM, Mercator, Geographic).
   Reprojects the layer geometry and saves the result to a new file. Demonstrates TGIS_Projection
   instantiation, spatial reference assignment, and layer coordinate transformation. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS ;
        TToolBar *ToolBar1 ;
        TButton *Button1 ;
        TToolButton *ToolButton1 ;
        TSaveDialog *dlgSave ;
        TToolButton *ToolButton3 ;
        TComboBox *cbxSrcProjection ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall cbxSrcProjectionChange(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
