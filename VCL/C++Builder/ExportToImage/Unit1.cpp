//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Export to image window
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

double __fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}

void __fastcall TForm1::GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)

{
  AnsiString str ;

  if ( _end <= 0 )
    Caption = "Export to image" ;
  else
    Caption = str.sprintf( "Export to image %d%%", trunc( _pos / _end * 100.0 )  );

  Application->ProcessMessages() ;
}

//---------------------------------------------------------------------------
TGIS_PixelFormat __fastcall TForm1::getExp_pixelformat()
{
  return current_obj->PixelFormat;
};

//---------------------------------------------------------------------------
int __fastcall TForm1::getExp_subformat()
{
  return int(current_obj->Subformat);
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  rbImage->Checked = True ;
  rbImageClick( this ) ;
}

//---------------------------------------------------------------------------

void __fastcall TForm1::actSaveExecute(TObject *Sender)
{
  TGIS_LayerPixelSubFormat c;

  Application->ProcessMessages() ;
  if ( cbType->ItemIndex >= 0 )
  {
	c = ( ( T_capability *)(cbType->Items->Objects[cbType->ItemIndex]) )->C ;
  }
  else
  {
	c = lpx->DefaultSubFormat ;
  }

  if (rbExtentMap->Checked)
  {
	FExtent = GIS->Extent;
  }
  else
  {
	FExtent = GIS->VisibleExtent;
  }

  if (rbQbest->Checked)
  {
	ValuesInit();
  }
  else if (rbQdoc->Checked)
  {
	ppi = DEFAULT_PPI_WEB;
	pixWidth = DEFAULT_WIDTHPIX_WEB;

	if (!((FExtent.XMax - FExtent.XMin) == 0))
	{
		pixHeight = (FExtent.YMax - FExtent.YMin) /
					(FExtent.XMax - FExtent.XMin) * pixWidth;
	}
	else
	{
		pixHeight = 2;
		pixHeight = 2;
	}
	ValuesWH();
  }
  else if (rbQweb->Checked)
  {
	ppi = DEFAULT_PPI_DOC;
	expWidth = DEFAULT_WIDTH_DOC_INCH;
	if ((FExtent.XMax - FExtent.XMin) == 0)
	{
		expHeight = (FExtent.YMax - FExtent.YMin) / (FExtent.XMax - FExtent.XMin) * expWidth;
	}
	else
	{
		expWidth  = 2;
		expHeight = 2;
	}

	ValuesWHpix();
  }

  lpx->ImportLayer( lstp, lstp->Extent, lstp->CS,
				   round( pixWidth  ),
				   round( pixHeight ),
                   c
				  ) ;
  ShowMessage("File exported!");
}

