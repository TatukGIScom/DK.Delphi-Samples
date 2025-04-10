//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Export to image window
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include "VCL.GisViewerWnd.hpp"
#include <Vcl.ActnList.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <stdio.h>
#include "GisAllLayers.hpp"
#include "GisClasses.hpp"
#include "GisEditor.hpp"
#include "GisLayer.hpp"
#include "GisLayerPixel.hpp"
#include "GisRegistredLayers.hpp"
#include "GisResource.hpp"
#include "GisTypes.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "Vcl.GisViewerWnd.hpp"
#include <System.Actions.hpp>

#define round(a) int((a)+0.5)

#define  DEFAULT_PPI              300
#define  DEFAULT_PPI_WEB          96
#define  DEFAULT_PPI_DOC         300
#define  DEFAULT_WIDTHPIX        4200
#define  DEFAULT_WIDTHPIX_WEB    640
#define  DEFAULT_WIDTH_DOC_MM    160
#define  DEFAULT_WIDTH_DOC_CM    16
#define  DEFAULT_WIDTH_DOC_INCH  6.3
#define  UNITS_MM    0
#define  UNITS_CM    1
#define  UNITS_INCH  2

//---------------------------------------------------------------------------
class T_capability {
  public:
	TGIS_LayerPixelSubFormat C ;
	T_capability( TGIS_LayerPixelSubFormat _c ) ;
};

T_capability::T_capability( TGIS_LayerPixelSubFormat _c ){
	C = _c.CreateCopy();
}
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TButton           *btnSave           ;
	TActionList       *actlMain          ;
	TAction           *actSave           ;
	TGroupBox         *gbFile            ;
	TEdit             *edtFile           ;
	TGroupBox         *gbCompression     ;
	TGroupBox         *gbSize            ;
	TRadioButton      *rbQbest           ;
	TRadioButton      *rbQdoc            ;
	TRadioButton      *rbQweb            ;
	TGroupBox         *GroupBox1         ;
	TLabel            *lbFormat          ;
	TComboBox         *cbType            ;
	TGIS_ViewerWnd    *GIS               ;
	TRadioButton      *rbExtentMap       ;
	TRadioButton      *rbExtentVisible   ;
	TLabel            *Label1            ;
	TButton           *btnSelectFile     ;
	TRadioButton      *rbImage           ;
	TRadioButton      *rbGrid            ;
	TSaveDialog       *dlgSaveGrid       ;
	TSaveDialog *dlgSaveImage;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall rbImageClick(TObject *Sender);
	void __fastcall rbGridClick(TObject *Sender);
	void __fastcall btnSelectFileClick(TObject *Sender);
	void __fastcall actSaveExecute(TObject *Sender);
	void __fastcall GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);


private:	// User declarations
	 TGIS_LayerPixelSubFormat *current_obj ;
	 TObjectList              *lst ;
	 TGIS_Extent              FExtent ;
	 bool                     FExtentAuto ;
	 int                      ppi;
	 double                   pixWidth;
	 double                   pixHeight;
	 int                      expWidth;
     int                      expHeight;

	 String __fastcall getExp_path() ;
	 int __fastcall getExp_width() ;
	 int __fastcall getExp_height();
	 unsigned __fastcall getExp_quality();
	 TGIS_PixelFormat __fastcall getExp_pixelformat();
	 int __fastcall getExp_subformat();
	 int __fastcall getExp_ppi() ;
	 double __fastcall trunc(double d) ;
	 Extended __fastcall ImageSizeCalculate() ;
	 void __fastcall ValuesInit();
	 void __fastcall ValuesWH();
	 void __fastcall ValuesWHpix();

public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	TGIS_LayerPixel   *lstp            ;
	TGIS_LayerPixel   *lpx             ;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

