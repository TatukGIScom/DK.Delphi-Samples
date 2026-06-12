//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
 * JoinAndChart sample implementation — demonstrates joining GIS layer data with external database
 * tables and visualizing relationships through proportional symbol charting.
 *
 * Loads California Counties shapefile, joins it with a statistical database table via ADO,
 * then renders pie/bar charts at each feature location. Chart size and field values are controlled
 * by user-selected dropdown fields.
 */
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

/* FormCreate
   Initializes the application: sets up database connection, loads the counties shapefile,
   configures label display, and triggers the initial chart rendering. */
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_LayerSHP *ll ;

  /* Initialize combobox selections to the first item (index 0). */
  cmbSize->ItemIndex   = 0 ;
  cmbValues->ItemIndex = 0 ;
  cmbStyle->ItemIndex  = 0 ;

  /* Connect to the statistical database using ADO (Microsoft Jet OLEDB provider for .mdb files).
     The connection string specifies the Stats.mdb file in the sample data directory. */
  ADOConnection->ConnectionString = Format("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%sStats.mdb",
                        OPENARRAY(TVarRec, ( GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\Statistical\\" ))
                       ) ;
  /* Establish the connection to the database. */
  ADOConnection->Connected = TRUE ;

  /* Create and load the California Counties shapefile layer. */
  ll       = new TGIS_LayerSHP ;
  ll->Path = GisSamplesDataDirDownload() + "\\World\\Countries\\USA\\States\\California\\tl_2008_06_county.shp" ;
  ll->Name = "tl_2008_06_county";

  /* Suppress automatic .ttkgp config file loading so explicit settings are always applied. */
  ll->UseConfig                    = False ;
  /* Configure county label display: show the "name" field from the shapefile. */
  ll->Params->Labels->Field        ="name";
  /* Use solid fill pattern for label background. */
  ll->Params->Labels->Pattern      = TGIS_BrushStyle::Solid ;
  /* No outline around label boxes. */
  ll->Params->Labels->OutlineWidth = 0 ;
  /* White text on black background for high contrast. */
  ll->Params->Labels->Font->Color  = TGIS_Color::White ;
  ll->Params->Labels->Color        = TGIS_Color::Black ;
  /* Position labels at the center of each county and use flow positioning for overlapping labels. */
  ll->Params->Labels->Position     <<  TGIS_LabelPosition::MiddleCenter  <<  TGIS_LabelPosition::Flow ;

  /* Add the configured layer to the viewer. */
  GIS->Add(ll) ;
  /* Fit the viewport to show all counties. */
  GIS->FullExtent() ;

  /* Trigger the chart rendering logic by calling cmbChange with the current combobox selections. */
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
/* cmbChange
   Called whenever a chart style, size field, or value field is selected.

   Algorithm:
   1. Retrieve the current selection from each combobox.
   2. Query the database to find min/max values of the size field (for proportional scaling).
   3. Load the full statistical dataset via ADO into ll->JoinADO.
   4. Configure the layer to join on county FIPS code (JoinPrimary = shapefile field, JoinForeign = database field).
   5. Set the chart style (Pie or Bar) and rendering parameters:
      - Chart size ranges from 350 to 1000 pixels based on the size field value.
      - Create 10 zones from min to max for color mapping.
      - Define which database fields to display as chart values (e.g., "male2000:female2000").
   6. Redraw the map with the new chart configuration. */
void __fastcall TForm1::cmbChange(TObject *Sender)
{
  TGIS_LayerVector *ll ;
  String  vsize   ;
  String  vvalues ;
  String  vstyle  ;
  Double  vmin    ;
  Double  vmax    ;
  WideString sql  ;

  /* Get the first layer (the counties shapefile). */
  ll = (TGIS_LayerVector *)( GIS->Items->Items[0] ) ;
  if ( ll == NULL ) return ;

  /* Retrieve the user-selected field names from the comboboxes. */
  vsize   = cmbSize->Items->Strings[ cmbSize->ItemIndex   ] ;
  vvalues = cmbValues->Items->Strings[ cmbValues->ItemIndex ] ;
  vstyle  = cmbStyle->Items->Strings[ cmbStyle->ItemIndex  ] ;

  /* Close the query before modifying it. */
  ADOQuery->Active = false ;

  /* Execute a query to find the minimum and maximum values of the size field.
     These values are used for proportional scaling of the chart symbols. */
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

  /* Load the full statistical dataset from the ce2000t table, sorted by FIPS code for consistent joins. */
  ADOQuery->SQL->Text =  "select * FROM ce2000t  ORDER BY fips" ;
  ADOQuery->Active = true ;

  /* Attach the ADO recordset to the layer so it can join attributes from the database. */
  ll->JoinADO = ADOQuery->Recordset ;

  /* Define the join relationship:
     - JoinPrimary: the shapefile field that links to the external data (county ID).
     - JoinForeign: the database field that matches the shapefile field (FIPS code). */
  ll->JoinPrimary = "cntyidfp" ;
  ll->JoinForeign = "fips"   ;

  /* Set the chart type: "Pie" for pie charts or "Bar" for bar charts. */
  ll->Params->Chart->Style       = ParamChart( vstyle, TGIS_ChartStyle::Pie ) ;

  /* Configure proportional symbol sizing:
     - GIS_RENDER_SIZE: enable dynamic sizing based on the size field.
     - StartSize/EndSize: map the min/max values to pixel ranges (350-1000).
     - Expression: the database field controlling the chart size. */
  ll->Params->Chart->Size          = GIS_RENDER_SIZE ;
  ll->Params->Render->StartSize    = 350  ;
  ll->Params->Render->EndSize      = 1000 ;
  ll->Params->Render->Expression = vsize ;

  /* Configure the renderer to create 10 zones (color-mapped ranges) from the min to max values. */
  ll->Params->Render->Zones      = 10 ;
  ll->Params->Render->MinVal     = vmin ;
  ll->Params->Render->MaxVal     = vmax ;

  /* Define which database fields to display as chart values.
     Format: "YAxisMin:YAxisMax:field1;field2;..."
     Example: "0:0:male2000;female2000" displays two fields on the chart.
     The first "0:0" means use auto-scaling for the Y-axis range (min:max). */
  ll->Params->Render->Chart      = "0:0:" + vvalues ;

  /* Include the chart definition in the legend so the rendered fields are documented. */
  ll->Params->Chart->Legend      = ll->Params->Render->Chart ;
  /* Show the legend for the chart. */
  ll->Params->Chart->ShowLegend  = true ;

  /* Redraw the map to apply the new chart rendering configuration. */
  GIS->InvalidateWholeMap() ;

  Application->ProcessMessages() ;

}
//---------------------------------------------------------------------------




