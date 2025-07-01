//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
program Hydrology;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmHydrology},
  GisHydrology;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmHydrology, frmHydrology);
  Application.Run;
end.
