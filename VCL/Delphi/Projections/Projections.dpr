program Projections;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

