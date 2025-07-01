//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to provied a join to external database and how to provide charts. 
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include <sysopen.h>
#include "Data.Win.ADODB.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)

#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  cmbSize->ItemIndex   = 0 ;
  cmbValues->ItemIndex = 0 ;
  cmbStyle->ItemIndex  = 0 ;

  ADOConnection->ConnectionString = Format("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb",
                        OPENARRAY(TVarRec, ( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\Statistical\\" ))
                       ) ;
  ADOConnection->Connected = TRUE ;

  ll       = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp" ;
  ll->Name = "tl_2008_06_county";

  ll->UseConfig                    = False ;
  ll->Params->Labels->Field        ="name";
  ll->Params->Labels->Pattern      = TGIS_BrushStyle::Solid ;
  ll->Params->Labels->OutlineWidth = 0 ;
  ll->Params->Labels->Font->Color  = TGIS_Color::White ;
  ll->Params->Labels->Color        = TGIS_Color::Black ;
  ll->Params->Labels->Position     <<  TGIS_LabelPosition::MiddleCenter  <<  TGIS_LabelPosition::Flow ;
  
  GIS->Add(ll) ;
  GIS->FullExtent() ;

  cmbChange(Sender) ;
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
void __fastcall TForm1::cmbChange(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  String  vsize   ;
  String  vvalues ;
  String  vstyle  ;
  Double  vmin    ;
  Double  vmax    ;
  WideString sql  ;

  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
  if ( ll == NULL ) return ;

  // get params
  vsize   = cmbSize->Items->Strings[ cmbSize->ItemIndex   ] ;
  vvalues = cmbValues->Items->Strings[ cmbValues->ItemIndex ] ;
  vstyle  = cmbStyle->Items->Strings[ cmbStyle->ItemIndex  ] ;

  ADOQuery->Active = false ;

  // find min, max values for shapes
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

  // let's load data to recordset
  ADOQuery->SQL->Text =  "select * FROM ce2000t  ORDER BY fips" ;
  ADOQuery->Active = true ;

  ll->JoinADO = ADOQuery->Recordset ;

  // set primary and foreign keys
  ll->JoinPrimary = "cntyidfp" ;
  ll->JoinForeign = "fips"   ;

  // Set the chart style: "Pie" or "Bar"
  ll->Params->Chart->Style       = ParamChart( vstyle, TGIS_ChartStyle::Pie ) ;
  
  // The chart size will be set by Render in the range of 350 to 1000
  // depending on the value of the "vsize" field
  ll->Params->Chart->Size          = GIS_RENDER_SIZE ;
  ll->Params->Render->StartSize    = 350  ;
  ll->Params->Render->EndSize      = 1000 ;
  ll->Params->Render->Expression = vsize ;
  
  // The Renderer will create 10 zones to group field values,
  // starting from "vmin" and edning with "vmax"
  ll->Params->Render->Zones      = 10 ;
  ll->Params->Render->MinVal     = vmin ;
  ll->Params->Render->MaxVal     = vmax ;

  // For 'Bar' chart you can replace '0:0' by 'min:max' to set custom Y-axis limits.
  // 'vvalues' contains list of values displayed on the chart.
  // In this sample field names are used, e.g. 'male2000:female2000'.
  // Values need to be divided by a colon ':'.
  ll->Params->Render->Chart      = "0:0:" + vvalues ;

  // If necessary, the chart can also be included in the legend
  ll->Params->Chart->Legend      = ll->Params->Render->Chart ;
  ll->Params->Chart->ShowLegend  = true ;
  
  GIS->InvalidateWholeMap() ;

  Application->ProcessMessages() ;

}
//---------------------------------------------------------------------------




