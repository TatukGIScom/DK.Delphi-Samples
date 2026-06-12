program Classification;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmClassification};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True ;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmClassification, frmClassification);
  Application.Run;
end.

