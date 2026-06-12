/*
 * GridToVector sample — demonstrates raster-to-vector conversion using
 * TGIS_GridToPolygon (raster to polygon) and TGIS_GridToPoint (raster to point).
 *
 * Two source datasets are available:
 *   Land Cover TIFF (Corine CLC2018, Luxembourg) and a DEM grid (elevation.grd).
 * Common parameters (tolerance) control the vectorisation quality.
 */
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

/* Loads the Land Cover dataset by default and sets the viewer to select mode on startup. */
void __fastcall TForm10::FormShow(TObject *Sender)
{
  btnLandCoverClick( Sender ) ;
  GIS->Mode = TGIS_ViewerMode::Select ;
}
//---------------------------------------------------------------------------

/* Loads the Corine Land Cover 2018 TIFF for Luxembourg and sets default tolerance value. */
void __fastcall TForm10::btnLandCoverClick(TObject *Sender)
{
  UnicodeString path = TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\Luxembourg\\CLC2018_CLC2018_V2018_20_Luxembourg.tif" ;
  GIS->Open( path ) ;
  edtTolerance->Text = "1" ;
}
//---------------------------------------------------------------------------

/* Loads an elevation grid, applies a blue-lime-red colour ramp, and sets default tolerance value. */
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
/* Reports rasterisation progress on the progress bar.
   _pos < 0 fills to max; _pos == 0 initialises; otherwise updates the position. */
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

/* Converts the source raster to a polygon vector layer using TGIS_GridToPolygon
   with the tolerance and split-shapes settings.  Any existing result is removed first.
   The output is added with 50% transparency and a black outline. */
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

/* Locates the shape under the cursor, selects it, and shows its attributes in the attribute control. */
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

/* Zooms out centred on the cursor position on mouse-wheel-down. */
void __fastcall TForm10::GISMouseWheelDown(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  if (GIS->IsEmpty)  exit;

  TPoint pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 0.5, pt.X, pt.Y ) ;
}
//---------------------------------------------------------------------------

/* Zooms in centred on the cursor position on mouse-wheel-up. */
void __fastcall TForm10::GISMouseWheelUp(TObject *Sender, TShiftState Shift, TPoint &MousePos,
          bool &Handled)
{
  if (GIS->IsEmpty)  exit;

  TPoint pt = GIS->ScreenToClient( MousePos ) ;
  GIS->ZoomBy( 2, pt.X, pt.Y ) ;
}
//---------------------------------------------------------------------------

