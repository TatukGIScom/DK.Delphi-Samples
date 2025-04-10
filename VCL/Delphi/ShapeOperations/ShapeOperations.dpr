//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to transform a shape geometry.
}
program ShapeOperations;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R ShapeTransform.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
