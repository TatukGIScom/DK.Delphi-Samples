//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to provide SQL Layer support.
}

program SQLWizard;

uses
  Vcl.Forms,
  formLayerSQL in 'formLayerSQL.pas' {frmLayerSQL},
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmLayerSQL, frmLayerSQL);
  Application.Run;
end.
