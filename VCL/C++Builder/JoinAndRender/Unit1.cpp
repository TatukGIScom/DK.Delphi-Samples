//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to use JoinADO.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
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
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll;

  cmbSize->ItemIndex = 0 ;

  ADOConnection->ConnectionString = Format("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb",
                        OPENARRAY(TVarRec, ( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\Statistical\\" ))
                       ) ;
  ADOConnection->Connected = TRUE ;

  // create a layer, set render and label params
  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp" ;
  ll->Name = "tl_2008_06_county";

  ll->UseConfig                    = false ;
  ll->Params->Labels->Field        = "name";
  ll->Params->Labels->Pattern      = TGIS_BrushStyle::Clear ;
  ll->Params->Labels->OutlineWidth = 0 ;
  ll->Params->Labels->Font->Color  = TGIS_Color::White ;
  ll->Params->Labels->Color        = TGIS_Color::Black ;
  ll->Params->Labels->Position     << TGIS_LabelPosition::MiddleCenter <<  TGIS_LabelPosition::Flow ;
  ll->Params->Render->StartSize    = 350  ;
  ll->Params->Render->EndSize      = 1000 ;

  GIS->Add(ll) ;
  GIS->FullExtent() ;

  cmbSizeChange( Sender ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormDestroy(TObject *Sender)
{
 ADOConnection->Connected = false ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
 GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomInClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom * 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomOutClick(TObject *Sender)
{
  GIS->Zoom = GIS->Zoom / 2 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cmbSizeChange(TObject *Sender)
{
  TGIS_LayerVector *ll       ;
  String            vsize    ;
  double            vmin     ;
  double            vmax     ;
  WideString        sql      ;

  ll = ( TGIS_LayerVector *)( GIS->Items->Items[0] );
  if ( ll == NULL)
    return ;

  vsize = cmbSize->Items->Strings[ cmbSize->ItemIndex ] ;

  ADOQuery->Active = false ;

  ADOQuery->SQL->Text = Format( "SELECT min(%s) AS mini, max(%s) AS maxi FROM ce2000t",
                          OPENARRAY(TVarRec, ( vsize, vsize ) )
                        ) ;
  ADOQuery->Active = true ;


  if( ADOQuery->Bof && ADOQuery->Eof) {
     MessageBox(NULL, "No records found", "Query", MB_ICONSTOP);
  }

  vmin = ADOQuery->Fields->FieldByName( "mini" )->Value ;
  vmax = ADOQuery->Fields->FieldByName( "maxi" )->Value ;
  ADOQuery->Active = false ;

  ADOQuery->SQL->Text =  "select * FROM ce2000t  ORDER BY fips" ;
  ADOQuery->Active = true ;

  ll->JoinADO = ADOQuery->Recordset ;
  // set indexes
  ll->JoinPrimary = "cntyidfp" ;
  ll->JoinForeign = "fips"   ;

  // and render params
  ll->Params->Render->Expression = vsize ;
  ll->Params->Render->Zones      = 10 ;
  ll->Params->Render->MinVal     = vmin ;
  ll->Params->Render->MaxVal     = vmax ;
  ll->Params->Render->StartColor = TGIS_Color::FromBGR (panColorStart->Color );
  ll->Params->Render->EndColor   = TGIS_Color::FromBGR (panColorEnd->Color   )   ;
  ll->Params->Area->Color        = TGIS_Color::RenderColor ;
  ll->Params->Area->ShowLegend   = true ;

  GIS->InvalidateWholeMap() ;
  Application->ProcessMessages();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::scrTransparencyChange(TObject *Sender)
{
  TGIS_LayerVector *ll       ;

  ll = ( TGIS_LayerVector *)( GIS->Items->Items[0] );
  if ( ll == NULL) return;

  // change transparency
  ll->Transparency = scrTransparency->Position ;
  GIS->InvalidateWholeMap() ;
}

//---------------------------------------------------------------------------

void __fastcall TForm1::panColorStartClick(TObject *Sender)
{
  if ( !dlgColor->Execute() ) return;

  panColorStart->Color = dlgColor->Color;
  cmbSizeChange( this ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::panColorEndClick(TObject *Sender)
{
  if ( !dlgColor->Execute() ) return;

  panColorEnd->Color = dlgColor->Color;
  cmbSizeChange(this) ;
}
//---------------------------------------------------------------------------

