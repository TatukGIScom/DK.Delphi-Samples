/*
 * ConvertOSM sample — converts an OpenStreetMap (.osm) file to SHP, SQL ADO, or SQLite layers
 * using TGIS_OSMImporter.
 *
 * The user selects an OSM input file and an export directory, then checks which geometry types to
 * export (Points, Lines, Polygons) and picks the target layer format via a radio group.  Clicking
 * Convert calls convertOSM which parses the file and writes each selected geometry type to a
 * separately named layer file.  Progress is reported in the status bar via doBusy; importer log
 * messages are appended to a memo via doLog.
 */
//---------------------------------------------------------------------------

#ifndef Unit2H
#define Unit2H
//---------------------------------------------------------------------------
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.Graphics.hpp>
#include "FileCtrl.hpp"
#include <Winapi.Windows.hpp>
#include <Winapi.Messages.hpp>
#include "GisLayerVector.hpp"
#include "GisLayerOSM.hpp"
#include "GisLayerSHP.hpp"
#include "GisLayerSqlAdo.hpp"
#include "GisLayerSqlSqlite.hpp"
#include "GisInternals.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "Vcl.GisViewerBmp.hpp"
#include "ShlObj.hpp"
#include "System.hpp"
#include <windowsx.h>
#include <math.h>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TStatusBar *stat1 ;
	TMemo       *mmolog ;
	TGroupBox   *grpTTKLS ;
	TButton     *btnOSM ;
	TEdit       *edtOSMPath ;
	TGroupBox   *grp1 ;
	TButton     *btnSelectFolder ;
	TEdit       *edExportDir ;
	TGroupBox   *grp2 ;
	TCheckBox   *cbel ;
	TCheckBox   *cbep ;
	TCheckBox   *cbepp ;
	TButton     *btnConvert ;
	TRadioGroup *rgLayerFormat ;
	TOpenDialog *dlgOpenOSM ;

	void __fastcall btnConvertClick(TObject *Sender);       /* Validate inputs; run conversion */
	void __fastcall btnOSMClick(TObject *Sender);           /* Browse for source OSM file */
	void __fastcall btnSelectFolderClick( TObject *Sender ); /* Browse for export directory */
private:	// User declarations
  TGIS_ViewerBmp* vwr ;
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	TGIS_LayerVector* __fastcall CreateLayer(int _ltype, String _ext ); /* Instantiate SHP/ADO/SQLite layer */
	String __fastcall BrowseDialog();                        /* Folder selection dialog */
	void __fastcall doBusy( TObject *_sender, int _pos, int _end, bool &_abort ) ; /* Status bar progress */
	void __fastcall doLog ( const String _txt ) ;           /* Append importer log to memo */
	void __fastcall convertOSM( const String _osmPath, const String _exportPath, const int _ltype ) ; /* Parse OSM; export selected geometry types */
    double __fastcall trunc(double d);

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
