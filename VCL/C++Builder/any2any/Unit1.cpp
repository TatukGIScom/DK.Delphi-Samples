//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
  any2any Sample — Demonstrates format conversion between different vector layer types.

  Key concepts illustrated:
    - Auto-detection of source layer format (shapefile, SQLite, GeoJSON, etc.)
    - Layer creation from file path (TGIS_Utils::GisCreateLayer)
    - Shape type conversion (Point, MultiPoint, Arc/LineString, Polygon)
    - ImportLayer operation for converting between formats
    - Command-line driven utility for batch conversion
    - Error handling for missing or invalid input files
    - Layer opening and metadata access (layer.Open())
    - Extent information (layer.Extent)

  User workflow:
    1. Run from command line: any2any source_file dest_file shape_type
    2. Specify source file (any supported GIS format)
    3. Specify destination file path
    4. Choose target shape type (A=Arc, G=Polygon, P=Point, M=Multipoint)
    5. Program converts shapes to target type and saves

  Shape type conversion:
    - Arc (A): converts all geometries to LineString type
    - Polygon (G): converts to polygon/area type
    - Point (P): converts to single point type
    - Multipoint (M): converts to multi-point type
    - Point clouds can be generalized, lines merged, polygons converted

  Key API:
    - TGIS_Utils::GisCreateLayer: auto-detect format from file extension
    - TGIS_LayerVector: base vector layer interface
    - ImportLayer: copy features from source to destination with shape type conversion
    - TGIS_ShapeType enum: specifies target geometry type
    - Layer.Extent: bounds of all features

  Error handling:
    - File not found: reports error with filename
    - Missing arguments: displays usage information
    - Invalid shape type: defaults to Unknown
*/

//  How to create format converter
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#include <iostream>
#include <utilcls.h>
#undef EOF
//#include "GisLicense.hpp"
#include "GisLayerVector.hpp"
#include "GisRegistredLayers.hpp"
#include "GisAllLayers.hpp"
#include "VCL.GisViewerBMP.hpp"

#pragma hdrstop
using namespace std;

//---------------------------------------------------------------------------

/*
  main
  Console-based vector layer format converter.

  Converts vector layers from one format to another with optional shape type transformation.
  The source format is auto-detected from the file extension; destination format is also
  inferred from the destination filename extension.

  Algorithm:
    1. Initialize COM runtime (CoInitialize)
    2. Validate command-line arguments (3 required)
    3. Create source layer: GisCreateLayer auto-detects format from file extension
    4. Open source layer and access its extent
    5. Parse target shape type from command-line argument (A/G/P/M)
    6. Create destination layer: auto-detect format from destination file path
    7. Copy all features: ImportLayer converts to target shape type
    8. Clean up and close both layers
    9. Report success or error to console

  Parameters:
    argc: argument count
    argv: argument vector

  Arguments expected:
    1. source_file: input file (auto-detects .shp, .db, .sqlite, .geojson, etc.)
    2. dest_file: output file (format inferred from extension)
    3. shape_type: single character A/G/P/M for target geometry type

  Returns:
    0 on success, 1 on error (missing arguments, file not found, import failure)
*/
#pragma argsused
int main(int argc, char* argv[])
{
  TGIS_LayerVector  *lm   ;
  TGIS_LayerVector  *ll   ;
  TGIS_ShapeType  shape_type  ;

  CoInitialize( NULL );
  cout << "TatukGIS Samples: ANY->ANY converter ( Vector layers only )" << endl ;
  if ( ParamCount() != 3 ) {
	cout << "Usage: ANY2SQL source_file destination shape_type" << endl ;
    cout << "Where shape_type:"<< endl ;
    cout << " A - Arc"         << endl ;
    cout << " G - polyGon"     << endl ;
    cout << " P - Point"       << endl ;
    cout << " M - Multipoint"  << endl ;
    return 1 ;
  }

  try {
  	ll = NULL ;
  	lm = NULL ;
    try {
      // Step 1: Auto-detect source layer format from file extension
      lm  = ( TGIS_LayerVector *)TGIS_Utils::GisCreateLayer( "", ParamStr(1) );
      if ( lm == NULL) {
        cout << "### ERROR: File " << ParamStr(1).c_str() << " not found" << endl;
        return 1;
      }
	  // Open the source layer to access its metadata and features
	  lm->Open() ;

      // Step 2: Parse shape type from command-line argument (first character of 3rd arg)
      // Valid values: A=Arc (LineString), G=Polygon, P=Point, M=MultiPoint
      switch ( ParamStr(3)[1] ) {
        case 'A' : {
                     // Convert to Arc/LineString type (curves and lines)
                     shape_type = TGIS_ShapeType::Arc        ;
                     break ;
                   }
        case 'G' : {
                     // Convert to Polygon type (area/ring geometries)
                     shape_type = TGIS_ShapeType::Polygon    ;
                     break ;
                   }
        case 'P' : {
                     // Convert to Point type (single point geometries)
                     shape_type = TGIS_ShapeType::Point      ;
                     break ;
                   }
        case 'M' : {
                     // Convert to MultiPoint type (multiple discrete points)
                     shape_type = TGIS_ShapeType::MultiPoint ;
                     break ;
                   }
        default  : {
                     // Invalid shape type defaults to Unknown (no conversion applied)
                     shape_type = TGIS_ShapeType::Unknown        ;
                     break ;
                   }
      }

      // Step 3: Auto-detect destination layer format from file extension
      ll  = ( TGIS_LayerVector *)TGIS_Utils::GisCreateLayer( "", ParamStr(2) );
      if ( ll == NULL) {
        cout << "### ERROR: File " << ParamStr(2).c_str() << " not found" << endl;
        return 1;
      }
      // Step 4: Import all features from source to destination with shape type conversion
      // Parameters:
      //   lm: source layer to import from
      //   lm->Extent: spatial bounds (all features in this extent)
      //   shape_type: target geometry type for conversion
      //   "": empty string for attribute filter (import all attributes)
      //   False: do not import selected features only
      ll->ImportLayer( lm,
                       lm->Extent,
                       shape_type,
                       "",
                       False
                      ) ;
    }
    __finally {
      // Step 5: Clean up and close both layers
      delete ll ;
      delete lm ;
   }
  }
  catch( const Exception &E ) {
    cout << E.Message.c_str() << endl ;
    return 1;
  }

  return 0;
}
//---------------------------------------------------------------------------
 
