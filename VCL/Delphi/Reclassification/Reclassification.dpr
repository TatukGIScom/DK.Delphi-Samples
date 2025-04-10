program Reclassification;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmReclassification};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmReclassification, frmReclassification);
  Application.Run;
end.
