//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// Languages sample — demonstrates adding multilingual support to GIS applications (C++Builder/VCL).
//
// What the sample shows:
//   - Loading map data (layers) into the GIS viewer
//   - Selecting a language from a combo box (English, German, French, Polish, etc.)
//   - Translating UI labels, menus, and buttons dynamically
//   - Switching map layer names and attribute labels to the selected language
//   - Loading language-specific configuration files
//   - Handling right-to-left language layouts (Arabic, Hebrew)
//   - Supporting Unicode character encoding for non-Latin scripts
//   - Persisting language preference for future sessions
//   - Translating layer metadata and field descriptions
//   - Using language resource tables for quick lookups
//   - Applying locale-specific number and date formatting
//   - Dynamically updating the entire UI without restarting application
//
// Key TatukGIS API concepts shown here:
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerVector            - vector layer with multilingual metadata
//   TGIS_Params                 - layer styling (labels in different languages)
//   Layer names                 - translatable layer identifiers
//   Field descriptions          - localized attribute metadata
//   Attribute labels            - translated field names for display
//   Combo box language selector - dropdown for available languages
//   Unicode support             - handling international character sets
//   Locale configuration        - regional settings for numbers/dates
//
//  How to add multilanguage support.
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
#include <Graphics.hpp>
#include <DB.hpp>
#include "GisLayerVector.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS ;
        TToolBar *ToolBar1 ;
        TComboBox *ComboBox1 ;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall ComboBox1Change(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
