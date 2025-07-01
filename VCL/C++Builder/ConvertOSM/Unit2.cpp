//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to convert OSM file.
//
//  Check project\options\directories in a case of any problems during compilation
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
void __fastcall TForm1::doLog ( const String _txt ){
  mmolog->Lines->Add( _txt);
  Application->ProcessMessages();
}

//---------------------------------------------------------------------------
void __fastcall TForm1::convertOSM( const String _osmPath, const String _exportPath, const int _ltype ){

  TGIS_OSMImporter *imp ;
  TGIS_LayerVector *lp ;
  String           fname ;
  String           ext ;

  vwr = new TGIS_ViewerBmp ;
  try{
    vwr->BusyEvent = doBusy ;
    imp = new TGIS_OSMImporter( *vwr ) ;
    try{
      imp->ImportLogEvent = doLog ;
      imp->ImportOSMFile( _osmPath );

      fname = GetFileName( _osmPath ) ;

      if (cbep->Checked) {
        lp = CreateLayer( _ltype, ext );
        try{
          lp->Path = _exportPath + "\\" + fname + "_pt" + ext ;
          lp->Name = fname + "_pt" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          imp->ExportOsmPoints( lp );
          lp->ParamsList->SaveToFile( lp->ConfigName );
        }
        __finally{
          delete lp;
        }
      }
      if ( cbel->Checked ) {
        lp = CreateLayer( _ltype, ext );
        try{
          lp->Path = _exportPath + "\\" + fname + "_l" + ext ;
          lp->Name = fname + "_l" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          imp->ExportOsmLines( lp );
          lp->ParamsList->SaveToFile( lp->ConfigName );
        }
        __finally{
          delete lp;
        }
      }
      if ( cbepp->Checked ) {
        lp = CreateLayer( _ltype, ext );
        try{
          lp->Path = _exportPath + "\\" + fname + "_p" + ext ;
          lp->Name = fname + "_p" ;
          lp->ConfigName = lp->Path ;
          lp->UseConfig  = True ;
          imp->ExportOsmPolygons( lp );
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
void __fastcall TForm1::btnOSMClick( TObject* Sender ){
  if ( dlgOpenOSM->Execute() ) {
    edtOSMPath->Text = dlgOpenOSM->FileName ;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnSelectFolderClick( TObject* Sender ){
  String path ;

  path = BrowseDialog( );
  if (path == "") {
    return ;
  }
  edExportDir->Text = path ;
}

//---------------------------------------------------------------------------

