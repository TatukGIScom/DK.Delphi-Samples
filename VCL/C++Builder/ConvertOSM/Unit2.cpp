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

#include <vcl.h>
#pragma hdrstop

#include "Unit2.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{

}
//---------------------------------------------------------------------------
/* Instantiates the appropriate layer type (SHP / SQL ADO / SQLite) for the chosen format index. */
TGIS_LayerVector* __fastcall TForm1::CreateLayer(int _ltype,
                                    String _ext )
{
  switch ( _ltype ) {
    case 0  : {
                  _ext = ".shp" ;
                  return new TGIS_LayerSHP ;
                }
    case 1  : {
                  _ext = ".ttkls" ;
                  return new TGIS_LayerSqlAdo ;
                }
    case 2  : {
                  _ext = ".ttkls" ;
                  return new TGIS_LayerSqlSqlite ;
                }
    default : {
                  _ext = ".shp" ;
                  return new TGIS_LayerSHP ;
                }
    }
}


//---------------------------------------------------------------------------
/* Opens a folder browse dialog and returns the selected path, using TFileOpenDialog on Vista+. */
String __fastcall TForm1::BrowseDialog(){

  String Result ;
  String sdir ;
  bool bexecuted ;
  TFileOpenDialog *dlg ;

  sdir = "c:\\" ;
  Result = "" ;
  bexecuted = false ;
  
  int winver ;
  #if (__CODEGEARC__ >= 0x0740)
	winver = Win32MajorVersion() ;
  #else
	winver = Win32MajorVersion ;
  #endif
  
  if( winver >= 6 ){
    dlg = new TFileOpenDialog(NULL);
    try{
      dlg->Options << fdoPickFolders << fdoPathMustExist << fdoForceFileSystem ;
      dlg->DefaultFolder = sdir;
      if( dlg->Execute() ){
        bexecuted = true ;
        sdir = dlg->FileName;
      }
    }__finally{
      delete dlg ;
    }
  }
  else{
    if( SelectDirectory( "", ExtractFileDrive(sdir), sdir, TSelectDirExtOpts()<<sdNewUI ) ){
      bexecuted = true ;
    }
  }
  if( bexecuted ){
     Result = sdir ;
  }
  return Result ;}

double __fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}
//---------------------------------------------------------------------------
/* Updates the status bar with percentage progress during a long import/export operation. */
void __fastcall TForm1::doBusy( TObject* _sender, int _pos, int _end, bool &_abort ) {

    AnsiString str ;
    if( _end <= 0 ){
      stat1->SimpleText = "" ;
    } else{
		stat1->SimpleText = str.sprintf( "%s %d%%", vwr->BusyText.c_str(), trunc( _pos/_end * 100 ) );

        Application->ProcessMessages() ;
        _abort = False ;
    }

}

//---------------------------------------------------------------------------
/* Appends an importer log message to the memo and processes pending UI events. */
void __fastcall TForm1::doLog ( const String _txt ){
  mmolog->Lines->Add( _txt);
  Application->ProcessMessages();
}

//---------------------------------------------------------------------------
/* Parses the OSM file with TGIS_OSMImporter and exports each selected geometry type (points,
   lines, polygons) to a layer file of the chosen format in the export directory. */
void __fastcall TForm1::convertOSM( const String _osmPath, const String _exportPath, const int _ltype ){

  TGIS_OSMImporter *imp ;
  TGIS_LayerVector *lp ;
  String           fname ;
  String           ext ;

  /* Create a bitmap viewer for rendering progress during import/export. */
  vwr = new TGIS_ViewerBmp ;
  try{
    /* Wire up the busy event to update the status bar with progress percentage. */
    vwr->BusyEvent = doBusy ;
    /* Create an OSM importer bound to the viewer for progress tracking. */
    imp = new TGIS_OSMImporter( *vwr ) ;
    try{
      /* Wire up the log event to display importer messages in the memo. */
      imp->ImportLogEvent = doLog ;
      /* Parse the OSM file and extract all geometric features (points, ways, relations). */
      imp->ImportOSMFile( _osmPath );

      /* Extract the base filename (without path/extension) for output layer naming. */
      fname = GetFileName( _osmPath ) ;

      /* Export points if the checkbox is checked. */
      if (cbep->Checked) {
        /* Create a layer of the selected format (SHP, SQL ADO, or SQLite). */
        lp = CreateLayer( _ltype, ext );
        try{
          /* Set the output path and layer name for point features. */
          lp->Path = _exportPath + "\\" + fname + "_pt" + ext ;
          lp->Name = fname + "_pt" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          /* Export all OSM point features (nodes tagged as POI) to the layer. */
          imp->ExportOsmPoints( lp );
          /* Save layer configuration (.ttkgp file). */
          lp->ParamsList->SaveToFile( lp->ConfigName );
        }
        __finally{
          delete lp;
        }
      }
      /* Export lines if the checkbox is checked. */
      if ( cbel->Checked ) {
        /* Create a layer of the selected format for line features. */
        lp = CreateLayer( _ltype, ext );
        try{
          /* Set the output path and layer name for line features. */
          lp->Path = _exportPath + "\\" + fname + "_l" + ext ;
          lp->Name = fname + "_l" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          /* Export all OSM line features (ways) to the layer. */
          imp->ExportOsmLines( lp );
          /* Save layer configuration. */
          lp->ParamsList->SaveToFile( lp->ConfigName );
        }
        __finally{
          delete lp;
        }
      }
      /* Export polygons if the checkbox is checked. */
      if ( cbepp->Checked ) {
        /* Create a layer of the selected format for polygon features. */
        lp = CreateLayer( _ltype, ext );
        try{
          /* Set the output path and layer name for polygon features. */
          lp->Path = _exportPath + "\\" + fname + "_p" + ext ;
          lp->Name = fname + "_p" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          /* Export all OSM polygon features (closed ways and relations) to the layer. */
          imp->ExportOsmPolygons( lp );
          /* Save layer configuration. */
          lp->ParamsList->SaveToFile( lp->ConfigName );
        }
        __finally{
          delete lp;
        }
      }
    }
    __finally{
      delete imp ;
    }
  }
  __finally{
    delete vwr ;
  }
}


//---------------------------------------------------------------------------
/* Validates that an OSM file and export directory have been selected, then runs the conversion. */
void __fastcall TForm1::btnConvertClick ( TObject* Sender ){
  btnConvert->Enabled = False ;
  try{
    if( edtOSMPath->Text == "" ){
      ShowMessage( "Select osm file first" );
      return ;
    }
    if( edExportDir->Text == "" ){
      ShowMessage( "Select export directory first" ) ;
      return ;
    }
    convertOSM( edtOSMPath->Text, edExportDir->Text, rgLayerFormat->ItemIndex ) ;

    ShowMessage( "Done" );
  }
  __finally{
    btnConvert->Enabled = True ;
  }
}

//---------------------------------------------------------------------------
/* Opens a file dialog for the user to select the source OSM file. */
void __fastcall TForm1::btnOSMClick( TObject* Sender ){
  if ( dlgOpenOSM->Execute() ) {
    edtOSMPath->Text = dlgOpenOSM->FileName ;
  }
}

//---------------------------------------------------------------------------
/* Opens a folder browse dialog for the user to select the export directory. */
void __fastcall TForm1::btnSelectFolderClick( TObject* Sender ){
  String path ;

  path = BrowseDialog( );
  if (path == "") {
    return ;
  }
  edExportDir->Text = path ;
}

//---------------------------------------------------------------------------

