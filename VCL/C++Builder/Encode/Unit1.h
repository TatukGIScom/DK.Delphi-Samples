/*
 * Encode sample — demonstrates transparent layer encoding using ReadEvent and WriteEvent callbacks.
 *
 * What the sample shows:
 *   - Loading a world shapefile into the GIS viewer with labels
 *   - Creating a separate vector layer and exporting it to a new file with encryption applied
 *   - Using TGIS_LayerSHP ReadEvent and WriteEvent callbacks to apply/reverse XOR cipher
 *     byte-by-byte (keyed on file position)
 *   - The encoded shapefile can be re-opened with the same callback wired to transparently
 *     decode it on the fly, while rendering with a distinct color
 *
 * Key TatukGIS API concepts shown here:
 *   TGIS_ViewerWnd        - main visual map control
 *   TGIS_LayerSHP         - ESRI Shapefile layer (source and destination)
 *   TGIS_LayerVector      - base class for vector layers
 *   TGIS_Layer.ImportLayer - export/convert layer to different format with transformation
 *   ReadEvent/WriteEvent  - callbacks for transparent cipher operations during I/O
 *   TGIS_Color            - color constants (Green for encoded layer visualization)
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
#include <ToolWin.hpp>
#include <DB.hpp>
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisRegistredLayers.hpp"
#include "GisTypesUI.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TGIS_ViewerWnd *GIS;
        TToolBar *ToolBar1;
        TButton *btnCloseAll;
        TButton *btnOpenBase;
        TButton *btnEncode;
        TButton *btnOpenEncoded;
        TStatusBar *StatusBar1;
        void __fastcall btnCloseAllClick(TObject *Sender);     /* Close all layers */
        void __fastcall btnOpenBaseClick(TObject *Sender);     /* Open base world shapefile */
        void __fastcall btnEncodeClick(TObject *Sender);       /* Export to encoded.shp with XOR write callback */
        void __fastcall btnOpenEncodedClick(TObject *Sender);  /* Open encoded.shp with XOR read callback */
private:	// User declarations
        void __fastcall doRead( TObject * _sender, int _pos, void *_buffer, int _count ) ;  /* Decode: XOR each byte with (pos+i) mod 256 */
	void __fastcall doWrite( TObject * _sender, int _pos, void *_buffer, int _count ) ;  /* Encode: XOR each byte with (pos+i) mod 256 */
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 
