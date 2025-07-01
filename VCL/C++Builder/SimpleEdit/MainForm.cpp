//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provide editing functionality.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "MainForm.h"
#include "InfoForm.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void TfrmMain::endEdit()
{
  btnEdit->Enabled    = False ;
  btnRevert->Enabled  = False ;
  btnDelete->Enabled  = False ;
  btnWinding->Enabled = False ;

  editLayer = NULL ;
  GIS->Editor->EndEdit() ;

  if ( btnShowInfo->Down )
    frmInfo->ShowInfo( NULL ) ;
} ;
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
  TGIS_Layer *ll ;
  Integer i ;

  stsBar->Panels->Items[3]->Text = "See: www.tatukgis.com" ;
  GIS->Open( GisSamplesDataDirDownload() + "\\samples\\SimpleEdit\\simpleedit.ttkproject" ) ;

  cmbLayer->Items->Add( "Show all" ) ;
  for (i=0; i<=GIS->Items->Count - 1; i++) {
    ll = (TGIS_Layer *)( GIS->Items->Items[i] ) ;
    if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
      cmbLayer->Items->Add( ll->Name ) ;
  }

  if ( GIS->Items->Count > 0 )
    cmbLayer->ItemIndex = 0 ;

  cmbSnap->Items->Add( "No snapping" ) ;
  for (i=0; i<=GIS->Items->Count - 1; i++) {
    ll = (TGIS_Layer *)( GIS->Items->Items[i] ) ;
    if ( ll->InheritsFrom( __classid(TGIS_LayerVector) ) )
      cmbSnap->Items->Add( ll->Name ) ;
  }

  if ( GIS->Items->Count > 0 )
    cmbSnap->ItemIndex = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::FormCloseQuery(TObject *Sender, bool &CanClose)
{
  endEdit() ;
  btnSelectClick( Sender ) ;

  if ( !GIS->MustSave() ) return ;

#ifdef __BCPLUSPLUS__  >= 0x0640
 if ( Application->MessageBox( L"Save all unsaved work?",
                               L"TatukGIS", MB_YESNO) == IDYES
     ) GIS->SaveAll() ;
#else
  if ( Application->MessageBox( "Save all unsaved work?",
                                "TatukGIS", MB_YESNO) == IDYES
     ) GIS->SaveAll() ;
#endif
}
//---------------------------------------------------------------------------


