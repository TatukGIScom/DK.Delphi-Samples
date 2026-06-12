program LayerStatistics;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmStatistics};

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True ;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmStatistics, frmStatistics);
  Application.Run;
end.

