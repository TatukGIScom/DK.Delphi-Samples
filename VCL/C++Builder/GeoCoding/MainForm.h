//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================


#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <ComCtrls.hpp>
#include <DB.hpp>
#include "GisShortestPath.hpp"
#include "GisGeocoding.hpp"
#include "VCL.GisControlScale.hpp"
#include "GisViewer.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisTypesUI.hpp"
#include "GisLayerADF.hpp"

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TGIS_ViewerWnd *GIS;
    TGIS_ControlScale *GIS_ControlScale1;
    TPanel *Panel2;
    TMemo *memRoute;
    TGroupBox *GroupBox1;
    TTrackBar *trkSmallRoads;
    TTrackBar *trkHighways;
    TLabel *lblSmallRoads;
    TLabel *lblHighways;
    TEdit *edtAddrFrom;
    TButton *btnResolve;
    TEdit *edtAddrTo;
    TButton *btnRoute;
    TLabel *lblAddrFrom;
    TLabel *lblAddrTo;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall btnResolveClick(TObject *Sender);
        void __fastcall btnRouteClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
private:	// User declarations
    TGIS_LayerVector *layerSrc ;
    TGIS_LayerVector *layerRoute ;
    TGIS_ShortestPath *rtrObj ;
    TGIS_Geocoding *geoObj ;
	Double costFactor ;
	void  __fastcall doLinkType( TObject * _sender, TGIS_ShapeArc * _shape,
					 int &_type ) ;

public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
