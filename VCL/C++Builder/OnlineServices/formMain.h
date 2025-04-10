//---------------------------------------------------------------------------

#ifndef formMainH
#define formMainH
//---------------------------------------------------------------------------
#include <vector>
#include <System.hpp>
#include <System.Classes.hpp>
#include <System.Generics.Collections.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.Grids.hpp>
#include "VCL.GisControlScale.hpp"
#include "VCL.GisViewerWnd.hpp"
#include <System.Classes.hpp>

//---------------------------------------------------------------------------
enum T_mapStyle {
	International,
	English,
	InternationalHillshade,
	EnglishHillshade
} ;

//---------------------------------------------------------------------------
class TfrmMain : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TGIS_ControlScale *GIS_Scale;
	TGroupBox *grpbxMap;
    TComboBox *cmbbxMap;
	TGroupBox *grpbxGeocoding;
	TLabel *lblGeocodingAddress;
	TEdit *edtGeocodingAddress;
	TLabel *lblGeocodingLimit;
	TComboBox *cmbbxGeocodingLimit;
	TButton *btnGeocoding;
	TGroupBox *grpbxRouting;
	TLabel *lblRoutingProfile;
	TRadioButton *rbtnRoutingProfileCar;
	TRadioButton *rbtnRoutingProfileBike;
	TRadioButton *rbtnRoutingProfileFoot;
	TStringGrid *strgrdRouting;
	TButton *btnRoutingAdd;
	TButton *btnRoutingDelete;
	TButton *btnRouting;
	TGroupBox *grpbxIsochrone;
	TLabel *lblIsochroneTime;
	TEdit *edtIsochroneTime;
	TLabel *lblIsochroneBuckets;
	TComboBox *cmbbxIsochroneBuckets;
	TLabel *lblIsochroneAddress;
	TEdit *edtIsochroneAddress;
	TButton *btnIsochrone;
	TGroupBox *grpbxRoutingDir;
	TLabel *lblRoutingDirDist;
	TLabel *lblRoutingDirTime;
	TLabel *lblRoutingDirInfo;
    TStringGrid *strgrdRoutingDir;
	TLabel *lblIsochroneProfile;
	TRadioButton *rbtnIsochroneProfileCar;
	TRadioButton *rbtnIsochroneProfileBike;
	TRadioButton *rbtnIsochroneProfileFoot;
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall cmbbxMapChange(TObject *Sender);
	void __fastcall btnGeocodingClick(TObject *Sender);
	void __fastcall btnRoutingAddClick(TObject *Sender);
	void __fastcall btnRoutingDeleteClick(TObject *Sender);
	void __fastcall btnRoutingClick(TObject *Sender);
	void __fastcall btnIsochroneClick(TObject *Sender);
	void __fastcall strgrdRoutingDirDblClick(TObject *Sender);
private:	// User declarations
    std::vector<TGIS_Uid> *shpList;
private:
	void __fastcall loadTiles(T_mapStyle _style);
	void __fastcall resetLayers();
    void __fastcall addDirection(UnicodeString _str, TGIS_Uid _uid);
public:		// User declarations
	__fastcall TfrmMain(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
//---------------------------------------------------------------------------
#endif
