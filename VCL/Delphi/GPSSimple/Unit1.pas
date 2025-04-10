//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
   TatukGIS sample - How to GPS NMEA Unit
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

