//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
// GPSTracker sample — demonstrates real-time GPS tracking and visualization (C++Builder/VCL).
//
// What the sample shows:
//   - Opening a TGIS_GpsNmea component connected to a serial port
//   - Creating an in-memory TGIS_LayerVector for GPS waypoints and track
//   - Adding point shapes to mark each GPS position received
//   - Creating a polyline shape to show the continuous GPS track
//   - Selecting serial port and baud rate configuration
//   - Recording GPS data to a shapefile for archival
//   - Displaying the track on a TGIS_ViewerWnd map control
//   - Handling real-time position updates from NMEA stream
//   - Adding manual waypoint labels with user-defined names
//   - Fitting the map extent to the track bounds
//   - Clearing track and starting fresh recording session
//   - Progress feedback during GPS data reception
//
// Key TatukGIS API concepts shown here:
//   TGIS_GpsNmea                - GPS receiver component for serial NMEA data
//   TGIS_ViewerWnd              - main visual map control
//   TGIS_LayerVector            - in-memory vector layer for track storage
//   TGIS_Shape (point)          - point geometry for waypoint markers
//   TGIS_Shape (polyline)       - polyline geometry for continuous track
//   GPSPosition event           - callback for each position update
//   NMEA 0183                   - standard GPS sentence format
//   Serial port configuration   - COM port and baud rate
//   Shapefile export            - saving track to .shp file
//   Map extent fitting          - FullExtent() for track bounds
//
//  How to use GPS Nmea unit.
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
#include <ExtCtrls.hpp>
#include <ToolWin.hpp>
#include <SyncObjs.hpp>
#include <ActnList.hpp>
#include <ImgList.hpp>
#include <DB.hpp>
#include "Vcl.GisGps.hpp"
#include "GisViewer.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include "GisRegistredLayers.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TToolBar *ToolBar1;
  TPanel *paLeft;
  TGIS_GpsNmea *GPS;
  TPanel *paInfo;
  TGIS_ViewerWnd *GIS;
  TToolButton *btnSave;
  TToolButton *btnRecord;
  TToolButton *ToolButton3;
  TEdit *edtPoint;
  TButton *btnAdd;
  TActionList *actList;
  TAction *actAdd;
  TAction *actRecord;
  TAction *actSave;
  TToolButton *ToolButton4;
  TComboBox *cbxCom;
  TComboBox *cbxBaud;
  TImageList *ImageList1;
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall GPSPosition(TObject *Sender);
  void __fastcall GISMouseMove(TObject *Sender, TShiftState Shift, int X,
          int Y);
  void __fastcall cbxComChange(TObject *Sender);
  void __fastcall actAddExecute(TObject *Sender);
  void __fastcall actSaveExecute(TObject *Sender);
  void __fastcall actRecordExecute(TObject *Sender);
  void __fastcall FormCloseQuery(TObject *Sender, bool &CanClose);
  void __fastcall cbxBaudChange(TObject *Sender);
  void __fastcall actListUpdate(TBasicAction *Action, bool &Handled);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
  TGIS_Shape  *currShape;
  TGIS_Point  lastPointGps;
  TGIS_Point  lastPointMap;


};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;

extern void MyInit(void);
extern void MyFinal(void);
//---------------------------------------------------------------------------
#endif
