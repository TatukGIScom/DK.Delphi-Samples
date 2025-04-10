//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Example of dem operations.
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

#include <Vcl.ComCtrls.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <Vcl.ImgList.hpp>
#include <Vcl.ToolWin.hpp>
#include "GisTypes.hpp"
#include "GisEditor.hpp"
#include "GisLayerVector.hpp"
#include "GisLayerPixel.hpp"
#include "GisTypesUI.hpp"
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisLayerADF.hpp"
#include "GisDem.hpp"
#include "VCL.GisControlLegend.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "GisRegistredLayers.hpp"
#include <cmath>

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TToolBar           *ToolBar1;
	TGIS_ViewerWnd     *GIS ;
	TStatusBar         *StatusBar ;
	TToolButton        *btnFullExtent ;
	TToolButton        *btnZoom ;
	TToolButton        *btnDrag ;
	TToolButton        *ToolButton4;
	TImageList         *ImageList1 ;
	TPanel             *paTop ;
	TGroupBox          *GroupBox1;
	TTrackBar          *tbShadowAngle ;
	TButton            *btnGenerate ;
	TComboBox          *cbDemOperation ;
	TLabel             *Label19;
	TLabel             *Label20;
	TLabel             *Label21;
	TCheckBox          *cbCombined ;
	TEdit              *eZFactor ;
	TEdit              *eAzimuth;
	TEdit              *eAltitude;
	TLabel             *Label18;
	TLabel             *Label17;
	TComboBox          *cbSlopeMode;
	TEdit              *eScale ;
	TGIS_ControlLegend *GIS_Legend;
	TLabel             *Label1 ;
	TProgressBar       *pboperation ;
	TCheckBox          *cbCustomOperation ;
	TGroupBox          *gbMain ;
	TToolButton        *ToolButton1 ;
	TToolButton        *ToolButton2;
	TOpenDialog        *dlgFileOpen ;
	TCheckBox          *chkAngleAzimuth ;
	TGroupBox          *gbHillShadeParams ;
	TGroupBox          *gbSlopeParams ;
	TComboBox          *cbCurvatureMode ;
	TLabel             *Label2 ;
	TGroupBox          *gbCurvature ;
	TToolButton        *btn1;
	TToolButton        *btn2 ;
	void __fastcall btnFullExtentClick(TObject *Sender);
	void __fastcall btnZoomClick(TObject *Sender);
	void __fastcall cbCustomOperationClick(TObject *Sender);
	void __fastcall btnGenerateClick(TObject *Sender);
	void __fastcall cbDemOperationChange(TObject *Sender);
	void __fastcall btn1Click(TObject *Sender);
	void __fastcall btnDragClick(TObject *Sender);
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort);
	double __fastcall trunc( double d );
	void __fastcall tbShadowAngleChange(TObject *Sender);
	void __fastcall ToolButton1Click(TObject *Sender);


private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	bool __fastcall changeDEM( TObject* _layer,
							   const TGIS_Extent &_extent,
							   const TGIS_GridArray _source,
							   TGIS_GridArray &_output,
							   const int _width,
							   const int _height,
							   float &_minz,
							   float &_maxz
							);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
