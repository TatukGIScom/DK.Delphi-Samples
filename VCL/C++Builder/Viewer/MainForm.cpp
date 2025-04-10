//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to prepare small coverage previewer.
//  Main window.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "MainForm.h"
#include "InfoForm.h"
#include "EditForm.h"
#include "ExportForm.h"
#include "SearchForm.h"
#include "GisLayerSHP.hpp"

#define round(a) int((a)+0.5)

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma link "GisControlPrintPreviewSimple"
#pragma resource "*.dfm"
TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::OpenCoverage( AnsiString _path )
{
  TGIS_LayerAbstract *ll;
  // clear the viewer
  GIS->Close() ;
  stsBar->Panels->Items[3]->Text = "" ;

  try {
    // open selected file 
    GIS->Open( _path , true ) ;

    mnuExportLayer->Enabled = false ;
    for ( int i = 0 ; i<=(GIS->Items->Count-1) ; i++ ) {
      // if set use these params for file
      ll = (TGIS_Layer *)( (GIS->Items)->Items[i] );
      // for layers of TGIS_LayerVector type enable export
      if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
        mnuExportLayer->Enabled = true ;
    }

    stsBar->Panels->Items[3]->Text = ExtractFileName( _path ) ;
  }
  catch ( const Exception& e ) {
    // if anything went wrong, show a warning
      ShowMessage( "File can''t be open\n\r" + e.Message ) ;
      GIS->Close();
  }
  GIS->UseRTree = UseRTree1->Checked;

}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::AppendCoverage( AnsiString _path )
{
  TGIS_Layer *ll;

  stsBar->Panels->Items[3]->Text = "" ;
  try {
      mnuExportLayer->Enabled = false ;
      // create a new layer
      ll = GisCreateLayer(ExtractFileName(_path),_path);
      // and add it to the viewer
      if ( ll != NULL ) {
          ll->ReadConfig();
          GIS->Add(ll);
          if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
            mnuExportLayer->Enabled = true ;
      }

    stsBar->Panels->Items[3]->Text =
              stsBar->Panels->Items[3]->Text + ExtractFileName( _path ) + " " ;
  }
  catch ( const Exception& e ) {
    // if anything went wrong, show a warning
      ShowMessage( "File can''t be open\n\r" + e.Message ) ;
      GIS->Close();
  }
  GIS->UseRTree = UseRTree1->Checked;
  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::tmrCreatedTimer(TObject *Sender)
{
    // for console purposes
    tmrCreated->Enabled = false ;
    tmrCreated->OnTimer = NULL ;
    if ( ParamStr(1) != "" ) OpenCoverage( ParamStr(1) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormShow(TObject *Sender)
{
  tmrCreated->Enabled = true ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISBusy(const TObject *_sender, int _pos,
      int _end, bool &_abort)
{
  AnsiString str;
  // show busy state
  if ( _end <= 0 )
    stsBar->Panels->Items[0]->Text = "";
  else
    stsBar->Panels->Items[0]->Text =
      str.sprintf( "Busy %d%%", Ceil( _pos / _end * 100.0 ) ) ;
  Application->ProcessMessages() ;
}
//---------------------------------------------------------------------------
#define VWR     "ttkgisfile"
#define VWRFULL "TatukGIS File"
void __fastcall TfrmMain::do_reg( TRegistry *reg, AnsiString _path, int _type )
{
  String    str;

  if ( _type == 0 ) {
    reg->OpenKey( _path, true);
    reg->WriteString("", VWR );
    reg->CloseKey();
    return;
  }
  if ( _type >= 1 ) {
    reg->OpenKey( _path + "\\shell\\ttkopen", true) ;
    reg->WriteString( "", "View with TatukGIS Viewer" );
    reg->CloseKey();

    reg->OpenKey( _path + "\\shell\\ttkopen\\command", true) ;
    str = "\"" + ParamStr(0) + "\" \"%1\"" ;
    reg->WriteString( "", str );
    reg->CloseKey();
  }
  if ( _type >= 2 ) {
    reg->OpenKey( _path, true);
    reg->WriteString( "", VWRFULL );
    reg->CloseKey();
    reg->OpenKey( _path + "\\DefaultIcon", true);
    reg->WriteString( "", "\"" + ParamStr(0) + "\", 0" );
    reg->CloseKey();
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::reg_ext( TRegistry *reg, AnsiString _ext )
{
  AnsiString refstr;

  refstr = "" ;

  if ( reg->OpenKey(_ext, false) ) {
    refstr = reg->ReadString("");   // read default type
    reg->CloseKey();
    // repair a bit our old bad installation
    if ( AnsiCompareText( refstr, "TatukGIS.Viewer" ) == 0 ) refstr = "" ;
  }
  // if extension file refers to nothing - add full registration
  // otherwise add registartion to referer
  if ( refstr == "") do_reg( reg, _ext  , 0 );
  else do_reg( reg, refstr, 1 ) ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  if ( DebugHook == 0 ) Position = poDefault ;

  // set File dialogs filters
  TGIS_FileTypes _mode;
  dlgFileOpen->Filter = GisSupportedFiles( _mode << TGIS_FileType::All, false, false );
  dlgFileAppend->Filter = GisSupportedFiles( _mode, true, false );
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::GISMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
  TGIS_Shape *shp;

  // if there is no layer or we are not in select mode, exit
  if ( GIS->IsEmpty ) return ;
  if ( GIS->InPaint ) return ;
  
  if ( GIS->Mode != TGIS_ViewerMode::Select ) return ;
  // let's try to locate a selected shape on the map
  shp = ( TGIS_Shape *)( GIS->Locate( GIS->ScreenToMap( Point( X, Y ) ), 5 / GIS->Zoom, True ) ) ;
  if ( shp == NULL ) return ;
  // if any found flash it and show shape info
  shp->Flash( 4, 100 ) ;
  frmInfo->ShowInfo( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point ptg;
  AnsiString str;

  if ( GIS->IsEmpty ) return ;
  // let's locate our position on the map and display coordinates, zoom
  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;
  stsBar->Panels->Items[1]->Text =
    str.sprintf( "X : %.4f | Y : %.4f", ptg.X, ptg.Y ) ;
  stsBar->Panels->Items[2]->Text =
    str.sprintf( "Zoom : %.4f | ZoomEx : %.4f", GIS->Zoom, GIS->ZoomEx ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::dlgFileSaveTypeChange(TObject *Sender)
{
  int k;

  k = 0 ;
  for ( int i = 1 ; i <= (dlgFileSave->Filter.Length() -1) ; i++ ) {
    if (( dlgFileSave->Filter[i  ] == '|' ) &&
        ( dlgFileSave->Filter[i+1] == '*' ) ) {
      dlgFileSave->DefaultExt = "" ;
      for ( int j = i + 3 ; j<= (dlgFileSave->Filter.Length()); j++ ) {
        if ( dlgFileSave->Filter[j] == '|' ) {
          k++ ;
          if ( k == dlgFileSave->FilterIndex ) return;
          else break ;
        }
        dlgFileSave->DefaultExt = dlgFileSave->DefaultExt + dlgFileSave->Filter[j] ;
      }
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::actFileOpenExecute(TObject *Sender)
{
  AnsiString str,ext;

  if (!dlgFileOpen->Execute()) return ;

  str = dlgFileOpen->FileName ;
  ext = ExtractFileExt( str ) ;
  // if project selected, load it to editor
  if ((AnsiCompareText( ext, ".ttkgp" ) == 0) ||
      (AnsiCompareText( ext, ".ttkproject" ) == 0) ||
      (AnsiCompareText( ext, ".ttkls" ) == 0)) {
    frmEdit->StatusBar1->Panels->Items[1]->Text = str;
    frmEdit->Editor->Enabled = true;
    frmEdit->Editor->Lines->Clear();
    frmEdit->Editor->Lines->LoadFromFile( str );
    frmEdit->btnSave->Enabled = false;
  }
  else
    // if config found, load it to editor
    if ( FileExists( str + ".ini") ) {
      frmEdit->StatusBar1->Panels->Items[1]->Text = str + ".ini";
      frmEdit->Editor->Enabled = true;
      frmEdit->Editor->Lines->Clear();
      frmEdit->Editor->Lines->LoadFromFile( str + ".ini");
      frmEdit->btnSave->Enabled = false;
    }
    else {
      frmEdit->Editor->Enabled = false;
      frmEdit->StatusBar1->Panels->Items[1]->Text = "";
      frmEdit->Editor->Lines->Clear();
      frmEdit->btnSave->Enabled = false;
    }
  // check file extension
  switch ( dlgFileOpen->FilterIndex ) {
    case 8  : str = str + "?ARC" ; break;
    case 9  : str = str + "?PAL" ; break;
    case 10 : str = str + "?LAB" ; break;
  }
  // open selected file
  OpenCoverage( str ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::actFileExportExecute(TObject *Sender)
{
  TGIS_LayerVector *ll;
  TGIS_Extent       extent;
  TGIS_ShapeType    shape_type;
  boolean           clipping;
  AnsiString        ext;

  if ( frmExportLayer->ShowModal() == mrCancel ) return ;

  dlgFileSaveTypeChange( 0 ) ;
  dlgFileSave->FileName = "" ;
  if ( !dlgFileSave->Execute()) return ;

  // check the extension to choose a proper layer
  ext = ExtractFileExt( dlgFileSave->FileName ) ;
  if      ( AnsiCompareText( ext, ".shp"  ) == 0 ) ll = new TGIS_LayerSHP;
  else if ( AnsiCompareText( ext, ".mif"  ) == 0 ) ll = new TGIS_LayerMIF;
  else if ( AnsiCompareText( ext, ".dxf"  ) == 0 ) ll = new TGIS_LayerDXF;
  else if ( AnsiCompareText( ext, ".ttkls") == 0 )
          ll = ( TGIS_LayerVector *)( GisCreateLayer( "", dlgFileSave->FileName ) );
  else {
         ShowMessage( "Unrecognized file extension" ) ;
         return ;
  }
  shape_type = TGIS_ShapeType::Unknown    ;
  extent     = GisWholeWorld() ;
  clipping   = false         ;

  // set the extent
  switch (frmExportLayer->grpSelectExtent->ItemIndex) {
    case 0 :  extent    = GisWholeWorld() ;
              clipping  = false ;
              break;
    case 1 :  extent    = GIS->VisibleExtent ;
              clipping  = false ;
              break;
    case 2 :  extent    = GIS->VisibleExtent ;
              clipping  = false ;
              break;
    default:  ShowMessage("Untested case"); return;
  }
  // set layer type
  switch (frmExportLayer->cmbShapeType->ItemIndex) {
    case 0 : shape_type = TGIS_ShapeType::Unknown    ;break;
    case 1 : shape_type = TGIS_ShapeType::Arc        ;break;
    case 2 : shape_type = TGIS_ShapeType::Polygon    ;break;
    case 3 : shape_type = TGIS_ShapeType::Point      ;break;
    case 4 : shape_type = TGIS_ShapeType::MultiPoint ;break;
    default:  ShowMessage("Untested case"); return;
  }
  
  try {
    // try to import existing layer to a new one and save it to the file
    ll->Path = dlgFileSave->FileName;
    ll->ImportLayer( ( TGIS_LayerVector *)( GIS->Get( frmExportLayer->cmbLayersList->Text ) ),
                    extent,
                    shape_type,
                    frmExportLayer->edtQuery->Text,
                    clipping
                  ) ;
  }
  __finally {
      if (ll) delete ll;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actFilePrintExecute(TObject *Sender)
{
	// let's see a print preview form
    GIS_ControlPrintPreviewSimple->Preview();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actFileExitExecute(TObject *Sender)
{
    // close the application
    Application->Terminate() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::actViewFullExtentExecute(TObject *Sender)
{
    // show the whole world
    GIS->FullExtent() ;  
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actViewZoomModeExecute(TObject *Sender)
{
    // set zoom mode
    GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actViewDragModeExecute(TObject *Sender)
{
    // set drag mode
    GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actViewSelectModeExecute(TObject *Sender)
{
    // set select mode
    GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::ActionList1Update(TBasicAction *Action,
      bool &Handled)
{
    boolean notbusy;
    notbusy = true;
    // update toolbar controls
    actViewZoomMode->Checked   = (GIS->Mode == TGIS_ViewerMode::Zoom)   ;
    actViewDragMode->Checked   = (GIS->Mode == TGIS_ViewerMode::Drag)   ;
    actViewSelectMode->Checked = (GIS->Mode == TGIS_ViewerMode::Select) ;
    actSearch->Checked         = frmSearch->Visible;

    actFileOpen->Enabled       = notbusy ;
    actFileExit->Enabled       = notbusy ;
    actFileExport->Enabled     = notbusy && ( !GIS->IsEmpty ) ;
    actFilePrint->Enabled      = notbusy && ( !GIS->IsEmpty ) ;
    actViewFullExtent->Enabled = notbusy && ( !GIS->IsEmpty ) ;
    actViewZoomMode->Enabled   = notbusy && ( !GIS->IsEmpty ) ;
    actViewDragMode->Enabled   = notbusy && ( !GIS->IsEmpty ) ;
    actViewSelectMode->Enabled = notbusy && ( !GIS->IsEmpty ) ;
    actAdd->Enabled            = notbusy && ( !GIS->IsEmpty ) ;
    actSearch->Enabled         = notbusy && ( !GIS->IsEmpty ) ;
    actClose->Enabled          = notbusy && ( !GIS->IsEmpty ) ;
    actEditFile->Enabled       = notbusy && ( !GIS->IsEmpty ) && (frmEdit->StatusBar1->Panels->Items[1]->Text != "");
    actSaveToImage->Enabled    = notbusy && ( !GIS->IsEmpty ) ;
    actSaveAll->Enabled        = notbusy && ( GIS->MustSave() ) ;
    actChangeMode->Enabled     = notbusy && ( !GIS->IsEmpty ) ;
    actCS->Enabled             = notbusy && ( !GIS->IsEmpty ) ;

//    Application->ProcessMessages() ;
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::UseRTree1Click(TObject *Sender)
{
  GIS->UseRTree = UseRTree1->Checked;
  GIS->Update();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::Color1Click(TObject *Sender)
{
  // let's change the viewer color
  if (!ColorDialog1->Execute()) return;

  GIS->Color = ColorDialog1->Color;
  GIS->Update();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actAddExecute(TObject *Sender)
{
  AnsiString File_name;

  if (!dlgFileAppend->Execute()) return ;

  for ( int i=0 ; i <= dlgFileAppend->Files->Count - 1 ; i++ ) {
    File_name = dlgFileAppend->Files->Strings[i];
      switch (dlgFileAppend->FilterIndex) {
        case 8  : File_name = File_name + "?ARC" ;break;
        case 9  : File_name = File_name + "?PAL" ;break;
        case 10 : File_name = File_name + "?LAB" ;break;
      }
    // add all selected files to the viewer
    AppendCoverage( File_name ) ;
  }
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actSearchExecute(TObject *Sender)
{
  frmSearch->ShowModal();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actCloseExecute(TObject *Sender)
{
  GIS->Close();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actEditFileExecute(TObject *Sender)
{
  frmEdit->ShowModal();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actSaveToImageExecute(TObject *Sender)
{
  AnsiString                ext  ;
  TGIS_PixelExportManager  *pem  ;
  TGIS_LayerPixel          *lp   ;
  int                       w, h ;
  int                       dpi  ;
  TGIS_LayerPixelSubFormat  sf   ;
  TGIS_ViewerBmp           *vbmp ;
  UnicodeString             path ;
  TGIS_PixelSubFormat       sub  ;
  TGIS_CompressionType      comp ;
  TGIS_Extent               ex   ;

  ex = GIS->Extent ;
  w   = 1024 ;
  h   = round((ex.YMax - ex.YMin) / (ex.XMax - ex.XMin) * w) ;
  ex  = GisExtent(ex.XMin, ex.YMin, ex.XMax, ex.YMin + ((ex.XMax - ex.XMin) / w) * h);

  dpi = 96 ;
  
  if (!dlgSaveImage->Execute()) return ;
  
  path = dlgSaveImage->FileName ;
    // save image from the viewer to file
  switch ( dlgSaveImage->FilterIndex) {
    case 1 : ext = ".bmp"; sub = TGIS_PixelSubFormat::BMP; comp = TGIS_CompressionType::None; break;
    case 2 : ext = ".jpg"; sub = TGIS_PixelSubFormat::JPEG; comp = TGIS_CompressionType::JPEG;; break;
    case 3 : ext = ".png"; sub = TGIS_PixelSubFormat::PNG; comp = TGIS_CompressionType::PNG;; break;
    case 4 : ext = ".tif"; sub = TGIS_PixelSubFormat::None; comp = TGIS_CompressionType::None;; break;
  }

  if ( CompareText( ExtractFileExt(path), "") == 0 ) {
    path = path + ext;
  }
  lp = (TGIS_LayerPixel *)( GisCreateLayer( path, path ) ) ;
  try {
    sf = TGIS_LayerPixelSubFormat( TGIS_PixelFormat::RGB, False, sub, comp, 90 ) ;

	lp->Build( lp->Path, false, GIS->CS, ex, w, h, sf  ) ;

    pem = new TGIS_PixelExportManager( lp ) ;
	try {

      vbmp = new TGIS_ViewerBmp ;
      try {
		pem->ExportFrom( *GIS, *vbmp, ex, dpi ) ;
      }
      __finally {
        delete vbmp ;
      }
    }
    __finally {
      delete pem ;
    }
  }
  __finally {
    lp->SaveData() ;
    delete lp ;
  };
    
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::actSaveAllExecute(TObject *Sender)
{
  GIS->SaveAll();  
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnChangeModeClick(TObject *Sender)
{
  if( GIS_ControlLegend->Mode == TGIS_ControlLegendMode::Layers ){
    GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Groups ;
  } else {
      GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Layers ;
  }
}
//---------------------------------------------------------------------------


void __fastcall TfrmMain::actCSExecute(TObject *Sender)
{
  TGIS_ControlCSSystem *dlg ;
  TGIS_HelpEvent he ;

  dlg = new TGIS_ControlCSSystem( this ) ;
  try {
    he = NULL ;
    if ( ( dlg->Execute( GIS->CS, he) ) == mrOk ) {
      GIS->CS = dlg->CS ;
    }
  } __finally {
    delete dlg ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::actChangeModeExecute(TObject *Sender)
{
  if( GIS_ControlLegend->Mode == TGIS_ControlLegendMode::Layers ){
    GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Groups ;
  } else {
      GIS_ControlLegend->Mode = TGIS_ControlLegendMode::Layers ;
  }
}
//---------------------------------------------------------------------------

