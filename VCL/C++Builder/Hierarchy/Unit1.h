//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * Hierarchy sample — demonstrates layer organization and grouping using TGIS_Hierarchy.
 *
 * Creates a hierarchical layer structure (nested groups of layers) on a map, organizing related
 * layers (e.g., Poland/Waters/Lakes, Poland/Areas/city). Supports group creation, layer assignment,
 * group nesting, and parsing hierarchy from INI format strings. Displays the hierarchy in a legend control.
 *
 * Key concepts illustrated:
 *   - CreateGroup() — creates a named group to logically organize layers
 *   - AddLayer() / DeleteLayer() — associates or removes layers from groups
 *   - Nested groups — groups can contain sub-groups for multi-level hierarchies
 *   - MoveGroup() — reparents a group to another group
 *   - ParseHierarchy() — deserializes a hierarchy from INI text format
 *   - TGIS_ControlLegend display — visualizes the hierarchy in a tree control
 */
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
#include "GISRegistredLayers.hpp"
#include "VCL.GisControlLegend.hpp"
#include "GisTypesUI.hpp"

//---------------------------------------------------------------------------
/* Hierarchy sample — demonstrates layer organization and grouping using TGIS_Hierarchy.
   Creates a hierarchical layer structure (nested groups of layers) on a map, organizing related
   layers (e.g., Poland/Waters/Lakes, Poland/Areas/city). Supports group creation, layer assignment,
   group nesting, and parsing hierarchy from INI format strings. Displays the hierarchy in a legend control. */
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TGIS_ControlLegend *GIS_ControlLegend;
	TToolBar *ToolBar1;
	TButton *Button1;
	void __fastcall Button1Click(TObject *Sender);

private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
