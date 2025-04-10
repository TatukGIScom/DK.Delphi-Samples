//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================

//
//  How to use hydrology toolset.
//
//  Check project\options\directories in a case of any problems during compilation
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

//#include "GisLicense.hpp"
#include "Unit1.h"
#include "math.h"
#include "assert.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VCL.GisControlLegend"
#pragma resource "*.dfm"

TForm1 *Form1;



//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}

//---------------------------------------------------------------------------
void __fastcall TForm1::doBusyEvent(TObject *_sender, int _pos, int _end, bool &_abort)
{
  if (_pos < 0)
  {
	pbBusy->Position = 0 ;
  }
  else
  if (_pos == 0)
  {
	pbBusy->Min = 0 ;
	pbBusy->Max = 100 ;
	pbBusy->Position = 0 ;
  }
  else
  {
	pbBusy->Position = _pos ;
  }
  Application->ProcessMessages();
}
//---------------------------------------------------------------------------
// Creates a new grid layer based with the same parameters as input DEM and given name
TGIS_LayerPixel* __fastcall TForm1::CreateLayerPix(
  TGIS_LayerPixel* _dem,
  System::UnicodeString _name
)
{
  TGIS_LayerPixel* res = new TGIS_LayerPixel() ;
  res->Build( True, _dem->CS, _dem->Extent, _dem->BitWidth, _dem->BitHeight ) ;
  res->Name = _name;
  res->Params->Pixel->Antialias = False ;
  res->Params->Pixel->GridShadow = False ;
  return res;
};

// Creates a new vector layer with given name, cs and type
TGIS_LayerVector* __fastcall TForm1::CreateLayerVec(
  System::UnicodeString _name,
  TGIS_CSCoordinateSystem* _cs,
  TGIS_ShapeType _type
)
{
  TGIS_LayerVector* res = new TGIS_LayerVector() ;
  res->Name = _name;
  res->Open() ;
  res->CS = _cs ;
  res->DefaultShapeType = _type;
  return res;
};

// Gets a pixel layer with given name from GIS
TGIS_LayerPixel* __fastcall TForm1::GetLayerPix(
  System::UnicodeString _name
)
{
  return (TGIS_LayerPixel*) GIS->Get( _name ) ;
};

