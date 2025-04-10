//=============================================================================3
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "MainForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------

__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
  layerSrc     = NULL ;
  layerResult  = NULL ;
  geoObj       = NULL ;
  infoFields   = NULL ;
  fieldNames   = NULL ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  infoFields = new TStringList ;
  infoFields->Add ( "STATEFP" ) ;
  infoFields->Add ( "COUNTYFP"   ) ;
  infoFields->Add ( "SMID"  ) ;
  infoFields->Add ( "FEATCAT"   ) ;
  infoFields->Add ( "MTFCC"  ) ;
  fieldNames = new TStringList ;
  fieldNames->Add ( "FULLNAME" ) ;
  fieldNames->Add ( "LFROMADD" ) ;
  fieldNames->Add ( "LTOADD" ) ;
  fieldNames->Add ( "RFROMADD" ) ;
  fieldNames->Add ( "RTOADD" ) ;
  fieldNames->Add ( "ZIPL"   ) ;
  fieldNames->Add ( "ZIPR"   ) ;
  selectedRow = -1;
  state = -1;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
  if ( infoFields )
    delete infoFields ;
  if ( fieldNames )
    delete fieldNames ;
  if ( geoObj ) ;
    delete geoObj ;
  if ( layerSrc )
    GIS->Close() ;
}
//---------------------------------------------------------------------------

void TForm1::openCoverage( const String _path )
{
  // for pretty view
  Update();

  // free what it wants to
  hideInfo();
  if ( layerResult ) {
    GIS->Delete( layerResult->Name ) ;
    layerResult = NULL ;
  }
  if ( geoObj )
    delete geoObj ;
  if ( layerSrc )
    GIS->Close();
  btnFindFirst->Enabled = FALSE ;
  btnFindAll->Enabled = FALSE ;
  btnHelp->Enabled = FALSE ;
  btnMatches->Enabled = FALSE ;

  ProgressBar1->Visible = TRUE ;
  GIS->BusyEvent = OnBusy;
  GIS->Lock();
  GIS->Open( _path, TRUE ) ;
  GIS->BusyEvent = NULL ;
  ProgressBar1->Visible = FALSE ;

  layerSrc = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
  if ( !layerSrc ) return ;
  if ( !layerSrc->InheritsFrom( __classid(TGIS_LayerVector) ) ) return ;

  layerSrc->Params->Line->SmartSize = -1;
  layerSrc->Params->Labels->Field = "FENAME";
  layerSrc->Params->Labels->Alignment = TGIS_LabelAlignment::Follow;
  layerSrc->Params->Labels->Color = TGIS_Color::Black;

  layerSrc->ParamsList->Add();
  layerSrc->Params->Query = "CFCC < 'A4";
  layerSrc->Params->Line->Width = -2;
  layerSrc->Params->Line->Style = TGIS_PenStyle::Solid;
  layerSrc->UseConfig = FALSE;

  // create route layer
  layerResult = new TGIS_LayerVector ;
  layerResult->UseConfig = FALSE ;
  layerResult->Params->Line->Color = TGIS_Color::Red ;
  layerResult->Params->Line->Width = -2 ;
  layerResult->Params->Marker->OutlineWidth = 1 ;
  layerResult->Name = "RouteDisplay" ;
  GIS->Add( layerResult ) ;

  // create geocod+ing object, set fields for routing
  geoObj = new TGIS_Geocoding( layerSrc ) ;
  geoObj->Offset = 0.0001  ;
  geoObj->LoadFormulas( GisSamplesDataDirDownload() + "\\Samples\\Geocoding\\us_addresses.geo",
                        GisSamplesDataDirDownload() + "\\Samples\\Geocoding\\tiger2008.geo",
                        ""
                      ) ;

  GIS->Unlock();
  GIS->RecalcExtent() ;
  GIS->FullExtent() ;

  GIS_ControlScale1->Visible = TRUE ;

  btnFindFirst->Enabled = TRUE ;
  btnFindAll->Enabled = TRUE ;
  btnHelp->Enabled = TRUE ;

  // focus on edit window
  edtAddress->Text = "";
  edtAddress->SetFocus();

  sgrdMemo->Cols[0]->Clear();
  sgrdMemo->RowCount = 1;
  sgrdMemo->PopupMenu = NULL;
  state = -1;
  selectedRow = -1;
}
//---------------------------------------------------------------------------

