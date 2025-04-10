//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  Simple BIM viewer.
  To read IFC files, please follow instructions from Deployment\ICF\Readme.txt
  BIM support requires Enterprise license.
}
program BimViewer;

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {frmMain},
  BimModel in 'BimModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
