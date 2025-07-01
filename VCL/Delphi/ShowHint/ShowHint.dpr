//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to show map hints : data fields from shape file
}
program ShowHint;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain},
  frmHint in 'frmHint.pas' {frmHints};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmHints, frmHints);
  Application.Run;
end.
