//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//  How to provide Geocoding using name standarization
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

USEFORM("MatchesForm.cpp", FormMatches);
USEFORM("HelpForm.cpp", FormHelp);
USEFORM("InfoForm.cpp", FormInfo);
USEFORM("MainForm.cpp", Form1);
//---------------------------------------------------------------------------
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  try
  {
    Application->Initialize();
    Application->CreateForm(__classid(TForm1), &Form1);
    Application->CreateForm(__classid(TFormMatches), &FormMatches);
    Application->CreateForm(__classid(TFormHelp), &FormHelp);
    Application->CreateForm(__classid(TFormInfo), &FormInfo);
    Application->Run();
  }
  catch (Exception &exception)
  {
    Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
