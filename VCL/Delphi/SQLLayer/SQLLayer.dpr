//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide SQL Layer support.
  Edit gistest.ttkls to provied your database access
  You can use *.ttkls as any other layer (for example open in editor)
}

program SQLLayer;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
