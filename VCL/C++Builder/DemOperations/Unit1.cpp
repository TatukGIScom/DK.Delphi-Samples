//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  Example of dem operations.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma link "VCL.GisViewerWnd"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFullExtentClick(TObject *Sender)
{
  GIS->FullExtent();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnZoomClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbCustomOperationClick(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = ( TGIS_LayerPixel *)( GIS->Items->Items[0] );
  if ( ll == NULL ) {
    return ;
  }

  if ( cbCustomOperation->Checked ) {
    ll ->Params->Pixel->AltitudeMapZones->Clear() ;
    ll->Params->Pixel->GridShadow = False ;
    ll->GridOperationEvent = changeDEM ;
  }
  else{
      ll->GridOperationEvent = NULL ;
      ll->Params->Pixel->GridShadow = True ;
  }

  GIS->InvalidateWholeMap() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnGenerateClick(TObject *Sender)
{
  TGIS_LayerPixel *lp ;
  TGIS_LayerPixel *ld ;
  TGIS_DemGenerator *dem ;
  TGIS_DemOperation *dop ;
  TGIS_DemSlopeMode sm ;
  TGIS_DemTotalCurvatureMode cm ;
  double eZFactorD ;
  double eAzimuthD ;
  double eAltitudeD ;
  double eScaleD ;
  lp = ( TGIS_LayerPixel *)(GIS->Items->Items[0]);
  ld = new TGIS_LayerPixel ;
  ld->Name = "out_" ;
  ld->CS = lp->CS ;
  ld->Build( True, lp->CS, lp->Extent, lp->BitWidth, lp->BitHeight ) ;
  dem = new TGIS_DemGenerator ;
  try {
    switch( cbDemOperation->ItemIndex ) {
        // Hillshade
        case 0:
          eZFactorD = DotStrToFloat( eZFactor->Text ) ;
          eAzimuthD = DotStrToFloat( eAzimuth->Text ) ;
          eAltitudeD = DotStrToFloat( eAltitude->Text ) ;
          dop = new TGIS_DemOperationHillShade( eZFactorD,
                                                eAzimuthD,
                                                eAltitudeD,
                                                cbCombined->Checked
                                               );
          break ;
        // Slope
        case 1:
          switch( cbSlopeMode->ItemIndex ){
            case 0: sm = TGIS_DemSlopeMode::Degrees ;
                    break ;
            case 1: sm = TGIS_DemSlopeMode::Percent ;
                    break ;
            default: sm = TGIS_DemSlopeMode::Degrees ;
                    break;
          }
          eScaleD = DotStrToFloat( eScale->Text ) ;
          dop = new TGIS_DemOperationSlope( sm, eScaleD );
          break ;
        // Slope Hydro
        case 2:
          switch( cbSlopeMode->ItemIndex ){
            case 0: sm = TGIS_DemSlopeMode::Degrees ;
                    break ;
            case 1: sm = TGIS_DemSlopeMode::Percent ;
                    break ;
            default: sm = TGIS_DemSlopeMode::Degrees ;
                    break ;
          }
          eScaleD = DotStrToFloat( eScale->Text ) ;
          dop = new TGIS_DemOperationSlopeHydro( sm, eScaleD );
          break ;
        // Aspect
        case 3: dop = new TGIS_DemOperationAspect( chkAngleAzimuth->Checked ) ;
                break ;
        // TRI
        case 4: dop = new TGIS_DemOperationTRI ;
                break ;
        // TPI
        case 5: dop = new TGIS_DemOperationTPI ;
                break ;
        // Roughness
        case 6: dop = new TGIS_DemOperationRoughness ;
                break ;
        // TotalCurvature
        case 7:
          switch( cbCurvatureMode->ItemIndex ){
            case 0: cm = TGIS_DemTotalCurvatureMode::Profile ;
                    break ;
            case 1: cm = TGIS_DemTotalCurvatureMode::Plan ;
                    break ;
            default : cm = TGIS_DemTotalCurvatureMode::Profile ;
                      break ;
          }
          dop = new TGIS_DemOperationTotalCurvature( cm );
          break ;
        // MatrixGain
        case 8: dop = new TGIS_DemOperationMatrixGain ;
                break ;
        case 9: dop = new TGIS_DemOperationFlowDir ;
                break ;
        default : dop = new TGIS_DemOperation ;
                  break ;
    }
    ld->Name = "out_" + dop->Description() ;
    if ( GIS->Get( ld->Name ) != NULL) {
      GIS->Delete( ld->Name ) ;
    }
    ld->Params->Pixel->GridShadow = False ;
    GIS->Add( ld ) ;
    try{
      dem->Process( lp, lp->Extent, ld, dop, GISBusyEvent ) ;
    }
    __finally{
      delete dop ;
    }
    GIS->InvalidateWholeMap() ;
  }
  __finally {
    delete dem ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::cbDemOperationChange(TObject *Sender)
{
  gbHillShadeParams->Visible = False ;
  gbSlopeParams->Visible = False ;
  chkAngleAzimuth->Visible = False ;
  gbCurvature->Visible = False ;
  gbSlopeParams->Top = gbHillShadeParams->Top ;
  gbCurvature->Top = gbHillShadeParams->Top;

  chkAngleAzimuth->Top = gbHillShadeParams->Top ;

  switch( cbDemOperation->ItemIndex ){
    case 0: gbHillShadeParams->Visible = True ;
            break ;
    case 1: gbSlopeParams->Visible = True ;
            break ;
    case 2: gbSlopeParams->Visible = True ;
            break ;
    case 3: chkAngleAzimuth->Visible = True ;
            break ;
    case 7: gbCurvature->Visible = True ;
            break ;
  }

  gbMain->Height = 250 ;
  btnGenerate->Top = gbMain->Top + 260 ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btn1Click(TObject *Sender)
{
  GIS->View3D = !( GIS->View3D ) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnDragClick(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Drag ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
  TGIS_FileTypes _mode;
  dlgFileOpen->Filter = GisSupportedFiles( _mode << TGIS_FileType::All, false );

  GIS->Open( GisSamplesDataDirDownload() +
             "\\World\\Countries\\USA\\States\\California\\San Bernardino\\NED\\w001001.adf" );
  cbDemOperationChange( Sender ) ;
}
//---------------------------------------------------------------------------

double _fastcall TForm1::trunc(double d){
  return (d>0) ? floor(d) : ceil(d) ;
}
void __fastcall TForm1::GISBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)

{
  if ( _end <= 0 ) {
    pboperation->Visible = False ;
  }
  else{
    pboperation->Visible = True ;
    pboperation->Position = trunc( _pos / _end * 100 );
  }

  pboperation->Update();
  Application->ProcessMessages() ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::tbShadowAngleChange(TObject *Sender)
{
  TGIS_LayerPixel *ll ;

  ll = ( TGIS_LayerPixel *)( GIS->Items->Items[0] ) ;
  if ( ll == NULL ) {
    return ;
  }

  ll->Params->Pixel->GridShadowAngle = tbShadowAngle->Position ;
  if ( GIS->InPaint == NULL ) {
    GIS->InvalidateWholeMap() ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::ToolButton1Click(TObject *Sender)
{
  if (dlgFileOpen->Execute() == False) {
    return ;
  }
  GIS->Open( dlgFileOpen->FileName ) ;
}
//---------------------------------------------------------------------------
#define  RAD_TO_DEG     180.0 / 3.14
#define  DEG_TO_RAD     3.14 / 180.0
#define  SQUARE_M_PI_2  (3.14*3.14)/4
bool __fastcall TForm1::changeDEM(
  TObject* _layer,
  const TGIS_Extent &_extent,
  const TGIS_GridArray _source,
  TGIS_GridArray &_output,
  const int _width,
  const int _height,
  float &_minz,
  float &_maxz
){
  int i, j              ;
  double sin_alt_rad    ;
  double cos_alt_zsf    ;
  double az_rad         ;
  double square_z_sf    ;
  double z_scale_factor ;
  float minz, maxz     ;
  double ZFactor        ;
  double Azimuth        ;
  double Altitude       ;
  bool Combined         ;
  float NoDataValue    ;
  double XRes           ;
  double YRes           ;
  double Scale          ;
  float AWindow[8]     ;
  int k,l               ;
  int xsize             ;
  int ysize             ;
  double xscale         ;
  double yscale         ;
  float val            ;
  bool usealg           ;
  bool abrt             ;
  int l1,l2,l3          ;
  float inodata        ;
  double x, y, aspect,
         xx_plus_yy,
         cang           ;
  bool result           ;
  double tmp            ;
  double ptr            ;

  result = True         ;


  xsize   = _width ;
  ysize   = _height ;
  xscale  = (_extent.XMax - _extent.XMin ) / xsize ;
  yscale  = ( _extent.YMax - _extent.YMin ) / ysize ;
  abrt    = False ;

  inodata = ( ( TGIS_LayerPixel *)( _layer) )->NoDataValue;


  XRes    = xscale ;
  YRes    = yscale ;
  Scale   = 1 ;
  minz    = GIS_MAX_SINGLE ;
  maxz    = -GIS_MAX_SINGLE ;

  ZFactor   = 2 ;
  Azimuth   = tbShadowAngle->Position ;
  Altitude  = 15 ;
  Combined  = False ;

  tmp = Altitude * DEG_TO_RAD ;
  sin_alt_rad     = sin(tmp ) ;
  az_rad          = Azimuth * DEG_TO_RAD ;
  z_scale_factor  = ZFactor / (2*Scale) ;
  tmp = Altitude*DEG_TO_RAD ;
  cos_alt_zsf     = cos( tmp ) * z_scale_factor ;
  square_z_sf     = z_scale_factor * z_scale_factor ;

  for( i = 2; i<=(_height-1); i++ ){
    l1 = i-2 ;
    l2 = i-1 ;
    l3 = i ;
    for( j = 1; j<=_width-2 ; j++ ){
      AWindow[0] = 12.1 ;
      AWindow[0] = _source[l1][j-1] ;
      AWindow[1] = _source[l1][j];
      AWindow[2] = _source[l1][j+1] ;
      AWindow[3] = _source[l2][j-1] ;
      AWindow[4] = _source[l2][j];
      AWindow[5] = _source[l2][j+1] ;
      AWindow[6] = _source[l3][j-1] ;
      AWindow[7] = _source[l3][j] ;
      AWindow[8] = _source[l3][j+1] ;

      usealg = True ;
      val = inodata ;
      if( abs(AWindow[4] - inodata) < 1e-10 ){
        val = inodata ;
        usealg = False ;
      }
      else{
        for ( k = 0; i <= 8; i++ ){
          if ( abs(AWindow[k] - inodata) < 1e-10 ){
            val = inodata ;
            usealg = False ;
            break ;
          }
        }
      }

      if ( usealg ){
        x = (AWindow[3] - AWindow[5]) / XRes ;
        y = (AWindow[7] - AWindow[1]) / YRes ;

        xx_plus_yy = x * x + y * y;
        aspect = atan2(y,x);
        cang = (sin_alt_rad - cos_alt_zsf * sqrt(xx_plus_yy) *
                 Sin(aspect - az_rad)) /Sqrt(1 + square_z_sf * xx_plus_yy);
        if (cang <= 0.0)
          cang = 1.0;
        else
          cang = 1.0 + (254.0 * cang);
        val = cang ;
      }

      if ( _source[l1][j] != inodata ){
        _output[l1][j] = val ;
      }

      if ( ( val < minz ) &&
         ( val != inodata ) )
        minz = val ;

      if ( ( val > maxz      ) &&
         ( val != inodata ) )
        maxz = val ;
    }
  }
  _minz = minz ;
  _maxz = maxz ;

  return result ;
}
