//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  Export to image window
}
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
