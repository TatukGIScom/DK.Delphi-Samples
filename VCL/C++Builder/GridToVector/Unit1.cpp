//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma link "VCL.GisControlAttributes"

#pragma resource "*.dfm"
TForm10 *Form10;
//---------------------------------------------------------------------------
__fastcall TForm10::TForm10(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm10::FormShow(TObject *Sender)
{
  btnLandCoverClick( Sender ) ;
  GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

void __fastcall TForm10::btnLandCoverClick(TObject *Sender)
{
  UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\Luxembourg\\CLC2018_CLC2018_V2018_20_Luxembourg.tif" ;
  GIS->Open( path ) ;
  edtTolerance->Text = "1" ;
}
//---------------------------------------------------------------------------

void __fastcall TForm10::btnDemClick(TObject *Sender)
{
  UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"Samples\\3D\\elevation.grd" ;
  GIS->Open( path ) ;
  GIS->FullExtent();
  TGIS_LayerPixel *lp = (TGIS_LayerPixel*)( GIS->Get( "elevation") ) ;
  lp->GenerateRamp(
	TGIS_Color::Blue,
	TGIS_Color::Lime,
	TGIS_Color::Red,
	lp->MinHeight,
	( lp->MinHeight + lp->MaxHeight ) / 2,
	lp->MaxHeight,
	True,
	( lp->MaxHeight - lp->MinHeight ) / 100,
	( lp->MaxHeight - lp->MinHeight ) / 10,
	NULL,
	true
  ) ;
  GIS->InvalidateWholeMap() ;
  edtTolerance->Text = "10" ;
}
//---------------------------------------------------------------------------
void __fastcall TForm10::doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
  if (_pos < 0)
  {
	pbprogress->Position = pbprogress->Max ;
  }
  else
  if (_pos == 0)
  {
	pbprogress->Min = 0 ;
	pbprogress->Max = _end ;
	pbprogress->Position = 0 ;
  }
  else
  {
	pbprogress->Position = _pos ;
  }
  Application->ProcessMessages();
}

void __fastcall TForm10::btnGenerateClick(TObject *Sender)
{
  TGIS_LayerPixel *lp = (TGIS_LayerPixel*)(  GIS->Items->Items[0] ) ;

  if (GIS->Get( "polygons" ) != NULL)
	GIS->Delete( "polygons" ) ;

  TGIS_LayerVector *lv = new TGIS_LayerVector() ;
  lv->Name = "polygons" ;
  lv->Open() ;
  lv->CS = lp->CS ;
  lv->DefaultShapeType = TGIS_ShapeType::Polygon ;
  lv->AddField( "value", TGIS_FieldType::Float, 0, 0 ) ;
  lv->Transparency = 50 ;
  lv->Params->Area->OutlineColor = TGIS_Color::Black;

  TGIS_GridToPolygon *polygonizer = new TGIS_GridToPolygon() ;
  try
  {
	polygonizer->Tolerance = StrToFloat( edtTolerance->Text ) ;
	polygonizer->SplitShapes = chkSplit->Checked ;
	polygonizer->BusyEvent = doBusyEvent ;

	polygonizer->Generate( lp, lv, "value" ) ;
  }
  __finally
  {
	delete  polygonizer ;
  } ;

  GIS->Add( lv ) ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm10::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{

  TGIS_Shape *shp = (TGIS_Shape*)(
	GIS->Locate( GIS->ScreenToMap( Point( X,  Y ) ), 5 / GIS->Zoom )
  ) ;

  if ( shp == NULL ) exit ;

  shp->Layer->DeselectAll() ;
  shp->IsSelected = ! shp->IsSelected ;

  GIS_ControlAttributes->ShowShape( shp ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm10::GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  if (GIS->IsEmpty)  exit;

  TPoint pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 0.5, pt.X, pt.Y ) ;
}
//---------------------------------------------------------------------------


void __fastcall TForm10::GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  if (GIS->IsEmpty)  exit;

  TPoint pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 2, pt.X, pt.Y ) ;
}
//---------------------------------------------------------------------------

