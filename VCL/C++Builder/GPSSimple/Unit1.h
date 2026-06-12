//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// GPSSimple sample — demonstrates basic GPS data reception and display (C++Builder/VCL).
//
// What the sample shows:
//   - Opening a TGIS_GpsNmea component connected to a serial port
//   - Selecting a serial port (COM 1-10) from a combo box
//   - Setting the baud rate (1200 to 19200) from a combo box
//   - Reading NMEA 0183 GPS sentences from the serial stream
//   - Parsing GPS position data (latitude, longitude, altitude)
//   - Handling GPS position events (GPSPosition callback)
//   - Displaying raw GPS data in a memo control
//   - Real-time position updates as new data arrives
//   - COM port and baud rate switching without restarting
//   - Basic NMEA sentence interpretation
//
// Key TatukGIS API concepts shown here:
//   TGIS_GpsNmea                - GPS receiver component for serial NMEA data
//   GPSPosition event           - callback fired when new position is received
//   Serial port configuration   - COM port and baud rate selection
//   NMEA 0183 format            - standard GPS sentence structure
//   GPS coordinates             - latitude, longitude, altitude
//   Real-time data streaming    - continuous position updates
//
//  How to GPS NMEA Unit.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ToolWin.hpp>
#include <ExtCtrls.hpp>
#include <DB.hpp>
#include "VCL.GisGps.hpp"
#include "VCL.GisFramework.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TGIS_GpsNmea *GPS;
  TMemo *Memo1;
  TComboBox *cbxCom;
  TComboBox *cbxBaud;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GPSPosition(TObject *Sender);
  void __fastcall cbxComChange(TObject *Sender);
  void __fastcall cbxBaudChange(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
