//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide WFS Layer support.
}
program WfsManager;

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {frmMain},
  formWFS in 'formWFS.pas' {frmWFS};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmWFS, frmWFS);
  Application.Run;
end.
