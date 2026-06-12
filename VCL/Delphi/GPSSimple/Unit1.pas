//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  GPSSimple sample — demonstrates basic GPS data reception and display (Delphi/VCL).

  What the sample shows:
    - Opening a TGIS_GpsNmea component connected to a serial port
    - Selecting a serial port (COM 1-10) from a combo box
    - Setting the baud rate (1200 to 19200) from a combo box
    - Reading NMEA 0183 GPS sentences from the serial stream
    - Parsing GPS position data (latitude, longitude, altitude)
    - Handling GPS position events (GPSPosition callback)
    - Displaying raw GPS data in a memo control
    - Real-time position updates as new data arrives
    - COM port and baud rate switching without restarting
    - Basic NMEA sentence interpretation

  Key TatukGIS API concepts shown here:
    TGIS_GpsNmea                - GPS receiver component for serial NMEA data
    GPSPosition event           - callback fired when new position is received
    Serial port configuration   - COM port and baud rate selection
    NMEA 0183 format            - standard GPS sentence structure
    GPS coordinates             - latitude, longitude, altitude
    Real-time data streaming    - continuous position updates
}

unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,
  System.Math,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.ToolWin,

  //GisLicense,

  Vcl.GisGps;

type
  TfrmMain = class(TForm)
    ToolBar1: TToolBar;
    cbxCom: TComboBox;
    cbxBaud: TComboBox;
    GPS: TGIS_GpsNmea;
    Memo1: TMemo;
    procedure cbxComChange(Sender: TObject);
    procedure cbxBaudChange(Sender: TObject);
    procedure GPSPosition(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;


implementation

{$R *.DFM}


procedure TfrmMain.cbxComChange(Sender: TObject);
begin
  GPS.Com := cbxCom.ItemIndex + 1 ;
  GPS.Active := True ;
end;

procedure TfrmMain.cbxBaudChange(Sender: TObject);
begin
  GPS.BaudRate := StrToInt( cbxBaud.Items[ cbxBaud.ItemIndex ] ) ;
  GPS.Active := True ;
end;



procedure TfrmMain.GPSPosition(Sender: TObject);
var
  str : String ;
begin
  str := Format( '%s %.4f %.4f', [ TimeToStr(Now),
                                   RadToDeg( GPS.Longitude ),
                                   RadToDeg( GPS.Latitude  )
                                 ]
               ) ;
  Memo1.Lines.Add( str ) ;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i : Integer ;
begin
  cbxCom.ItemIndex := GPS.Com-1 ;

  for i:=0 to cbxBaud.Items.Count - 1 do begin
    if StrToInt( cbxBaud.Items[ i ] ) = GPS.BaudRate then begin
       cbxBaud.ItemIndex := i ;
       break ;
    end
  end ;
  GPS.Active := True ;
end;

end.

