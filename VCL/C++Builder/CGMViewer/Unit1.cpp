/*
 * CGMViewer sample — demonstrates rendering CGM (Computer Graphics Metafile) symbol files
 * as point markers using SymbolList.
 *
 * A FileListBox shows *.cgm files from the Symbols directory.  Selecting one renders it
 * centred on a crosshair layer sized to fit two-thirds of the smaller viewer dimension.
 * Button1 rotates the marker by 90° each click.
 */
//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
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

/* Loads the selected CGM file into SymbolList, sizes it to fit two-thirds of the smaller
   viewer dimension (aspect-ratio preserved), and invalidates the map. */
void TForm1::drawSymbol()
{
  int w,h ;

  shp->Params->Marker->Symbol = SymbolList()->Prepare( FileList->FileName ) ;
  if ( shp->Params->Marker->Symbol ) {
    shp->Params->Marker->Size = - Min( GIS->Width, GIS->Height ) * 2 / 3 ;

    // prepare to obtain computed width/height
      shp->Params->Marker->Symbol->Prepare( *GIS, -5, TGIS_Color::Black, TGIS_Color::Black, 0.0, 0, TGIS_LabelPosition::MiddleCenter, true ) ;
      w = shp->Params->Marker->Symbol->Width  ;
      h = shp->Params->Marker->Symbol->Height ;
      shp->Params->Marker->Symbol->Unprepare() ;

    if (h < w) shp->Params->Marker->Size =  shp->Params->Marker->Size * h / w;
  }
  else {
    shp->Params->Marker->Size = 0 ;
  } ;

  shp->Params->Marker->Color = TGIS_Color::RenderColor ;
  shp->Params->Marker->OutlineColor = TGIS_Color::RenderColor ;
  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

/* Creates the crosshair vector layer (horizontal line, vertical line, centre point) on startup
   and navigates the FileListBox to the Symbols directory. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerVector  *ll  ;

  DirectoryListBox1->Directory = GisSamplesDataDirDownload() + "\\Symbols" ;

  ll = new TGIS_LayerVector ;
  GIS->Add( ll ) ;
  ll->Extent = GisExtent( -90, -90, 90, 90 ) ;
  GIS->FullExtent() ;

  shp = ll->CreateShape( TGIS_ShapeType::Arc ) ;
  shp->Params->Line->Width = 1 ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( -90, 0 ) );
  shp->AddPoint( GisPoint(  90, 0 ) );

  shp = ll->CreateShape( TGIS_ShapeType::Arc ) ;
  shp->Params->Line->Width = 1 ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( 0, -90 ) );
  shp->AddPoint( GisPoint( 0,  90 ) );

  shp = ll->CreateShape( TGIS_ShapeType::Point ) ;
  shp->AddPart() ;
  shp->AddPoint( GisPoint( 0, 0 ) );
}
//---------------------------------------------------------------------------

/* Redraws the symbol at the new size whenever the form is resized. */
void __fastcall TForm1::FormResize(TObject *Sender)
{
  drawSymbol() ;
}
//---------------------------------------------------------------------------

/* Synchronises the FileListBox to the directory selected in DirectoryListBox1. */
void __fastcall TForm1::DirectoryListBox1Change(TObject *Sender)
{
  FileList->Directory = DirectoryListBox1->Directory ;
}
//---------------------------------------------------------------------------

/* Redraws the symbol when a different CGM file is selected in the file list. */
void __fastcall TForm1::FileListClick(TObject *Sender)
{
  StatusBar1->SimpleText = FileList->FileName ;
  drawSymbol() ;
}
//---------------------------------------------------------------------------

/* Rotates the displayed symbol by 90° (π/2 radians) each click. */
void __fastcall TForm1::Button1Click(TObject *Sender)
{
  // rotate symbol
  shp->Params->Marker->SymbolRotate = shp->Params->Marker->SymbolRotate+3.14/2;
  shp->Invalidate();
}
//---------------------------------------------------------------------------


