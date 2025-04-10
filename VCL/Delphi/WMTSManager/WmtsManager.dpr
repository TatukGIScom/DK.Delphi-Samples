//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide WMTS Layer support.
}
program WMTSManager;

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {frmMain},
  formWMTS in 'formWMTS.pas' {frmWMTS};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmWMTS, frmWMTS);
  Application.Run;
end.
