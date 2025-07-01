//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  How to prepare small coverage previewer.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

USEFORM("SearchForm.cpp", frmSearch);
USEFORM("PrintForm.cpp", frmPrint);
USEFORM("ExportForm.cpp", frmExportLayer);
USEFORM("EditForm.cpp", frmEdit);
USEFORM("MainForm.cpp", frmMain);
USEFORM("InfoForm.cpp", frmInfo);
//---------------------------------------------------------------------------
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  try
  {
     Application->Initialize();
     Application->CreateForm(__classid(TfrmMain), &frmMain);
     Application->CreateForm(__classid(TfrmInfo), &frmInfo);
     Application->CreateForm(__classid(TfrmEdit), &frmEdit);
     Application->CreateForm(__classid(TfrmExportLayer), &frmExportLayer);
     Application->CreateForm(__classid(TfrmSearch), &frmSearch);
     Application->Run();
  }
  catch (Exception &exception)
  {
     Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