// Displays progress during opening file. }
void _fastcall TForm1::OnBusy(TObject * _sender, int _pos,
          const int _end, bool &_abort)
{
  // show progress
  if (_pos == 0) {
    ProgressBar1->Min = 0;
    ProgressBar1->Position = 0;
    ProgressBar1->Max = 100;
    doAbort = FALSE ;
  } else if ( _pos == -1 ) {
    ProgressBar1->Position = 100;
    ProgressBar1->Max = 100;
  } else {
    if ( doAbort )
      _abort = TRUE ;
    else {
      ProgressBar1->Position = _pos;
      ProgressBar1->Max = _end;
    }
  }
  Application->ProcessMessages() ;
}
//---------------------------------------------------------------------------

// Matches the address string and searches geocoding results.
int TForm1::parse( bool _findFirst, bool _extendedScope )
{
  int resval ;

  resval = 0 ;

  TGIS_ObjectList *resolvedAddresses  ;
  TGIS_ObjectList *resolvedAddresses2 ;

  resolvedAddresses  = NULL ;
  resolvedAddresses2 = NULL ;

  try {
    if ( geoObj->Match( edtAddress->Text, resolvedAddresses, resolvedAddresses2 ) ) {
      FormMatches->ShowMatches ( resolvedAddresses,
                                 resolvedAddresses2
                               ) ;
      resval = geoObj->ParseEx ( resolvedAddresses,
                                 resolvedAddresses2,
                                 _findFirst,
                                 _extendedScope,
                                 TRUE
                               ) ;
      btnMatches->Enabled = TRUE ;
     }
   } __finally {
   if ( resolvedAddresses )
     FreeObjectNotNil( resolvedAddresses ) ;
   if ( resolvedAddresses2 )
     FreeObjectNotNil( resolvedAddresses2 ) ;
  } ;

  return resval ;
}

//---------------------------------------------------------------------------

