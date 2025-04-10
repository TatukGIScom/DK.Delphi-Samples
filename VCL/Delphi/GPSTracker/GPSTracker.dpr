//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
   TatukGIS sample - How to GPS NMEA Unit
}
program GPSTracker;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain} ;

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TatukGIS GPS NMEA';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
