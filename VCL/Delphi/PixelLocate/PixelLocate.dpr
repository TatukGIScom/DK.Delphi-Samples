//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide basic pixel support.
}
program PixelLocate;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R PixelLocate.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
