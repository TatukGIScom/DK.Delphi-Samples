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

