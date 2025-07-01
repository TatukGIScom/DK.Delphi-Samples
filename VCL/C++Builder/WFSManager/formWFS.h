//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================

//
//  WFS Manager.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef formWFSH
#define formWFSH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.Variants.hpp>
#include <System.SysUtils.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Menus.hpp>
#include "GisFileWFS.hpp"
#include "GisFunctions.hpp"
#include "GisTypes.hpp"
#include "GisClasses.hpp"
#include "GisResource.hpp"
#include "GisLayerWFS.hpp"
#include "GisCsSystems.hpp"
#include "GisCsFactory.hpp"

//---------------------------------------------------------------------------
class TfrmWFS : public TForm
{
__published:	// IDE-managed Components
	TLabel *Label1;
	TComboBox *cbURL;
	TTreeView *tvLayers;
	TGroupBox *GroupBox1;
	TButton *btnLoadService;
	TGroupBox *GroupBox2;
	TLabel *Label2;
	TEdit *eParams;
	TLabel *Label3;
	TComboBox *cbDataFormats;
	TCheckBox *cbReverseXY;
	TCheckBox *cbMaxFeatures;
	TEdit *seMaxFeatures;
	TCheckBox *cbBBoxFIlter;
	TButton *btnAddLayer;
	TLabel *Label4;
	TComboBox *cbCRS;
	TMemo *memLayerInfo;
	TGroupBox *GroupBox3;
	TGroupBox *GroupBox4;
	TButton *btnCancel;
	TComboBox *cbVersion;
	TLabel *Label5;
	TEdit *eYMin;
	TEdit *eXMax;
	TEdit *eXMin;
	TEdit *eYMax;
	TLabel *lblXMin;
	TLabel *lblXMax;
	TLabel *lblYMax;
	TLabel *lblYMin;
	TCheckBox *cbStartIndex;
	TEdit *seStartIndex;
	TCheckBox *chkClipVisibleExtent;
	TPopupMenu *pm1;
	TMenuItem *Locateonmap1;
	TButton *btnOpenURL;
	TMenuItem *OpenMetadata1;
	void __fastcall btnAddLayerClick(TObject *Sender);
	void __fastcall btnCancelClick(TObject *Sender);
	void __fastcall btnLoadServiceClick(TObject *Sender);
	void __fastcall btnOpenURLClick(TObject *Sender);
	void __fastcall cbBBoxFIlterClick(TObject *Sender);
	void __fastcall cbMaxFeaturesClick(TObject *Sender);
	void __fastcall cbStartIndexClick(TObject *Sender);
	void __fastcall chkClipVisibleExtentClick(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall Locateonmap1Click(TObject *Sender);
	void __fastcall OpenMetadata1Click(TObject *Sender);
	void __fastcall tvLayersChange(TObject *Sender, TTreeNode *Node);
private:	// User declarations
	TGIS_FileWFS *wfs ;
	TGIS_WFSFeature * __fastcall getSelectedFeature() ;
	TGIS_Extent __fastcall getBBoxExtent( const TGIS_WFSFeature * _fea ) ;
public:		// User declarations
	__fastcall TfrmWFS(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TfrmWFS *frmWFS;
//---------------------------------------------------------------------------
#endif
