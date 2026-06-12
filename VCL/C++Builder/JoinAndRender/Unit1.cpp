//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * JoinAndRender sample implementation — demonstrates joining GIS layer data with external databases
 * and applying data-driven styling (choropleth maps) based on joined attribute values.
 *
 * Loads California Counties shapefile, joins it with a statistical database, then colors and renders
 * each county based on a user-selected data field. Color ranges from start (low values) to end (high values).
 */
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

/* FormCreate
   Initializes the application: sets up database connection, loads the counties shapefile,
   configures label display and rendering parameters, then triggers the initial rendering. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll;

  /* Initialize the combobox to the first item. */
  cmbSize->ItemIndex = 0 ;

  /* Connect to the statistical database using ADO (Microsoft Jet OLEDB provider for .mdb files). */
  ADOConnection->ConnectionString = Format("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb",
                        OPENARRAY(TVarRec, ( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\Statistical\\" ))
                       ) ;
  /* Establish the connection to the database. */
  ADOConnection->Connected = TRUE ;

  /* Create and load the California Counties shapefile layer. */
  ll = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp" ;
  ll->Name = "tl_2008_06_county";

  /* Suppress automatic .ttkgp config file loading so explicit settings are always applied. */
  ll->UseConfig                    = false ;
  /* Configure county label display: show the "name" field from the shapefile. */
  ll->Params->Labels->Field        = "name";
  /* Use clear/transparent pattern for label background. */
  ll->Params->Labels->Pattern      = TGIS_BrushStyle::Clear ;
  /* No outline around label boxes. */
  ll->Params->Labels->OutlineWidth = 0 ;
  /* White text on black background for high contrast. */
  ll->Params->Labels->Font->Color  = TGIS_Color::White ;
  ll->Params->Labels->Color        = TGIS_Color::Black ;
  /* Position labels at county centers and use flow positioning for overlapping labels. */
  ll->Params->Labels->Position     << TGIS_LabelPosition::MiddleCenter <<  TGIS_LabelPosition::Flow ;
  /* Configure rendering size range (used for proportional symbols if needed). */
  ll->Params->Render->StartSize    = 350  ;
  ll->Params->Render->EndSize      = 1000 ;

  /* Add the configured layer to the viewer. */
  GIS->Add(ll) ;
  /* Fit the viewport to show all counties. */
  GIS->FullExtent() ;

  /* Trigger the data-driven rendering by calling cmbSizeChange with the current selection. */
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

/* cmbSizeChange
   Called whenever a data field is selected from the combobox.

   Algorithm:
   1. Retrieve the selected field name from the combobox.
   2. Query the database to find min/max values of that field (for color zone mapping).
   3. Load the full statistical dataset into the layer via JoinADO.
   4. Configure the join on county FIPS code.
   5. Set up choropleth rendering parameters:
      - Create 10 color zones from min to max field value.
      - Map zone colors from StartColor (low values) to EndColor (high values).
      - Enable legend display to show the zone mapping. */
void __fastcall TForm1::cmbSizeChange(TObject *Sender)
{
  TGIS_LayerVector *ll       ;
  String            vsize    ;
  double            vmin     ;
  double            vmax     ;
  WideString        sql      ;

  /* Get the first layer (the counties shapefile). */
  ll = ( TGIS_LayerVector *)( GIS->Items->Items[0] );
  if ( ll == NULL)
    return ;

  /* Retrieve the selected field name from the combobox. */
  vsize = cmbSize->Items->Strings[ cmbSize->ItemIndex ] ;

  /* Close the query before modifying it. */
  ADOQuery->Active = false ;

  /* Query the database to find the minimum and maximum values of the selected field.
     These values will be used to define the color zone range. */
  ADOQuery->SQL->Text = Format( "SELECT min(%s) AS mini, max(%s) AS maxi FROM ce2000t",
                          OPENARRAY(TVarRec, ( vsize, vsize ) )
                        ) ;
  ADOQuery->Active = true ;

  /* Check if the query returned results. */
  if( ADOQuery->Bof && ADOQuery->Eof) {
     MessageBox(NULL, "No records found", "Query", MB_ICONSTOP);
  }

  /* Extract the min and max values from the query result. */
  vmin = ADOQuery->Fields->FieldByName( "mini" )->Value ;
  vmax = ADOQuery->Fields->FieldByName( "maxi" )->Value ;
  ADOQuery->Active = false ;

  /* Load the full statistical dataset from the ce2000t table, sorted by FIPS for consistent joins. */
  ADOQuery->SQL->Text =  "select * FROM ce2000t  ORDER BY fips" ;
  ADOQuery->Active = true ;

  /* Attach the ADO recordset to the layer so it can join attributes from the database. */
  ll->JoinADO = ADOQuery->Recordset ;
  /* Define the join relationship:
     - JoinPrimary: the shapefile field (county ID).
     - JoinForeign: the database field (FIPS code). */
  ll->JoinPrimary = "cntyidfp" ;
  ll->JoinForeign = "fips"   ;

  /* Configure choropleth (data-driven color) rendering:
     - Expression: the database field controlling the color mapping.
     - Zones: number of color grades from min to max value (10 = 10 discrete colors).
     - MinVal/MaxVal: the range of data values to map.
     - StartColor/EndColor: colors for the low and high ends of the range.
     - RenderColor: tells the renderer to use the color zones instead of default colors. */
  ll->Params->Render->Expression = vsize ;
  ll->Params->Render->Zones      = 10 ;
  ll->Params->Render->MinVal     = vmin ;
  ll->Params->Render->MaxVal     = vmax ;
  /* Convert VCL color (BGR format) to GIS color format. */
  ll->Params->Render->StartColor = TGIS_Color::FromBGR (panColorStart->Color );
  ll->Params->Render->EndColor   = TGIS_Color::FromBGR (panColorEnd->Color   )   ;
  /* Use the RenderColor flag to enable data-driven coloring. */
  ll->Params->Area->Color        = TGIS_Color::RenderColor ;
  /* Display the color legend showing zone ranges and their colors. */
  ll->Params->Area->ShowLegend   = true ;

  /* Redraw the map to apply the new choropleth rendering. */
  GIS->InvalidateWholeMap() ;
  /* Process any pending UI events to keep the interface responsive. */
  Application->ProcessMessages();
}
//---------------------------------------------------------------------------

/* scrTransparencyChange
   Adjusts the layer transparency via a trackbar slider (0-100, where 0 = opaque, 100 = fully transparent).
   This allows viewing underlying map layers through the counties. */
void __fastcall TForm1::scrTransparencyChange(TObject *Sender)
{
  TGIS_LayerVector *ll       ;

  /* Get the first layer (the counties shapefile). */
  ll = ( TGIS_LayerVector *)( GIS->Items->Items[0] );
  if ( ll == NULL) return;

  /* Set the layer transparency from the slider position (0-100).
     0 = fully opaque (no transparency), 100 = fully transparent (invisible). */
  ll->Transparency = scrTransparency->Position ;
  /* Redraw the map to apply the new transparency level. */
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