//---------------------------------------------------------------------------
void __fastcall TForm1::btnSelectFileClick(TObject *Sender)
{
  TGIS_LayerPixelSubFormatList *clst ;
  TGIS_LayerPixelSubFormat     c     ;
  TObject *obj ;
  T_capability *cap ;

  if (rbImage->Checked)
  {
	if ( !dlgSaveImage->Execute() )
	{
	  return ;
	}

    edtFile->Text = dlgSaveImage->FileName;
    edtFile->Hint = dlgSaveImage->FileName;
  }
  else
  {
	if ( !dlgSaveGrid->Execute() )
	{
	  return ;
	}

	edtFile->Text = dlgSaveGrid->FileName;
    edtFile->Hint = dlgSaveGrid->FileName;
  }
  cbType->Clear();

  try{
    lstp = ( TGIS_LayerPixel *) (GIS->Items->Items[0]) ;
	if (rbImage->Checked)
	{
      lpx = ( TGIS_LayerPixel * )(GisCreateLayer( ExtractFileName( dlgSaveImage->FileName ),
                            dlgSaveImage->FileName ) ) ;
    }
	else
	{
        lpx = ( TGIS_LayerPixel * )( GisCreateLayer( ExtractFileName( dlgSaveGrid->FileName ),
                                dlgSaveGrid->FileName ) ) ;
    }
    clst = lpx->Capabilities ;
	for( int i=0; i<clst->Count; i++)
	{
	  c = clst->Items[i];
	  cap = new T_capability(c);
	  cbType->AddItem( c.ToString(),
					   (TObject *)(cap)  ) ;
    }

	cbType->ItemIndex = 0 ;

	btnSave->Enabled = true;
	rbQbest->Enabled = true;
	rbQdoc->Enabled = true;
	rbQweb->Enabled = true;
	rbExtentMap->Enabled = true;
	rbExtentVisible->Enabled = true;
	cbType->Enabled = true;

	rbExtentMap->Checked = true ;
	rbQbest->Checked = true ;
  }
  catch ( const Exception& e ) {
	ShowMessage( e.Message ) ;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
  cbType->Clear();
  FreeObjectNotNil( lst ) ;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::ValuesInit() {

  int i,j             ;
  TGIS_Layer *la      ;
  TGIS_LayerPixel *lp ;
  double density      ;
  double density0     ;
  double density1     ;
  int widthpix        ;
  double ext_delta    ;
  double ext_width    ;

  density0 = 0 ;
  density  = density0 ;
  ppi = DEFAULT_PPI;
  j = 0 ;
  for ( i = GIS->Items->Count - 1 ; i>=0 ; i-- ) {
      la = ( TGIS_Layer * )( GIS->Items->Items[ i ] ) ;

      if ( la->InheritsFrom( __classid(TGIS_LayerPixel) ) ) {
         ext_width = la->Extent.XMax - la->Extent.XMin ;

         density1 = ( ( TGIS_LayerPixel *)( la ))->BitWidth / ext_width ;
         if ( density1 > density0 ){
            density = density1 ;
            j = i ;
         }
         density0 = density1 ;
      }

  }

  if ( density == 0 ) {
    widthpix = 4200 ;
  }
  else {
         la = ( TGIS_Layer *) ( GIS->Items->Items[ j ] ) ;
         ext_width = la->Extent.XMax - la->Extent.XMin ;
		 ext_delta = ( FExtent.XMax - FExtent.XMin ) / ext_width ;

         lp = ( TGIS_LayerPixel *)( GIS->Items->Items[ j ] );
         widthpix =  round ( ext_delta *
                              lp->BitWidth ) ;
  }

  pixWidth = widthpix ;
  if ( ( FExtent.XMax - FExtent.XMin ) != 0 ){
	pixHeight = ( FExtent.YMax - FExtent.YMin ) /
				( FExtent.XMax - FExtent.XMin ) * pixWidth;
  }
  else{
	pixWidth  = 2 ;
	pixHeight = 2 ;
  }
}

void __fastcall TForm1::ValuesWH()
{
  expWidth = pixWidth / ppi;

  if (!((FExtent.XMax - FExtent.XMin) == 0))
  {
	expHeight = (FExtent.YMax - FExtent.YMin)/
				(FExtent.XMax - FExtent.XMin) * expWidth;
  }
  else
  {
	expWidth  = 2;
	expHeight = 2;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::ValuesWHpix()
{
  pixWidth = expWidth * ppi;

  if (!((FExtent.XMax - FExtent.XMin) == 0))
  {
	  pixHeight = (FExtent.YMax - FExtent.YMin)/
				  (FExtent.XMax - FExtent.XMin) * pixWidth;
  }
  else
  {
	  pixWidth  = 2;
	  pixHeight = 2;
  }
}

//---------------------------------------------------------------------------
void __fastcall TForm1::rbGridClick(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\hdr.adf");
  edtFile->Text = "";
  cbType->Clear();
  btnSave->Enabled = false;
  rbQbest->Enabled = false;
  rbQdoc->Enabled = false;
  rbQweb->Enabled = false;
  rbExtentMap->Enabled = false;
  rbExtentVisible->Enabled = false;
  cbType->Enabled = false;
}

//---------------------------------------------------------------------------
void __fastcall TForm1::rbImageClick(TObject *Sender)
{
  GIS->Open( GisSamplesDataDirDownload() + "\\World\\VisibleEarth\\world_8km.jpg" );
  edtFile->Text = "";
  cbType->Clear();
  btnSave->Enabled = false;
  rbQbest->Enabled = false;
  rbQdoc->Enabled = false;
  rbQweb->Enabled = false;
  rbExtentMap->Enabled = false;
  rbExtentVisible->Enabled = false;
  cbType->Enabled = false;
}

