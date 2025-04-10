//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
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
