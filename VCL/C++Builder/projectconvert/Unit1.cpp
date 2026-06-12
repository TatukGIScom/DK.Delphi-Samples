//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
/*
  projectconvert Sample — Converts legacy TTKGP project files to modern TTKPROJECT format.

  Key concepts illustrated:
    - Legacy project format handling (TTKGP)
    - Modern project format (TTKPROJECT)
    - Project file loading via headless viewer
    - Project file format conversion and upgrade
    - In-place conversion (original .ttkgp preserved)
    - File extension manipulation
    - Single-pass conversion pipeline

  User workflow:
    1. Run: projectconvert path_to_project.ttkgp
    2. Program opens the .ttkgp project
    3. Automatically converts to .ttkproject format
    4. Saves new .ttkproject file in same directory
    5. Original .ttkgp file remains unchanged

  File handling:
    - Input: .ttkgp (legacy TatukGIS Group Project format)
    - Output: .ttkproject (modern XML-based project format)
    - Location: output file placed in same directory as input
    - Non-destructive: original file preserved for backward compatibility

  Key API:
    - TGIS_ViewerBmp: headless viewer for project operations
    - vwr->Open(path): load project from file
    - vwr->SaveProjectAs(new_path): save project in new format
    - TPath::ChangeExtension: filename extension manipulation

  Use cases:
    - Batch migration of legacy projects to modern format
    - Project modernization without external tools
    - Preserving project layer references and metadata
    - Maintaining backward compatibility during transition
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
  Headless project converter: upgrades legacy TTKGP format to modern TTKPROJECT format.

  Algorithm:
    1. Initialize COM runtime for Windows compatibility
    2. Validate command-line arguments (exactly 1 argument required)
    3. Create headless viewer (TGIS_ViewerBmp) for project operations
    4. Load legacy .ttkgp project file
    5. Change output filename extension to .ttkproject
    6. Save project in new format to same directory
    7. Clean up viewer and exit

  Parameters:
    argc: argument count
    argv: argument vector

  Arguments expected:
    1. project_path: full path to .ttkgp file (extension auto-detected)

  Returns:
    0 on success, no return on argument error (waits for user input before exiting)

  Notes:
    - This is a non-destructive conversion (original .ttkgp preserved)
    - All layer references and metadata are preserved in conversion
    - Output .ttkproject uses modern XML format
*/
#pragma argsused
int main(int argc, char* argv[])
{
  TGIS_ViewerBmp *vwr  ;
  String path          ;

  CoInitialize( NULL );

  // Validate command-line arguments (must have exactly 1 argument)
  if ( ParamCount() != 1 ) {
    cout << "TatukGIS Samples - TTKGP -> TTKPROJECT converter" << endl ;
    cout << "Enter path of the TTKGP project. TTKPROJECT output will be placed in the same directory."<< endl ;
    cout << "TTKGP file will be kept in its place after conversion."<< endl ;
    cout << "Put directories with filenames and .TTKGP extension into parameters."<< endl;
    cin.get();
    return 0 ;
  }

  // Step 1: Create headless viewer for project operations
  vwr = new TGIS_ViewerBmp() ;

  // Step 2: Load legacy project
  path = ParamStr(1);
  vwr->Open( path );

  // Step 3: Change output filename extension to .ttkproject
  path = TPath::ChangeExtension( path, ".ttkproject" );

  // Step 4: Save project in modern TTKPROJECT format
  vwr->SaveProjectAs( path );

  // Step 5: Clean up resources
  delete vwr ;
}
//---------------------------------------------------------------------------
 
