//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  any2any Sample — Console-based vector layer format converter demonstrating
  auto-detection of source/destination formats and optional shape type conversion.

  Key concepts illustrated:
    - Auto-detection of layer format from file extension
    - TGIS_Utils.GisCreateLayer factory for format resolution
    - Shape type conversion (Point, MultiPoint, Arc/LineString, Polygon)
    - TGIS_LayerVector.ImportLayer for feature migration
    - Command-line driven console utility
    - Error handling for missing files and invalid arguments
    - Layer extent access and spatial extent operations
    - File format support: shapefile, SQLite, GeoJSON, WFS, and others

  User workflow:
    1. Run: any2any source_file dest_file shape_type
    2. Source file: input in any supported GIS format
    3. Destination file: output filename (format inferred from extension)
    4. Shape type: single character A/G/P/M for target geometry
    5. Program converts shapes and saves to destination
    6. Original file preserved, new file created with target format/type

  Shape type conversion:
    - Arc (A): convert all geometries to LineString/Arc type
    - Polygon (G): convert to polygon/area type with boundaries
    - Point (P): convert to single point geometries
    - Multipoint (M): convert to multi-point type
    - Geometry simplification/generalization applied as needed

  Key API:
    - TGIS_Utils.GisCreateLayer: auto-detect and create layer from file
    - TGIS_LayerVector.Open: open layer and load metadata
    - TGIS_LayerVector.ImportLayer: copy features with optional shape conversion
    - TGIS_ShapeType enum: target geometry type specification
    - TGIS_LayerVector.Extent: spatial bounds of all features

  Error handling:
    - File not found: displays error with filename
    - Invalid arguments: shows usage information
    - Missing destination: creates new file
    - Unknown shape type: defaults to Unknown (no conversion)
}

{$APPTYPE CONSOLE}
{$APPTYPE CONSOLE}
program any2any;

uses
  System.SysUtils,
  System.Classes,

  Winapi.Activex,

  Vcl.Graphics,

  //GisLicense,
  GisAllLayers,
  GisTypes,
  GisFunctions,
  GisViewer,
  GisLayerVector,
  GisUtils,
  GisRegistredLayers,
  GisTypesUI ;

var
  lm         : TGIS_LayerVector ;
  ll         : TGIS_LayerVector ;
  shape_type : TGIS_ShapeType ;

begin
  { Initialize COM runtime for Windows compatibility }
  CoInitialize( nil );

  { Display welcome message }
  writeln( 'TatukGIS Samples - ANY->ANY converter ( Vector files only )' ) ;

  { Step 1: Validate command-line arguments (exactly 3 required) }
  if ParamCount <> 3 then begin
    writeln( 'Usage: ANY2ANY source_file destination_file shape_type' ) ;
    writeln( 'Where shape_type:' ) ;
    writeln( ' A - Arc'         ) ;
    writeln( ' G - polyGon'     ) ;
    writeln( ' P - Point'       ) ;
    writeln( ' M - Multipoint'  ) ;
    exit ;
  end ;

  try
    lm := nil ;
    ll := nil ;
    try
      { Step 2: Auto-detect source layer format from file extension }
      lm  := TGIS_LayerVector( TGIS_Utils.GisCreateLayer( '', ParamStr(1) ) ) ;

      { Validate source file exists }
      if not Assigned( lm ) then begin
        writeln( Format( '### ERROR: File %s not found', [ParamStr(1)] ) ) ;
        exit ;
      end ;

      { Step 3: Open source layer to access its metadata and features }
      lm.Open ;

      { Step 4: Parse shape type from command-line argument (first character of 3rd arg)
                Valid values: A=Arc (LineString), G=Polygon, P=Point, M=MultiPoint }
      case ParamStr(3)[1] of
        'A' : shape_type := TGIS_ShapeType.Arc        ;  { Convert to Arc/LineString }
        'G' : shape_type := TGIS_ShapeType.Polygon    ;  { Convert to Polygon/Area }
        'P' : shape_type := TGIS_ShapeType.Point      ;  { Convert to Point }
        'M' : shape_type := TGIS_ShapeType.MultiPoint ;  { Convert to MultiPoint }
      else
        shape_type := TGIS_ShapeType.Unknown ;           { Invalid: no conversion }
      end ;

      { Step 5: Auto-detect destination layer format from destination filename }
      ll := TGIS_LayerVector( TGIS_Utils.GisCreateLayer( '', ParamStr(2) ) ) ;

      { Validate destination file path is accessible }
      if not Assigned( ll ) then begin
        writeln( Format( '### ERROR: File %s not found', [ParamStr(2)] ) ) ;
        exit ;
      end ;

      { Step 6: Import all features from source to destination with shape type conversion
                Parameters:
                  lm: source layer to import from
                  lm.Extent: spatial bounds (all features in this extent)
                  shape_type: target geometry type for conversion
                  '': empty string for attribute filter (import all attributes)
                  False: import all features, not just selected }
      ll.ImportLayer( lm,
                      lm.Extent,
                      shape_type,
                      '',
                      False
                    ) ;

    finally
      { Step 7: Clean up and close both layers }
      ll.Free ;
      lm.Free ;
    end ;
  except
    on E : Exception do
      { Display any exception message to console }
      writeln( E.Message ) ;
  end ;
end.
