//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  SQLLayer Sample - C++Builder VCL
//  ==================================
//  Demonstrates how to open and display an SQL layer using TatukGIS DK.
//
//  An SQL layer (*.ttkls file) is a virtual layer definition that connects to
//  a relational database (e.g. PostgreSQL/PostGIS, SQL Server, SQLite, Oracle
//  Spatial) and executes a SQL query to expose the result as a mappable layer.
//  The .ttkls file stores the connection string, the SQL statement, and field
//  mappings.  It can be opened just like any other layer or project format.
//
//  Key concepts shown:
//    - Opening a .ttkls project file with TGIS_ViewerWnd->Open
//    - Fitting the view to the full data extent with FullExtent
//    - Switching the viewer between Zoom and Drag interaction modes
//
//  To adapt this sample to your own database:
//    Edit the gistest.ttkls file to supply your connection string and SQL query.
//    The .ttkls file can also be opened in the TatukGIS Editor for visual
//    configuration.
//
//  Check project\options\directories in case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"  // Uncomment and configure if using a licensed build
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

/// <summary>
///   Called when the form is first created.
///   Opens the SQL layer project file and fits the view to its full extent.
/// </summary>
/// <remarks>
///   GisSamplesDataDirDownload() returns the path to the TatukGIS sample data
///   directory.  The gistest.ttkls file describes the database connection and
///   SQL query; edit it before running to point at your own database.
///   The second argument to Open (true) triggers an immediate refresh.
/// </remarks>
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  // Open the SQL layer definition file (.ttkls).
  // TGIS_ViewerWnd::Open accepts any supported layer or project format.
  // For .ttkls files it connects to the configured database, executes the
  // SQL query, and creates a virtual vector layer from the result set.
  GIS->Open( TGIS_Utils::GisSamplesDataDirDownload() +  "\\Samples\\SQLLayers\\gistest.ttkls" , true ) ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Zooms the map out to the full data extent, making all features visible.
/// </summary>
void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Switches the viewer to Zoom mode.
///   In this mode, left-click-drag draws a rubber-band rectangle to zoom in;
///   right-click zooms out by a fixed step.
/// </summary>
void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  // TGIS_ViewerMode::Zoom — rubber-band zoom interaction
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

/// <summary>
///   Switches the viewer to Drag (pan) mode.
///   In this mode, click-drag scrolls the map without changing the zoom level.
/// </summary>
void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  // TGIS_ViewerMode::Drag — pan/scroll interaction
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------