void __fastcall TfrmMain::GISEditorChange(TObject *Sender)
{
  btnUndo->Enabled = GIS->Editor->CanUndo ;
  btnRedo->Enabled = GIS->Editor->CanRedo ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  if ( GIS->IsEmpty ) return;
  if ( Key == VK_CONTROL ) {
    if (!vkControl ) { // avoid multiple call on key repeat ;
      GIS->Mode = TGIS_ViewerMode::Select ;
      vkControl = True ;
    }
  }
  if ( Key == VK_DELETE ) {
    if ( GIS->Mode == TGIS_ViewerMode::Edit ) {
      GIS->Editor->DeleteShape() ;
      GIS->Mode = TGIS_ViewerMode::Select ;
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  if ( GIS->IsEmpty ) return;
  if ( Key == VK_CONTROL ) {
    if      ( btnEdit->Down )
            GIS->Mode = TGIS_ViewerMode::Edit ;
    else if ( btnDrag->Down )
            GIS->Mode = TGIS_ViewerMode::Drag ;
    vkControl = False ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnSaveClick(TObject *Sender)
{
  endEdit() ;
  btnSelectClick( Sender ) ;
  GIS->SaveAll() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnZoomClick(TObject *Sender)
{
  endEdit() ;
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnDragClick(TObject *Sender)
{
  endEdit() ;
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnSelectClick(TObject *Sender)
{
  btnSelect->Down = True ;
  endEdit() ;
  GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnEditClick(TObject *Sender)
{
  btnEdit->Enabled    = True ;
  btnRevert->Enabled  = True ;
  btnDelete->Enabled  = True ;
  btnWinding->Enabled = True ;

  btnEdit->Down = True ;
  if ( GIS->Mode == TGIS_ViewerMode::Edit ) return ;
  endEdit() ;
  GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnAddShapeClick(TObject *Sender)
{
  endEdit() ;
  GIS->Mode = TGIS_ViewerMode::Edit ;
  editLayer = GIS->Get( cmbLayer->Items->Strings[ cmbLayer->ItemIndex ] );
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnRedoClick(TObject *Sender)
{
  GIS->Editor->Redo() ;
  if ( GIS->AutoCenter )
    GIS->Zoom = GIS->Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnUndoClick(TObject *Sender)
{
  GIS->Editor->Undo() ;
  if ( GIS->AutoCenter )
    GIS->Zoom = GIS->Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnRevertClick(TObject *Sender)
{
  GIS->Editor->RevertShape() ;
  if ( btnShowInfo->Down )
    frmInfo->ShowInfo( (TGIS_Shape *)( GIS->Editor->CurrentShape ) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnDeleteClick(TObject *Sender)
{
  GIS->Editor->DeleteShape() ;
  btnSelectClick( Sender ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnShowInfoClick(TObject *Sender)
{
  if ( btnShowInfo->Down ) {
    frmInfo->ShowInfo( (TGIS_Shape *)( GIS->Editor->CurrentShape ) ) ;
    frmInfo->Show() ;
  }
  else
    frmInfo->Hide() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnAutoCenterClick(TObject *Sender)
{
  GIS->AutoCenter = btnAutoCenter->Down ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::cmbLayerChange(TObject *Sender)
{
  Integer i ;
  TGIS_Layer *ll ;

  endEdit() ;
  GIS->SetFocus() ;
  btnSelectClick( Sender ) ;

  for (i=1; i<=cmbLayer->Items->Count - 1; i++) {
    ll = ( TGIS_Layer* )( GIS->Get( cmbLayer->Items->Strings[ i ] ) );
    if ( cmbLayer->ItemIndex == 0 )
      ll->Active = True ;
    else
      ll->Active = ( i == cmbLayer->ItemIndex ) ;
  }

  btnAddShape->Enabled = ( cmbLayer->ItemIndex != 0 ) ;

  GIS->InvalidateWholeMap();
}
//---------------------------------------------------------------------------


void __fastcall TfrmMain::btnPrintClick(TObject *Sender)
{
  if ( dlgPrint->Execute() ) {
    GIS->Print(0) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISMouseMove(TObject *Sender, TShiftState Shift,
      int X, int Y)
{
  TGIS_Point ptg ;
  AnsiString tmp;

  if ( GIS->IsEmpty ) return;
  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;
  stsBar->Panels->Items[1]->Text = tmp.sprintf( "x: %.4f", ptg.X ) ;
  stsBar->Panels->Items[1]->Text = tmp.sprintf( "x: %.4f", ptg.X ) ;
  stsBar->Panels->Items[2]->Text = tmp.sprintf( "y: %.4f", ptg.Y ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnWindingClick(TObject *Sender)
{
  GIS->Editor->ChangeWinding() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::mnuAddPartClick(TObject *Sender)
{
  GIS->Editor->CreatePart( GisPoint3DFrom2D( menuPos ) ) ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::mnuDeletePartClick(TObject *Sender)
{
  GIS->Editor->DeletePart() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::cmbSnapChange(TObject *Sender)
{
  if ( cmbSnap->ItemIndex > 0 )
    GIS->Editor->SnapLayer = GIS->Get( cmbSnap->Items->Strings[ cmbSnap->ItemIndex ] ) ;
  else
	GIS->Editor->SnapLayer = NULL ;

  GIS->InvalidateEditor(TRUE);
}
//---------------------------------------------------------------------------




void __fastcall TfrmMain::GISMouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
 TPoint      pt   ;
  TGIS_Point  ptg  ;
  TGIS_Shape *shp  ;
  Double      dist ;
  Integer     part ;
  TGIS_Point  proj ;

  if ( GIS->IsEmpty ) return;
  if ( GIS->InPaint ) return ;

  ptg = GIS->ScreenToMap( Point( X, Y ) ) ;

  switch ( Button ) {
    case mbRight : {
                     if ( GIS->Mode == TGIS_ViewerMode::Edit ) {
                       menuPos = ptg ;
                       pt = ClientToScreen( Point( X, Y ) ) ;
                       mnuPopup->Popup( pt.x, pt.y ) ;
                     }
                     break ;
                   }
    case mbLeft  : {
                     if ( GIS->Mode == TGIS_ViewerMode::Edit ) {
                       if ( editLayer == NULL ) return ;
                       else {
                         GIS->Editor->CreateShape( editLayer, ptg, TGIS_ShapeType::Unknown ) ;
                         if ( cmbSnap->ItemIndex > 0 )
                           GIS->Editor->SnapLayer = GIS->Get( cmbSnap->Items->Strings[ cmbSnap->ItemIndex ] ) ;
                         else
                           GIS->Editor->SnapLayer = NULL ;

						 GIS->InvalidateEditor(TRUE);
                         if ( btnShowInfo->Down )
                           frmInfo->ShowInfo( (TGIS_Shape *)( GIS->Editor->CurrentShape ) ) ;
                         editLayer = NULL ;
                         btnEditClick( Sender ) ;
                       }
                     }
                     else if ( GIS->Mode == TGIS_ViewerMode::Select ) {
                       endEdit() ;
                       if ( btnShowInfo->Down )
                         frmInfo->ShowInfo( NULL ) ;
                       shp = (TGIS_Shape *)( GIS->Locate( ptg, 5/GIS->Zoom, TRUE  ) ) ;
                       if ( shp == NULL ) return ;

                       if ( cmbLayer->ItemIndex != 0 ) {
                         if ( shp->Layer !=
                             GIS->Get( cmbLayer->Items->Strings[cmbLayer->ItemIndex] )
                            ) return ;
                       }

					   shp = shp->Layer->LocateEx( ptg, 5/GIS->Zoom, -1, dist, part, proj, TRUE ) ;
                       if ( shp == NULL ) return ;

                       GIS->Editor->EditShape( shp, part ) ;
                       if ( cmbSnap->ItemIndex > 0 )
                         GIS->Editor->SnapLayer =
                           GIS->Get( cmbSnap->Items->Strings[ cmbSnap->ItemIndex ] ) ;
                       else
						 GIS->Editor->SnapLayer = NULL ;

					   GIS->InvalidateEditor(TRUE);
                       GIS->Mode = TGIS_ViewerMode::Edit ;

                       if ( btnShowInfo->Down )
                         frmInfo->ShowInfo( shp ) ;
                       btnEditClick( Sender) ;
                     } ;
                     break ;
                   }
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::ToolButton7Click(TObject *Sender)
{
  GIS->Editor->EditingLinesStyle->PenStyle = TGIS_PenStyle::Dash ;
  GIS->Editor->EditingLinesStyle->PenColor = TGIS_Color::Lime ;

  GIS->Editor->EditingPointsStyle->PointsFont->Name = "Verdana" ;
  GIS->Editor->EditingPointsStyle->PointsFont->Size = 8 ;
  GIS->Editor->EditingPointsStyle->PointsFont->Color = TGIS_Color::White ;
  GIS->Editor->EditingPointsStyle->PointsBackground = TGIS_Color::Green ;

  GIS->Editor->EditingPointsStyle->ActivePoints->BrushStyle   = TGIS_BrushStyle::Solid ;
  GIS->Editor->EditingPointsStyle->ActivePoints->BrushColor   = TGIS_Color::Green ;
  GIS->Editor->EditingPointsStyle->ActivePoints->PenStyle     = TGIS_PenStyle::Solid ;
  GIS->Editor->EditingPointsStyle->ActivePoints->PenColor     = TGIS_Color::Black ;

  GIS->Editor->EditingPointsStyle->InactivePoints->BrushStyle = TGIS_BrushStyle::Solid ;
  GIS->Editor->EditingPointsStyle->InactivePoints->BrushColor = TGIS_Color::Blue ;
  GIS->Editor->EditingPointsStyle->InactivePoints->PenStyle   = TGIS_PenStyle::Solid ;
  GIS->Editor->EditingPointsStyle->InactivePoints->PenColor   = TGIS_Color::Black ;

  GIS->Editor->EditingPointsStyle->SelectedPoints->BrushStyle = TGIS_BrushStyle::Solid ;
  GIS->Editor->EditingPointsStyle->SelectedPoints->BrushColor = TGIS_Color::Red ;
  GIS->Editor->EditingPointsStyle->SelectedPoints->PenStyle   = TGIS_PenStyle::Solid ;
  GIS->Editor->EditingPointsStyle->SelectedPoints->PenColor   = TGIS_Color::Black ;

  GIS->Editor->EditingPointsStyle->Points3D->BrushStyle      = TGIS_BrushStyle::Solid ;
  GIS->Editor->EditingPointsStyle->Points3D->BrushColor      = TGIS_Color::Purple ;
  GIS->Editor->EditingPointsStyle->Points3D->PenStyle        = TGIS_PenStyle::Solid ;
  GIS->Editor->EditingPointsStyle->Points3D->PenColor        = TGIS_Color::Olive ;

  GIS->Editor->EditingPointsStyle->SnappingPoints->BrushStyle = TGIS_BrushStyle::Solid ;
  GIS->Editor->EditingPointsStyle->SnappingPoints->BrushColor = TGIS_Color::Red ;
  GIS->Editor->EditingPointsStyle->SnappingPoints->PenStyle   = TGIS_PenStyle::Solid ;
  GIS->Editor->EditingPointsStyle->SnappingPoints->PenColor   = TGIS_Color::Yellow ;

  if ( GIS->Editor->InEdit ) {
    GIS->Editor->RefreshShape();
  }

}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::GISAfterPaintEvent(TObject *Sender, TObject *_canvas)
{
   AnsiString tmp;
   stsBar->Panels->Items[0]->Text = tmp.sprintf( "zoom: %.4f", GIS->ZoomEx ) ;
}
//---------------------------------------------------------------------------

