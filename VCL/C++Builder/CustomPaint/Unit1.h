//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <ToolWin.hpp>
#include <DB.hpp>
#include <Direct2D.hpp>
#include "GisUtils.hpp"
#include "GisViewer.hpp"
#include "GisLayerSHP.hpp"
#include "GisTypesUI.hpp"
#include "VCL.GisViewerWnd.hpp"
#include "VCL.GisRendererGdi32.hpp"
#include "VCL.GisRendererGdiPlus.hpp"
#include "VCL.GisRendererDirect2D.hpp"

// Delphi DX12 (RAD RX12)
#ifdef VER360
  #define LEVEL_RX12_VCL
#endif

#ifdef LEVEL_RX12_VCL
  #define SKIA
#endif

#ifdef SKIA
  #include "VCL.GisRendererSkia.hpp"
  #include <System.Skia.hpp>
#endif

//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
	TGIS_ViewerWnd *GIS;
	TComboBox *cbRenderer;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall cbRendererChange(TObject *Sender);
	void __fastcall GISPaintExtraEvent(TObject *_sender, TGIS_RendererAbstract *_renderer,
          TGIS_DrawMode _mode);
private:	// User declarations
public:		// User declarations
	__fastcall TForm1(TComponent* Owner);
	void __fastcall initialize_pixels() ;
	void __fastcall GISPaintShapeEvent(TObject *_sender, TGIS_Shape *_shape);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
