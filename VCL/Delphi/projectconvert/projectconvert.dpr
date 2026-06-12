//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  projectconvert Utility - Console-based converter for upgrading legacy
  TatukGIS TTKGP projects to modern TTKPROJECT format.

  Key concepts illustrated:
    - Legacy format migration: TTKGP → TTKPROJECT conversion
    - Format upgrade: transition from old to new project structure
    - Backward compatibility: read legacy TTKGP format
    - Forward compatibility: save in current TTKPROJECT format
    - Non-destructive: original TTKGP file preserved
    - One-command conversion: simple batch upgrade workflow

  Technical approach:
    - Load legacy TTKGP project file
    - TatukGIS automatically parses legacy format
    - SaveProjectAs: save loaded project in TTKPROJECT format
    - New project uses same layers and configuration
    - Original TTKGP file unchanged

  Usage:
    projectconvert <path_to_ttkgp_file>

  Parameters:
    - path_to_ttkgp_file: full path to legacy .ttkgp project file
    - Output: <same_name>.ttkproject in same directory

  Workflow:
    1. Prepare legacy TTKGP project files
    2. Run converter: projectconvert project.ttkgp
    3. Converter creates project.ttkproject
    4. Original project.ttkgp untouched
    5. New project.ttkproject ready for use

  Format Differences:

  TTKGP (Legacy):
    - Binary proprietary format
    - Limited extensibility
    - Monolithic project structure
    - Older coordinate system definitions
    - Legacy rendering rules format

  TTKPROJECT (Modern):
    - XML-based (human-readable, extensible)
    - Better flexibility and customization
    - Modular layer definitions
    - Modern EPSG coordinate system support
    - Current rendering engine compatibility

  Benefits of Upgrade:
    - XML format: projects visible with text editor
    - Better compatibility: works with current version
    - Enhanced features: new rendering capabilities
    - Future-proof: format supported indefinitely
    - Easier maintenance: XML easier to edit/troubleshoot
    - Layer modularity: external layer references (.ttkls)

  One-Time Migration:
    - Convert all TTKGP projects to TTKPROJECT
    - Batch convert: run converter on all legacy files
    - Deprecation: TTKGP support may be removed in future versions
    - Recommended: upgrade before major version jumps
}
program projectconvert;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,

   //GisLicense,
  GisAllLayers,

  Vcl.GisViewerBMP;

var
  vwr   : TGIS_ViewerBmp  ;
  path  : String          ;
begin
  if ParamCount <> 1 then
  begin
    Writeln('TatukGIS Samples - TTKGP -> TTKPROJECT converter');
    Writeln('Enter path of the TTKGP project. TTKPROJECT output will be placed in the same directory.');
    Writeln('TTKGP file will be kept in its place after conversion.');
    Writeln('Put directories with filenames and .TTKGP extension into parameters.');
    Readln;
    exit;
  end;

  vwr := TGIS_ViewerBmp.Create;
  path := ParamStr(1);
  vwr.Open(path);

  path := TPath.ChangeExtension( path, '.ttkproject' ) ;
  vwr.SaveProjectAs( path );
  vwr.Free
end.