// Finds address and displays results. }
void TForm1::findAddress( bool _findFirst     ,
                          bool _extendedScope
                        )
{
  int         i   ;
  int         j   ;
  int         r   ;
  TGIS_Shape *shp ;
  String      s   ;

  if ( !geoObj ) {
    #ifdef __BCPLUSPLUS__  >= 0x0640
      Application->MessageBox(L"Open a TIGER/Line file.", L"Open Error", 0);
    #else
      Application->MessageBox( "Open a TIGER/Line file.",  "Open Error", 0);
    #endif
    return ;
  }

  layerResult->RevertShapes() ;
  hideInfo();
  sgrdMemo->Cols[0]->Clear();
  sgrdMemo->RowCount = 1;
  sgrdMemo->PopupMenu = NULL;
  state = -1;
  selectedRow = -1;
  btnMatches->Enabled = False ;

  // locate shapes meeting query
  Screen->Cursor = crHourGlass;
  try {
    r = parse( _findFirst, _extendedScope ) -1 ;
  } catch( EGIS_Exception &E) {
    ShowMessage( "EGIS exception: " + E.Message );
    r = -1;
  } catch( Exception &E) {
    ShowMessage( "Exception: " + E.Message );
    r = -1;
  }

  if (r < 0) {
    edtAddress->Text = edtAddress->Text + " ???";
  } else {
    if ( _findFirst == True ) {
      sgrdMemo->ShowHint = FALSE ;
      state = 0;
    }  else {
      sgrdMemo->ShowHint = TRUE;
      state = 1;
    };
  };

  sgrdMemo->Cols[0]->BeginUpdate();
  for ( i=0; i<=r; i++ ) {
    // add found shape to route layer (red color)
    shp = layerSrc->GetShape( geoObj->Uid[i] ) ;
    layerResult->AddShape( shp, FALSE ) ;

    if (i == 0) {
      layerResult->Extent = shp->Extent ;
    };

    if ( _findFirst == True ) {
      if (i == 0) {
        for ( j=0; j<fieldNames->Count; j++ ) {
          s = shp->GetField( fieldNames->Strings[j] );
          if ( j > 0 )
            sgrdMemo->RowCount = sgrdMemo->RowCount + 1;
          sgrdMemo->Cells[0][sgrdMemo->RowCount-1] = fieldNames->Strings[j] + "=" + s;
        };
      };
    } else {
      if (i > 0)
        sgrdMemo->RowCount = sgrdMemo->RowCount + 1;
      sgrdMemo->Cells[0][sgrdMemo->RowCount-1] = geoObj->Query[i] ;
    };

    shp = layerSrc->GetShape( geoObj->UidEx[i] ) ;
    if ( shp ) {
      layerResult->AddShape( shp, FALSE ) ;
      if ( _findFirst == True ) {
        if ( i == 0 ) {
          sgrdMemo->RowCount = sgrdMemo->RowCount + 1;
          sgrdMemo->Cells[0][sgrdMemo->RowCount-1] = "---------------------------";
          for ( j=0; j<fieldNames->Count; j++ ) {
            s = shp->GetField( fieldNames->Strings[j] );
            sgrdMemo->RowCount = sgrdMemo->RowCount + 1;
            sgrdMemo->Cells[0][sgrdMemo->RowCount-1] = fieldNames->Strings[j] + "=" + s;
          };
        };
      } ;
    };

    // mark address as green squere
    shp = layerResult->CreateShape( TGIS_ShapeType::Point ) ;
    shp->Lock( TGIS_Lock::Extent );
      shp->AddPart() ;
      shp->AddPoint( geoObj->Point[i] ) ;
      shp->Params->Marker->Color = TGIS_Color::Yellow ;
    shp->Unlock() ;
  }
  sgrdMemo->Cols[0]->EndUpdate();

  GIS->Lock();
    GIS->VisibleExtent = layerResult->Extent ;
    GIS->Zoom = 0.7 * GIS->Zoom ;
  GIS->Unlock();

  Screen->Cursor = crDefault;
  sgrdMemo->SetFocus();
}
//---------------------------------------------------------------------------

// Displays info in the window.
void TForm1::showInfo()
{
  TGIS_Shape *shp ;
  int         j   ;

  if ( !layerSrc ) return;
  if ( selectedRow == -1 ) return;

  FormInfo->sgrdInfo->Cols[0]->Clear();
  FormInfo->sgrdInfo->Cols[1]->Clear();

  // get current shape
  shp = layerSrc->GetShape( geoObj->Uid[selectedRow] ) ;
  GIS->VisibleExtent = shp->Extent  ;

  FormInfo->sgrdInfo->Cells[0][0] = "Shape Id" ;
  FormInfo->sgrdInfo->Cells[1][0] = IntToStr( shp->Uid );
  for ( j=1; j<=fieldNames->Count; j++ ) {
    FormInfo->sgrdInfo->Cells[0][j] = fieldNames->Strings[j-1];
    FormInfo->sgrdInfo->Cells[1][j] = shp->GetField( fieldNames->Strings[j-1] );
  }

  // display info in the info window
  shp = layerSrc->GetShape( geoObj->UidEx[selectedRow] ) ;
  if ( shp ) {
    FormInfo->sgrdInfo->Cells[0][fieldNames->Count+1] = "------------------------";
    FormInfo->sgrdInfo->Cells[1][fieldNames->Count+1] = "------------------------";
    FormInfo->sgrdInfo->Cells[0][fieldNames->Count+2] = "Shape Id" ;
    FormInfo->sgrdInfo->Cells[1][fieldNames->Count+2] = IntToStr( shp->Uid );
    for ( j=1; j<=fieldNames->Count; j++ ) {
      FormInfo->sgrdInfo->Cells[0][fieldNames->Count+2+j] = fieldNames->Strings[j-1];
      FormInfo->sgrdInfo->Cells[1][fieldNames->Count+2+j] =
                                        shp->GetField( fieldNames->Strings[j-1] );
    }
    FormInfo->Height = 465;
  } else
    FormInfo->Height = 241;

  GIS->Zoom = 0.7 * GIS->Zoom ;

  //show Info
  if ( FormInfo->Visible == False ) {
    FormInfo->FormStyle = fsStayOnTop ;
    FormInfo->Show() ;
  } else
    FormInfo->Update();
}
//---------------------------------------------------------------------------

