//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to create 3D View.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControl3D"
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::btn2D3DClick(TObject *Sender)
{
  if( GIS->IsEmpty ) return ;

  GIS->View3D = !(GIS->View3D) ;
  if( GIS->View3D ){
    btn2D3D->Caption = "2D View" ;
    btnTextures->Enabled = true;
    btnRoof->Enabled = true;
    btnWalls->Enabled = true;
    Button2->Enabled = true;
    GIS_3D->Enabled = true;
  }
  else {
    btn2D3D->Caption = "3D View" ;
    btnTextures->Enabled = false;
    btnRoof->Enabled = false;
    btnWalls->Enabled = false;
    Button2->Enabled = false;
    GIS_3D->Enabled = false;
  }
  cbx3DMode->ItemIndex = 0 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  if( !(GIS->View3D) ){
    GIS->FullExtent() ;
  }
  else{
    GIS->Viewer3D->ResetView() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnOpenClick(TObject *Sender)
{
  GIS->Lock();
  try
  {
	if (GIS->View3D)
	  btn2D3DClick( this ) ;
    GIS->Close() ;
    GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() + "Samples\\3D\\Building3D.ttkproject");
    cbx3DMode->ItemIndex = 0 ;
  }
  __finally
  {
	GIS->Unlock() ;
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnNavigationClick(TObject *Sender)
{
  if( !(GIS->View3D) ) return ;
  if( !GIS->Viewer3D->AdvNavigation ){
    GIS->Viewer3D->AdvNavigation = true ;
    btnNavigation->Caption = "Std. Navigation" ;
    GIS->Viewer3D->FastMode = true ;
    btnRefresh->Caption = "Unlock Refresh" ;
  }
  else {
    GIS->Viewer3D->AdvNavigation = false ;
    btnNavigation->Caption = "Adv. Navigation" ;
    GIS->Viewer3D->FastMode = false ;
    btnRefresh->Caption = "Lock Refresh" ;
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnRefreshClick(TObject *Sender)
{
  if( !GIS->View3D ) return;
  if ( !GIS->Viewer3D->FastMode ){
    GIS->Viewer3D->FastMode = true ;
    btnRefresh->Caption = "Unlock Refresh" ;
  }
  else{
    GIS->Viewer3D->FastMode = false ;
    btnRefresh->Caption = "Lock Refresh" ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnTexturesClick(TObject *Sender)
{
  TGIS_LayerVector *lv ;
  TGIS_Bitmap *bmp;

  lv = ( TGIS_LayerVector *)( GIS->Get( "buildings") );
  if ( lv == NULL) return ;

  if ( ( lv->Params->Area->Bitmap == NULL ) || lv->Params->Area->Bitmap->IsEmpty ){
	bmp = new TGIS_Bitmap();
	try
	{
	  btnTextures->Caption = "Hide Textures" ;
	  bmp->LoadFromBitmap (Image2->Picture->Bitmap, "");
	  lv->Params->Area->Bitmap = bmp;
	  bmp->LoadFromBitmap (Image1->Picture->Bitmap, "");
	  lv->Params->Area->OutlineBitmap = bmp;
	}
	__finally
	{
	  delete bmp ;
	}
  }
  else {
    btnTextures->Caption = "Show Textures" ;
    lv->Params->Area->Bitmap = NULL ;
    lv->Params->Area->OutlineBitmap = NULL ;
  }

  GIS->Viewer3D->UpdateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  TGIS_LayerVector *lv ;
  TGIS_Shape *shp ;

  GIS->Lock();
  try
  {
    GIS->Close() ;

    lv = new TGIS_LayerVector() ;
    lv->Name = "multipatch" ;
    lv->Params->Area->Color = TGIS_Color::Yellow ;
    GIS->Add( lv ) ;
    shp = (TGIS_ShapeMultiPatch *)(lv->CreateShape( TGIS_ShapeType::MultiPatch, TGIS_DimensionType::XYZ ) );
    shp->Lock(TGIS_Lock::Projection);

    shp->AddPart() ;
    shp->SetPartType( 0, TGIS_PartType::TriangleFan ) ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(5,4,10));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 0,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 10,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 10,8,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 0,8,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,5));
    shp->AddPart() ;
    shp->SetPartType( 1, TGIS_PartType::TriangleStrip ) ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,0,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,8,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,8,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,8,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,8,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,0));
    shp->AddPart() ;
    shp->SetPartType( 2, TGIS_PartType::OuterRing ) ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(4,0,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(4,0,3));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(6,0,3));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(6,0,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,0,0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(10,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,5));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(0,0,0));
    shp->AddPart() ;
    shp->SetPartType( 3, TGIS_PartType::InnerRing ) ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(1,0,2));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(1,0,4));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(3,0,4));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(3,0,2));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(1,0,2));
    shp->AddPart() ;
    shp->SetPartType( 4, TGIS_PartType::InnerRing ) ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(7,0,2));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(7,0,4));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(9,0,4));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(9,0,2));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(7,0,2));

    shp->Unlock() ;
    GIS->FullExtent() ;

    GIS->Zoom = GIS->Zoom / 2 ;
    btn2D3DClick( this ) ;
    GIS->Viewer3D->CameraPosition = TGIS_Utils::GisPoint3D( DegToRad(10.0), DegToRad(200.0),28.0) ;
    GIS->Viewer3D->ShowLights = true ;
    GIS->Viewer3D->ShowVectorEdges = false ;
  }
  __finally
  {
    GIS->Unlock();
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
  if( GIS->View3D ){
    GIS->Viewer3D->LightVector = !(GIS->Viewer3D->LightVector) ;
    GIS->Viewer3D->UpdateWholeMap() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button3Click(TObject *Sender)
{
  TGIS_LayerVector *lv ;
  TGIS_Shape *shp  ;

  GIS->Lock();
  try
  {
    GIS->Close() ;

    lv = new TGIS_LayerVector() ;
    lv->Name = "volumetric_lines" ;
    GIS->Add( lv ) ;
    shp = lv->CreateShape( TGIS_ShapeType::Arc, TGIS_DimensionType::XYZ ) ;
    shp->Params->Line->Color = TGIS_Color::Red ;
    shp->Params->Line->Width = 450 ;
    shp->Params->Line->OutlinePattern = TGIS_BrushStyle::Clear ;
    shp->Lock(TGIS_Lock::Projection);
    shp->AddPart() ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(-50, 50, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(  0,  0,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 50,  0,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 50, 50,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 50, 50, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(100, 50, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(150, 50,  0));
    shp->Unlock() ;

    shp = lv->CreateShape(TGIS_ShapeType::Arc, TGIS_DimensionType::XYZ ) ;
    shp->Params->Line->Color = TGIS_Color::Blue;
    shp->Params->Line->Width = 350 ;
    shp->Params->Line->OutlinePattern = TGIS_BrushStyle::Clear ;
    shp->Lock(TGIS_Lock::Projection);
    shp->AddPart() ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(-50,  40, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(  0, -10,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 60, -10,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 60,  40,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 60,  40, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(110,  40, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(160,  40,  0));
    shp->Unlock() ;

    shp = lv->CreateShape( TGIS_ShapeType::Arc, TGIS_DimensionType::XYZ );
    shp->Params->Line->Color = TGIS_Color::Green;
    shp->Params->Line->Width = 250 ;
    shp->Params->Line->OutlinePattern = TGIS_BrushStyle::Clear ;
    shp->Lock(TGIS_Lock::Projection);
    shp->AddPart() ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(-50,  30, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(  0, -20,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 70, -20,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 70,  30,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 70,  30, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(120,  30, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(170,  30,  0));
    shp->Unlock() ;

    shp = lv->CreateShape( TGIS_ShapeType::Arc, TGIS_DimensionType::XYZ );
    shp->Params->Line->Color = TGIS_Color::Yellow ;
    shp->Params->Line->Width = 150 ;
    shp->Params->Line->OutlinePattern = TGIS_BrushStyle::Clear ;
    shp->Lock(TGIS_Lock::Projection);
    shp->AddPart() ;
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(-50,  20, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(  0, -30,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 80, -30,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 80,  20,  0));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D( 80,  20, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(130,  20, 50));
    shp->AddPoint3D(TGIS_Utils::GisPoint3D(120,  30, 50));
    shp->Unlock() ;

    GIS->FullExtent() ;
    btn2D3DClick( this ) ;
    GIS->Viewer3D->ShowLights = true ;
  }
  __finally
  {
    GIS->Unlock();
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnWallsClick(TObject *Sender)
{
  TGIS_LayerVector *lv ;

  lv = ( TGIS_LayerVector *)( GIS->Get( "buildings") );
  if( lv == NULL ) return;

  if( lv->Params->Area->OutlinePattern == TGIS_BrushStyle::Clear ){
    btnWalls->Caption = "Hide walls" ;
    lv->Params->Area->OutlinePattern = TGIS_BrushStyle::Solid ;
  }
  else{
    lv->Params->Area->OutlinePattern = TGIS_BrushStyle::Clear ;
    btnWalls->Caption = "Show walls" ;
  } ;
 GIS->Viewer3D->UpdateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnRoofClick(TObject *Sender)
{
  TGIS_LayerVector *lv  ;

  lv = (TGIS_LayerVector *)( GIS->Get( "buildings") ) ;
  if( lv == NULL) return ;

  if( lv->Params->Area->Pattern == TGIS_BrushStyle::Clear){
    btnRoof->Caption = "Hide roof" ;
    lv->Params->Area->Pattern = TGIS_BrushStyle::Solid ;
  }
  else{
    lv->Params->Area->Pattern = TGIS_BrushStyle::Clear ;
    btnRoof->Caption = "Show roof" ;
  }
  GIS->Viewer3D->UpdateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbx3DModeChange(TObject *Sender)
{
  if ( !GIS->View3D ) return ;

  switch ( cbx3DMode->ItemIndex ){
    case 0 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::CameraPosition;
             break;
    case 1 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::CameraXYZ ;
             break ;
    case 2 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::CameraXY ;
             break ;
    case 3 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::CameraRotation ;
             break ;
    case 4 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::SunPosition ;
             break ;
    case 5 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::Zoom ;
             break ;
    case 6 : GIS->Viewer3D->Mode = TGIS_Viewer3DMode::Select ;
             break ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  GIS->View3D = false ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  btnTextures->Enabled = false;
  btnRoof->Enabled = false;
  btnWalls->Enabled = false;
  Button2->Enabled = false;
  //GIS_3D.GIS_Viewer := GIS;
  cbx3DMode->ItemIndex = 0 ;
  cbx3DModeChange( this );
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  TGIS_Shape *shp ;
  int prec ;

  // if there is no layer or we are not in select mode, exit
  if ( GIS->IsEmpty ) return ; ;
  if ( GIS->InPaint ) return ;
  
  if( ( GIS->View3D ) && ( GIS->Viewer3D->Mode == TGIS_Viewer3DMode::Select ) ){
    prec = 20 ;
    shp = ( TGIS_Shape *)(GIS->Locate(Point(X, Y), prec));
    if( shp !=NULL ){
      shp->IsSelected = !( shp->IsSelected );
      GIS->Viewer3D->UpdateAllSelectedObjects();
    }
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  TPoint pt  ;
  TGIS_Point3D cam ;

  if( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  if( GIS->View3D ){
    // allows MouseWheel works properly in ZoomMode
    GIS->Viewer3D->StoreMousePos( pt ) ;

    cam = GIS->Viewer3D->CameraPosition ;
    cam.Z = cam.Z  / ( 1 + 0.05 ) ;
    GIS->Viewer3D->CameraPosition = cam ;
  }
  else{
	GIS->ZoomBy( 3./2., pt.X, pt.Y );
  }
  Handled = true ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
		  bool &Handled)
{
  TPoint pt ;
  TGIS_Point3D cam ;

  if( GIS->IsEmpty ) return ;

  pt = GIS->ScreenToClient( MousePos ) ;

  if( GIS->View3D ){
	// allows MouseWheel works properly in ZoomMode
	GIS->Viewer3D->StoreMousePos( pt ) ;

	cam = GIS->Viewer3D->CameraPosition ;
	cam.Z = cam.Z  * ( 1 + 0.05 ) ;
	GIS->Viewer3D->CameraPosition = cam ;
  }
  else {
   GIS->ZoomBy( 2./3., pt.X, pt.Y );
  }

  Handled = True ;
}
//---------------------------------------------------------------------------

