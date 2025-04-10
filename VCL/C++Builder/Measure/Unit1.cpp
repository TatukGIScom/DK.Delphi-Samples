//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
TGIS_LayerVector *ll;
TGIS_CSUnits *units;
bool isLine;
bool isPolygon;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  GIS->Lock();
  GIS->Open(GisSamplesDataDirDownload() + "\\World\\WorldDCW\\world.shp");

  ll = new TGIS_LayerVector();
  ll->Params->Line->Color = TGIS_Color::Red;
  ll->Params->Line->Width = 25;
  ll->SetCSByEPSG(4326);

  GIS->Add(ll);
  GIS->RestrictedExtent = GIS->Extent;

  GIS->Unlock();

  units = CSUnitsList()->ByEPSG( 904201 ) ;

  isLine = false;
  isPolygon = false;

  GIS->Editor->EditingLinesStyle->PenWidth = 10;
  GIS->Editor->Mode = TGIS_EditorMode::AfterActivePoint;
}
//---------------------------------------------------------------------------



void __fastcall TForm1::GISEditorChangeEvent(TObject *Sender)
{
  if (GIS->Editor->CurrentShape != NULL)
  {
	TGIS_Shape *shp = (TGIS_Shape*)GIS->Editor->CurrentShape;
	if (isLine)
	{
	  edtLength->Text = units->AsLinear(shp->LengthCS(), true);
	}
	else if (isPolygon)
	{
	  edtLength->Text = units->AsLinear(shp->LengthCS(), true);
	  edtArea->Text = units->AsAreal(shp->AreaCS(), true, '%s');
	}
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::GISMouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift,
          int X, int Y)
{
  if (GIS->Mode == TGIS_ViewerMode::Edit)
  {
	return;
  }

  TGIS_Point ptg = GIS->ScreenToMap(Point(X, Y));
  if (isLine)
  {
	GIS->Editor->CreateShape(ll, ptg, TGIS_ShapeType::Arc);
	GIS->Mode = TGIS_ViewerMode::Edit;
  }
  else if (isPolygon)
  {
	GIS->Editor->CreateShape(ll, ptg, TGIS_ShapeType::Polygon);
	GIS->Mode = TGIS_ViewerMode::Edit;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnLineClick(TObject *Sender)
{
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  isPolygon = false;
  isLine = true;

  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnPolygonClick(TObject *Sender)
{
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  isPolygon = true;
  isLine = false;

  GIS->Mode = TGIS_ViewerMode::Select;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnClearClick(TObject *Sender)
{
  GIS->Editor->DeleteShape();
  GIS->Editor->EndEdit();

  edtArea->Text = "";
  edtLength->Text = "";

  GIS->Mode = TGIS_ViewerMode::Drag;
}
//---------------------------------------------------------------------------

