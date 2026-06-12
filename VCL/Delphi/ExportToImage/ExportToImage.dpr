program ExportToImage;

uses
  Vcl.Forms,
  mainform in 'mainform.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TatukGIS ExportToImage';
  Application.CreateForm(TfrmExportToImage, frmExportToImage);
  Application.Run;
end.