// Gets a vector layer given name from GIS
TGIS_LayerVector* __fastcall TForm1::GetLayerVec(
  System::UnicodeString _name
)
{
  return (TGIS_LayerVector* ) GIS->Get( _name )  ;
};
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
   hydrologyToolset->Free();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormShow(TObject *Sender)
{
  GIS->Mode = TGIS_ViewerMode::Zoom ;
  GIS->RestrictedDrag = False ;
  GIS->Open(
    TGIS_Utils::GisSamplesDataDirDownload() +
	"World\\Countries\\Poland\\DEM\\Bytowski_County.tif"
  ) ;

  dem = ((TGIS_LayerPixel* )GIS->Items->Items[0])  ;
  ext = dem->Extent ;

  dem->Params->Pixel->Antialias = False ;
  dem->Params->Pixel->GridShadow = False ;
  GIS->InvalidateWholeMap() ;

  hydrologyToolset = new TGIS_Hydrology() ;
  hydrologyToolset->BusyEvent = doBusyEvent ;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnSinkClick(TObject *Sender)
{
  btnSink->Enabled= False;

  // creating a pixel layer for a grid with sinks
  TGIS_LayerPixel* sinks = CreateLayerPix( dem, HYDRO_LAYER_SINK ) ;

  // Sink algorithm needs only grid layer with DEM
  hydrologyToolset->Sink( dem, ext, sinks ) ;

  GIS->Add( sinks ) ;

  // coloring pixels with sinks (pits) or flats
  String mn = DotFloatToStr( sinks->MinHeight ) ;
  String mx = DotFloatToStr( sinks->MaxHeight ) ;
  sinks->Params->Pixel->AltitudeMapZones->Add(
	Format( "%s,%s,165:15:21:255,%s-%s", OPENARRAY(TVarRec, (mn, mx, mn, mx) ) )
  ) ;
  GIS->InvalidateWholeMap() ;

  btnFillSinks->Enabled= True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFillSinksClick(TObject *Sender)
{
  btnFillSinks->Enabled = False ;

  // turning off layers
  dem->Active= False ;
  GetLayerPix( HYDRO_LAYER_SINK )->Active = False ;

  // creating a pixel layer for a hydrologically conditioned DEM
  TGIS_LayerPixel* hydro_dem = CreateLayerPix( dem, HYDRO_LAYER_DEM ) ;

  // Fill algorithm needs grid layer with DEM
  hydrologyToolset->Fill( dem, ext, hydro_dem ) ;

  GIS->Add( hydro_dem ) ;

  // applying layer symbology
  TGIS_GradientMap* color_ramp = TGIS_Utils::GisColorRampList->ByName( "YellowGreen" ) ;
  TGIS_ColorMapArray color_map = color_ramp->RealizeColorMap( TGIS_ColorMapMode::Continuous, 0, True ) ;
  hydro_dem->GenerateRampEx( hydro_dem->MinHeight, hydro_dem->MaxHeight, color_map, NULL ) ;
  hydro_dem->Params->Pixel->GridShadow = True ;
  hydro_dem->Params->Pixel->Antialias = True ;
  hydro_dem->Params->Pixel->ShowLegend = False ;

  GIS->InvalidateWholeMap() ;

  btnFlowDirection->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFlowDirectionClick(TObject *Sender)
{
  btnFlowDirection->Enabled = False ;

  TGIS_LayerPixel* hydro_dem = GetLayerPix( HYDRO_LAYER_DEM ) ;
  hydro_dem->Active = False ;

  // creating a pixel layer for a grid with coded flow directions
  TGIS_LayerPixel* flowdir = CreateLayerPix( dem, HYDRO_LAYER_DIRECTION ) ;

  // FlowDirection algorithm needs hydrologically conditioned DEM
  hydrologyToolset->FlowDirection( hydro_dem, ext, flowdir ) ;

  // applying a turbo color ramp for direction codes
  flowdir->Params->Pixel->AltitudeMapZones->Add( "1,1,48:18:59:255,1" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "2,2,71:117:237:255,2" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "4,4,29:206:214:255,4" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "8,8,98:252:108:255,8" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "16,16,210:232:53:255,16" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "32,32,254:154:45:255,32" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "64,64,217:56:6:255,64" ) ;
  flowdir->Params->Pixel->AltitudeMapZones->Add( "128,128,122:4:3:255,128" ) ;
  flowdir->Params->Pixel->ShowLegend = True ;

  GIS->Add( flowdir ) ;
  GIS->InvalidateWholeMap() ;

  btnFlowAccumulation->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnFlowAccumulationClick(TObject *Sender)
{
  btnFlowAccumulation->Enabled = False ;

  TGIS_LayerPixel* flowdir = GetLayerPix( HYDRO_LAYER_DIRECTION ) ;
  flowdir->Active = False ;

  // creating a pixel layer for a flow accumulation grid
  TGIS_LayerPixel* flowacc = CreateLayerPix( dem, HYDRO_LAYER_ACCUMULATION) ;

  // FlowAccumulation algorithm needs hydrologically conditioned DEM
  hydrologyToolset->FlowAccumulation( flowdir, ext, flowacc ) ;

  GIS->Add( flowacc ) ;

  // performing a geometric classification for better result visualization
  TGIS_ClassificationPixel* classifier = new TGIS_ClassificationPixel( flowacc ) ;
  try
  {
	classifier->Method = TGIS_ClassificationMethod::GeometricalInterval ;
	classifier->Band = "1" ;
	classifier->NumClasses = 5 ;
	classifier->ColorRamp = TGIS_Utils::GisColorRampList->ByName( "Bathymetry2" )
	  ->RealizeColorMap( TGIS_ColorMapMode::Continuous, 0, True ) ;

	if (classifier->MustCalculateStatistics())
	  flowacc->Statistics->Calculate() ;

	classifier->Classify() ;
	flowacc->Params->Pixel->ShowLegend = True ;
  }
  __finally
  {
	classifier->Free() ;
  }

  GIS->InvalidateWholeMap() ;

  btnAddOutlets->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnAddOutletsClick(TObject *Sender)
{
  btnAddOutlets->Enabled = False ;

  // creating a vector layer for outlets (pour points)
  TGIS_LayerVector* outlets = CreateLayerVec( HYDRO_LAYER_OUTLETS, dem->CS,TGIS_ShapeType::Point ) ;

  // adding point symbology
  outlets->Params->Marker->Style = TGIS_MarkerStyle::TriangleUp ;
  outlets->Params->Marker->SizeAsText = "SIZE:8pt" ;

  // adding two sample pour points
  // outlets should be located to cells of high accumulated flow
  TGIS_Shape* shp = outlets->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Projection ) ;
  shp->AddPart() ;
  shp->AddPoint( TGIS_Utils::GisPoint( 375007.548333318, 696503.13358447 ) );
  shp->Unlock() ;

  shp = outlets->CreateShape( TGIS_ShapeType::Point ) ;
  shp->Lock( TGIS_Lock::Projection ) ;
  shp->AddPart() ;
  shp->AddPoint( TGIS_Utils::GisPoint( 399612.055851588, 706196.55502031 ) );
  shp->Unlock() ;

  GIS->Add( outlets ) ;
  GIS->InvalidateWholeMap() ;

  btnWatershed->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnWatershedClick(TObject *Sender)
{
  btnWatershed->Enabled = False ;

  TGIS_LayerPixel* flowdir = GetLayerPix( HYDRO_LAYER_DIRECTION ) ;
  TGIS_LayerVector* outlets = GetLayerVec( HYDRO_LAYER_OUTLETS ) ;

  // creating a pixel layer for a watershed grid
  TGIS_LayerPixel* watershed = CreateLayerPix( dem, HYDRO_LAYER_WATERSHED ) ;

  // applying symbology
  watershed->Params->Pixel->AltitudeMapZones->Add( "1,1,62:138:86:255,1" ) ;
  watershed->Params->Pixel->AltitudeMapZones->Add( "2,2,108:3:174:255,2" ) ;
  watershed->Transparency = 50 ;

  watershed->Params->Pixel->ShowLegend = True ;

  // Watershed algorithm needs Flow Direction grid and outlets (may be vector, or grid)
  hydrologyToolset->Watershed( flowdir, outlets, GIS_FIELD_UID, ext, watershed ) ;

  GIS->Add( watershed ) ;
  GIS->InvalidateWholeMap() ;

  btnBasin->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnBasinClick(TObject *Sender)
{
  btnBasin->Enabled = False ;

  TGIS_LayerPixel* flowdir = GetLayerPix( HYDRO_LAYER_DIRECTION ) ;
  TGIS_LayerPixel* flowacc = GetLayerPix( HYDRO_LAYER_ACCUMULATION ) ;
  flowacc->Active = False ;
  GetLayerPix( HYDRO_LAYER_DEM )->Active = False ;
  GetLayerPix( HYDRO_LAYER_WATERSHED )->Active = False ;
  GetLayerVec( HYDRO_LAYER_OUTLETS )->Active = False ;

  // creating a pixel layer for a Basin grid
  TGIS_LayerPixel* basins = CreateLayerPix( dem, HYDRO_LAYER_BASIN ) ;

  // Basin algorithm only needs a Flow Direction grid
  hydrologyToolset->Basin( flowdir, ext, basins, round( flowacc->MaxHeight/100 ) ) ;

  GIS->Add( basins ) ;

  // classifying basin grid by unique values
  TGIS_ClassificationPixel* classifier = new TGIS_ClassificationPixel( basins ) ;
  try
  {
	classifier->Method = TGIS_ClassificationMethod::Unique ;
    classifier->Band = GIS_BAND_GRID ;
    classifier->ShowLegend = False ;

	if (classifier->MustCalculateStatistics())
	  basins->Statistics->Calculate() ;
	classifier->EstimateNumClasses() ;

	classifier->ColorRamp = TGIS_Utils::GisColorRampList->ByName( "UniquePastel" )
	  ->RealizeColorMap( TGIS_ColorMapMode::Discrete, classifier->NumClasses ) ;

	classifier->Classify() ;
  }
  __finally
  {
	classifier->Free() ;
  }

  GIS->InvalidateWholeMap() ;

  btnStreamOrderStrahler->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnStreamOrderStrahlerClick(TObject *Sender)
{
  btnStreamOrderStrahler->Enabled = False ;

  TGIS_LayerPixel* flowdir = GetLayerPix( HYDRO_LAYER_DIRECTION ) ;
  TGIS_LayerPixel* flowacc = GetLayerPix( HYDRO_LAYER_ACCUMULATION ) ;

  // creating a pixel layer for a grid with coded flow directions
  TGIS_LayerPixel* stream_order = CreateLayerPix( dem, HYDRO_LAYER_STREAM_ORDER ) ;

  // applying a symbology from "Blues" color ramp
  stream_order->Params->Pixel->AltitudeMapZones->Add( "1,1,78:179:211:255,1" ) ;
  stream_order->Params->Pixel->AltitudeMapZones->Add( "2,2,43:140:190:255,2" ) ;
  stream_order->Params->Pixel->AltitudeMapZones->Add( "3,3,8:104:172:255,3" ) ;
  stream_order->Params->Pixel->AltitudeMapZones->Add( "4,4,8:64:129:255,4" ) ;
  stream_order->Params->Pixel->ShowLegend = True ;

  // StreamOrder algorithm needs Flow Direction and Flow Accumulation grids
  hydrologyToolset->StreamOrder( flowdir, flowacc, ext, stream_order ) ;

  GIS->Add( stream_order ) ;
  GIS->InvalidateWholeMap() ;

  btnVectorize->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btnVectorizeClick(TObject *Sender)
{
  btnVectorize->Enabled = False ;

  TGIS_LayerPixel* flowdir = GetLayerPix( HYDRO_LAYER_DIRECTION ) ;
  TGIS_LayerPixel*streams = GetLayerPix( HYDRO_LAYER_STREAM_ORDER ) ;
  TGIS_LayerPixel*basins  = GetLayerPix( HYDRO_LAYER_BASIN ) ;

  streams->Active = False ;
  basins->Active = False ;

  // 1-> Converting basins to polygon

  // creating a vector polygon layer for basins
  TGIS_LayerVector* basins_vec= CreateLayerVec( HYDRO_LAYER_BASIN_VEC, dem->CS, TGIS_ShapeType::Polygon ) ;
  basins_vec->AddField( HYDRO_FIELD_BASIN, TGIS_FieldType::Number, 10, 0 ) ;

  // using GirdToPolygon vectorization tool
  TGIS_GridToPolygon* vectorizator = new TGIS_GridToPolygon() ;
  try
  {
    vectorizator->BusyEvent = doBusyEvent ;
	vectorizator->Generate( basins, basins_vec, HYDRO_FIELD_BASIN ) ;
  }
  __finally
  {
	vectorizator->Free() ;
  } ;

  GIS->Add( basins_vec ) ;

  // classifying a basins vector layer by unique value
  TGIS_ClassificationVector* classifier = new TGIS_ClassificationVector( basins_vec ) ;
  try
  {
	classifier->Method = TGIS_ClassificationMethod::Unique ;
	classifier->Field = HYDRO_FIELD_BASIN ;
	classifier->ShowLegend = False ;

	if (classifier->MustCalculateStatistics())
	  basins_vec->Statistics->Calculate() ;
	classifier->EstimateNumClasses() ;

	classifier->ColorRamp = TGIS_Utils::GisColorRampList->ByName( "Unique" )
	  ->RealizeColorMap( TGIS_ColorMapMode::Discrete, classifier->NumClasses ) ;
	classifier->Classify() ;
  }
  __finally
  {
	classifier->Free() ;
  } ;

  // 2-> Converting streams to polylines

  // creating a vector layer for streams from Stream Order grid
  TGIS_LayerVector* streams_vec = CreateLayerVec( HYDRO_LAYER_STREAM_VEC, dem->CS, TGIS_ShapeType::Arc ) ;
  streams_vec->AddField( HYDRO_FIELD_ORDER, TGIS_FieldType::Number, 10, 0 ) ;

  // applying symbology and width based on a stream order value and labeling
  streams_vec->Params->Line->WidthAsText = "RENDERER" ;
  streams_vec->Params->Line->ColorAsText = "ARGB:FF045A8D";
  streams_vec->Params->Render->Expression = HYDRO_FIELD_ORDER ;
  streams_vec->Params->Render->Zones = 4 ;
  streams_vec->Params->Render->MinVal= 1 ;
  streams_vec->Params->Render->MaxVal= 5 ;
  streams_vec->Params->Render->StartSizeAsText = "SIZE:1pt" ;
  streams_vec->Params->Render->EndSizeAsText = "SIZE:4pt" ;
  streams_vec->Params->Labels->Value = Format("{%s}", OPENARRAY(TVarRec, (HYDRO_FIELD_ORDER)) );
  streams_vec->Params->Labels->FontSizeAsText = "SIZE:7pt" ;
  streams_vec->Params->Labels->FontColorAsText = "ARGB:FF045A8D" ;
  streams_vec->Params->Labels->ColorAsText = "ARGB:FFBDC9E1" ;
  streams_vec->Params->Labels->Alignment = TGIS_LabelAlignment::Follow ;

  hydrologyToolset->StreamToPolyline( flowdir, streams, ext, streams_vec, HYDRO_FIELD_ORDER ) ;

  GIS->Add( streams_vec ) ;
  GIS->InvalidateWholeMap() ;

  btn3D->Enabled = True ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::btn3DClick(TObject *Sender)
{
  if (GIS->View3D)
  {
    btn3D->Caption = "View in 3D" ;
    GIS->View3D = False ;
  }
  else
  {
	btn3D->Caption = "View in 2D" ;

	TGIS_LayerVector* basins = GetLayerVec( HYDRO_LAYER_BASIN_VEC ) ;
	basins->Active = False ;

	TGIS_LayerPixel* hdem = GetLayerPix( HYDRO_LAYER_DEM ) ;
    hdem->Active = True ;
    hdem->Params->ScaleZ = 1 ;
	hdem->Params->NormalizedZ = TGIS_3DNormalizationType::Range ;

	TGIS_LayerVector* streams = GetLayerVec( HYDRO_LAYER_STREAM_VEC ) ;
    streams->Params->Labels->Visible = False ;
	streams->Layer3D = TGIS_3DLayerType::Off ;

	GIS->InvalidateWholeMap() ;

	GIS->View3D = True ;
    GIS->Viewer3D->ShowLights = True ;
	GIS->Viewer3D->ShadowsLevel = 40 ;
  } ;
}
//---------------------------------------------------------------------------

