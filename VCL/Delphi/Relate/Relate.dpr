//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{ How to compute relations between two shapes.
  Main form
}
program Relate;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