// Hides the info window.
void TForm1::hideInfo()
{
  if ( !FormInfo ) return;
  if ( FormInfo->Visible == True )
    FormInfo->Hide();
};
//---------------------------------------------------------------------------

void __fastcall TForm1::sgrdMemoContextPopup(TObject *Sender,
      TPoint &MousePos, bool &Handled)
{
  // check if menu can be displayed
  if ( state == 1 ) {
    sgrdMemo->PopupMenu = popupMenu1;
    popupMenuRow = MousePos.y / sgrdMemo->DefaultRowHeight + sgrdMemo->TopRow;
    if ( popupMenuRow > sgrdMemo->Cols[0]->Count-1 )
      Handled = TRUE;
    else
      Handled = FALSE;
  } else if ( state == 0 ) {
    sgrdMemo->PopupMenu = popupMenu2;
    popupMenuRow = (MousePos.y / sgrdMemo->DefaultRowHeight) + sgrdMemo->TopRow;
    if ( popupMenuRow > sgrdMemo->Cols[0]->Count-1 )
      Handled = TRUE;
    else
      Handled = FALSE;
  } else
    Handled = TRUE;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::sgrdMemoDblClick(TObject *Sender)
{
  if (fShown == False)
    showInfo();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::sgrdMemoSelectCell(TObject *Sender, int ACol,
      int ARow, bool &CanSelect)
{
  // check if the cell can be selected
  CanSelect = ( ARow < sgrdMemo->Cols[0]->Count ) &&
               !( ( sgrdMemo->Cols[0]->Count == 1 ) &&
                  ( sgrdMemo->Cells[ACol][ARow] == "" )
                );
  if ( ( CanSelect == True ) && ( state == 1 ) )
    selectedRow = ARow;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnOpenDefaultClick(TObject *Sender)
{
  openCoverage( GisSamplesDataDirDownload() +  "\\World\\Countries\\USA\\States\\California\\San Bernardino\\TIGER\\tl_2008_06071_edges_trunc.shp" ) ;
}
//---------------------------------------------------------------------------

// Opens a TIGER/Line file.
void __fastcall TForm1::btnOpenClick(TObject *Sender)
{
  //open a file
  OpenDialog1->Filter = "SHP files (*.SHP)|*.SHP";
  OpenDialog1->FilterIndex = 1;

  // Display Open dialog box
  if ( OpenDialog1->Execute() ) {
    openCoverage( OpenDialog1->FileName ) ;
  };
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnHelpClick(TObject *Sender)
{
  FormHelp->Show();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFindFirstClick(TObject *Sender)
{
  findAddress( TRUE, !chkExtended->Checked );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFindAllClick(TObject *Sender)
{
  findAddress( FALSE, !chkExtended->Checked );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnMatchesClick(TObject *Sender)
{
  FormMatches->Show();
}
//---------------------------------------------------------------------------

// Writes a row text to the clipboard.
void __fastcall TForm1::mnuCopyClick(TObject *Sender)
{
  if ( state == 1 )
    Clipboard()->SetTextBuf(
      sgrdMemo->Cells[0][popupMenuRow].c_str()
    );
}
//---------------------------------------------------------------------------

// Writes a field value to the clipboard.
void __fastcall TForm1::mnuCopyvalueClick(TObject *Sender)
{
  if ( state == 0 )
    Clipboard()->SetTextBuf(
      sgrdMemo->Cols[0]->Values[sgrdMemo->Cols[0]->Names[popupMenuRow]].c_str()
    );
}
//---------------------------------------------------------------------------


void __fastcall TForm1::sgrdMemoClick(TObject *Sender)
{
  fShown = FALSE ;
  if ( FormInfo->Visible == TRUE ) {
    showInfo();
    fShown = TRUE ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  doAbort = TRUE ;
}
//---------------------------------------------------------------------------

