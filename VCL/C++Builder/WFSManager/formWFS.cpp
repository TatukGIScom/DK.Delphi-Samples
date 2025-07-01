//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
//
//  WFS Manager.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "formWFS.h"
#include "formMain.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TfrmWFS *frmWFS;
//---------------------------------------------------------------------------
__fastcall TfrmWFS::TfrmWFS(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TfrmWFS::btnAddLayerClick(TObject *Sender)
{
  TGIS_WFSFeature *fea ;
  String wfsPath ;
  String str ;

  wfsPath = "&SERVICE=WFS" ;

  if( eParams->Text != "" ){
    wfsPath = wfsPath + "&" + eParams->Text ;
  }
  if( cbVersion->Text != "" ){
    wfsPath = wfsPath + "&VERSION=" + cbVersion->Text ;
  }
  fea = getSelectedFeature() ;
  if( fea != NULL){
    wfsPath = wfsPath + "&TYPENAME=" + fea->Name ;
  }
  if( cbCRS->Text != "" ){
    wfsPath = wfsPath + "&SRSNAME=" + cbCRS->Text ;
  }
  if( cbDataFormats->Text != "" ) {
    wfsPath = wfsPath + "&OUTPUTFORMAT=" + cbDataFormats->Text ;
  }
  if( cbMaxFeatures->Checked ){
    wfsPath = wfsPath + "&MAXFEATURES=" + seMaxFeatures->Text ;
  }
  if( cbStartIndex->Checked ){
    wfsPath = wfsPath + "&STARTINDEX=" + seStartIndex->Text ;
  }
  if( cbBBoxFIlter->Checked ){
    if( cbReverseXY->Checked ){
      wfsPath = wfsPath +
                   str.sprintf( L"&BBOX=%s,%s,%s,%s",
                            DotFloatToStr(StrToFloat(eYMin->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eXMin->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eYMax->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eXMax->Text)).c_str()
                          );
    }
  }
  else{
      wfsPath = wfsPath +
                   str.sprintf( L"&BBOX=%s,%s,%s,%s",
                            DotFloatToStr(StrToFloat(eXMin->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eYMin->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eXMax->Text)).c_str(),
                            DotFloatToStr(StrToFloat(eYMax->Text)).c_str()
                          ) ;
  }

  if( cbReverseXY->Checked ){
    wfsPath = wfsPath + "&AxisOrder=" + GIS_INI_AXIS_ORDER_NE ;
  }
  frmMain->AppendCoverage( wfs->MakeUrl( wfsPath, cbURL->Text ) ) ;


}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::btnCancelClick(TObject *Sender)
{
    //this->Close();
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::btnLoadServiceClick(TObject *Sender)
{
  String str   ;
  int i ;
  TTreeNode *root ;
  TTreeNode *node ;
  TGIS_WFSFeature *fea ;

  str = cbURL->Text ;
  if( str == "") return ;

  tvLayers->Items->Clear() ;
  memLayerInfo->Lines->Clear() ;
  wfs->Load( str ) ;

  if(!IsStringEmpty( wfs->Error )){
    new EGIS_Exception( _rsrc( GIS_RS_ERR_SERVER_ERROR ), wfs->Error, 0 ) ;
  }
  if( wfs->FeaturesCount == 0 ) return ;

  tvLayers->Items->BeginUpdate() ;
  try{
    root = tvLayers->Items->Add( NULL, wfs->Path ) ;
    for( i = 0 ; i<= wfs->FeaturesCount-1 ; i++ ){
      fea = wfs->Feature[i] ;
      node = tvLayers->Items->AddChild( root, fea->Name ) ;
      node->Data = wfs->Feature[i] ;
    }
    root->Expanded = true ;
    tvLayers->Select( root ) ;
  }
  __finally{
    tvLayers->Items->EndUpdate() ;
  }

  cbDataFormats->Items->BeginUpdate() ;
  cbDataFormats->Items->Clear() ;
  cbDataFormats->Items->AddStrings( wfs->DataFormats ) ;
  cbDataFormats->Items->EndUpdate() ;

  cbCRS->Items->BeginUpdate() ;
  cbCRS->Items->Clear() ;
  cbCRS->Items->EndUpdate() ;

  eXMin->Text = "" ;
  eXMax->Text = "" ;
  eYMin->Text = "" ;
  eYMax->Text = "" ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::btnOpenURLClick(TObject *Sender)
{
  TGIS_LayerWFS *lwfs ;

  lwfs = new TGIS_LayerWFS ;
  lwfs->Path = cbURL->Text ;
  frmMain->GIS->Add( lwfs ) ;
  frmMain->GIS->FullExtent() ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::cbBBoxFIlterClick(TObject *Sender)
{
  eXMin->Enabled   = cbBBoxFIlter->Checked ;
  eXMax->Enabled   = cbBBoxFIlter->Checked ;
  eYMin->Enabled   = cbBBoxFIlter->Checked ;
  eYMax->Enabled   = cbBBoxFIlter->Checked ;

  lblXMin->Enabled = cbBBoxFIlter->Checked ;
  lblXMax->Enabled = cbBBoxFIlter->Checked ;
  lblYMin->Enabled = cbBBoxFIlter->Checked ;
  lblYMax->Enabled = cbBBoxFIlter->Checked ;

  chkClipVisibleExtent->Enabled = cbBBoxFIlter->Checked ;
  chkClipVisibleExtentClick( this );
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::cbMaxFeaturesClick(TObject *Sender)
{
    seMaxFeatures->Enabled = cbMaxFeatures->Checked ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::cbStartIndexClick(TObject *Sender)
{
  seStartIndex->Enabled = cbStartIndex->Checked ;
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::chkClipVisibleExtentClick(TObject *Sender)
{
 TGIS_Extent ext ;

  if ( frmMain->GIS->IsEmpty ) return ;

  ext = getBBoxExtent( getSelectedFeature() ) ;

  if( !GisIsNoWorld( ext ) ){
    eXMin->Text = DotFloatToStr( ext.XMin ) ;
    eXMax->Text = DotFloatToStr( ext.XMax ) ;
    eYMin->Text = DotFloatToStr( ext.YMin ) ;
    eYMax->Text = DotFloatToStr( ext.YMax ) ;
  }
  else{
    eXMin->Text = "" ;
    eXMax->Text = "" ;
    eYMin->Text = "" ;
    eYMax->Text = "" ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::FormDestroy(TObject *Sender)
{
  if( wfs != NULL ){
    delete wfs ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::FormShow(TObject *Sender)
{
  if( wfs == NULL ){
    wfs = new TGIS_FileWFS( NULL, NULL ) ;
  }
}
//---------------------------------------------------------------------------

TGIS_Extent __fastcall TfrmWFS::getBBoxExtent( const TGIS_WFSFeature * _fea ){
  TGIS_CSCoordinateSystem *lcs ;
  TGIS_CSCoordinateSystem *wgs  ;
  TGIS_Extent Result ;

  Result = GisNoWorld() ;

  if( _fea == NULL ){
   return Result ;
  }

  try{
    if( cbCRS->ItemIndex > -1 ){
      lcs = TGIS_CSFactory::ByWKT( cbCRS->Text ) ;
    }else{
      lcs = TGIS_CSFactory::ByWKT( _fea->DefaultSRS ) ;
    }
  }
  catch(Exception& e){
    lcs = CSUnknownCoordinateSystem() ;
  }

  if( !chkClipVisibleExtent->Checked ){
    wgs = TGIS_CSFactory::ByEPSG( GIS_EPSG_WGS84 ) ;

    if ( !( lcs->InheritsFrom(__classid(TGIS_CSUnknownCoordinateSystem)))){
      Result = lcs->ExtentFromCS( wgs, _fea->WGS84BBox ) ;
      if( lcs->Error != 0 ){
        Result = GisNoWorld() ;
      }
    }
  }
  else {
    wgs = frmMain->GIS->CS ;

    if ( !lcs->InheritsFrom(__classid( TGIS_CSUnknownCoordinateSystem ) ) ){
      Result = lcs->ExtentFromCS( wgs, frmMain->GIS->UnrotatedExtent( frmMain->GIS->VisibleExtent ) ) ;
      if( lcs->Error != 0 ){
        Result = GisNoWorld() ;
      }
    }
  }

  return Result ;
}

TGIS_WFSFeature * __fastcall TfrmWFS::getSelectedFeature(){
  TGIS_WFSFeature * Result ;

  if( ( tvLayers->Selected != NULL) && ( tvLayers->Selected->Level > 0 ) ){
    Result = ( TGIS_WFSFeature *)(tvLayers->Selected->Data);
  }
  else{
    Result = NULL ;
  }
  return Result ;
}
void __fastcall TfrmWFS::Locateonmap1Click(TObject *Sender)
{
  TGIS_WFSFeature *fea ;

  fea = getSelectedFeature() ;
  if( fea != NULL ){
    frmMain->GIS->VisibleExtent = fea->WGS84BBox ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::OpenMetadata1Click(TObject *Sender)
{
  TGIS_WFSFeature *fea ;

  fea = getSelectedFeature() ;
  if( fea != NULL){
    ShellExecute( 0, L"open", fea->MetadataUrl.c_str() , NULL, NULL, 0 ) ;
  }
}
//---------------------------------------------------------------------------

void __fastcall TfrmWFS::tvLayersChange(TObject *Sender, TTreeNode *Node)
{
  TGIS_WFSFeature *fea ;
  TGIS_Extent ext ;
  String str ;

  if (( Node != NULL) && ( Node->Level > 0 )) {
    fea = ( TGIS_WFSFeature *)(Node->Data) ;
    memLayerInfo->Lines->BeginUpdate() ;
    memLayerInfo->Clear() ;
    memLayerInfo->Lines->Add( "Name : " + fea->Name ) ;
    memLayerInfo->Lines->Add( "Title : "+ fea->Title ) ;
    if( fea->Description != "" ){
      memLayerInfo->Lines->Add( "Description : " + fea->Description ) ;
    }
    if( fea->Keywords != "" ){
      memLayerInfo->Lines->Add( "Keywords : "  + fea->Keywords ) ;
    }
    memLayerInfo->Lines->Add( "Default SRS : "  + fea->DefaultSRS ) ;
    memLayerInfo->Lines->Add( "WGS84 Bounding Box : " ) ;
    memLayerInfo->Lines->Add( str.sprintf(L" %f, %f, %f, %f",
                                   fea->WGS84BBox.XMin, fea->WGS84BBox.YMin,
                                    fea->WGS84BBox.XMax, fea->WGS84BBox.YMax ) ) ;
    memLayerInfo->Lines->EndUpdate() ;

    ext = getBBoxExtent( fea ) ;

    if (!GisIsNoWorld( ext ) ){
      eXMin->Text = DotFloatToStr( ext.XMin ) ;
      eXMax->Text = DotFloatToStr( ext.XMax ) ;
      eYMin->Text = DotFloatToStr( ext.YMin ) ;
      eYMax->Text = DotFloatToStr( ext.YMax ) ;
    }
    else{
      eXMin->Text = "" ;
      eXMax->Text = "" ;
      eYMin->Text = "" ;
      eYMax->Text = "" ;
    }
    cbCRS->Text = "" ;
    cbCRS->Items->BeginUpdate() ;
    cbCRS->Items->Clear() ;
    cbCRS->Items->Add( fea->DefaultSRS ) ;
    cbCRS->Items->AddStrings( fea->OtherSRS ) ;
    cbCRS->Items->EndUpdate() ;
  }
  else{
    memLayerInfo->Lines->BeginUpdate() ;
    memLayerInfo->Clear() ;
    memLayerInfo->Lines->AddStrings( wfs->ServiceInfo ) ;
    memLayerInfo->Lines->EndUpdate() ;
  }
}

//---------------------------------------------------------------------------

