//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to perform filter operation.
}
unit Unit1;

interface

uses

  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisTypes,
  GisEditor,
  GisLayerSHP,
  GisUtils,
  GisTypesUI,
  GisPixelFilter,
  GisViewer,
  GisLayerPixel,
  GisLayerADF,
  GisLayer,

  Vcl.GisViewerWnd, VCL.GisControlLegend;

type
  TForm1 = class(TForm)
    cbStructure: TComboBox;
    Label1: TLabel;
    lblStructuring: TLabel;
    btnExecute: TButton;
    GIS: TGIS_ViewerWnd;
    cbMask: TComboBox;
    sbMaskSize: TScrollBar;
    lblMaskSizeValue: TLabel;
    lblMaskSize: TLabel;
    lblMask: TLabel;
    GIS_Legend: TGIS_ControlLegend;
    pbProgress: TProgressBar;
    lbFilter: TListBox;
    btnReset: TButton;
    procedure open ;
    procedure sbMaskSizeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure onFilterChange(Sender: TObject);
    procedure doBusyEvent(
          _sender : TObject ;
          _pos    : Integer ;
          _end    : Integer ;
      var _abort  : Boolean
    ) ;
    procedure btnResetClick(Sender: TObject);
  private
    bFirst : Boolean ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  GisRegistredLayers ;

procedure TForm1.btnExecuteClick(Sender: TObject);
var
  fltr  : TGIS_PixelFilterAbstract               ;
  input : TGIS_LayerPixel                        ;
  output: TGIS_LayerPixel                        ;
  mask  : TGIS_PixelFilterMaskType               ;
  struct: TGIS_PixelFilterStructuringElementType ;
  block : Integer                                ;
begin
  input := GIS.Items[0] as TGIS_LayerPixel ;

  if bFirst then begin
    output := TGIS_LayerPixel.Create ;
    output.Name := 'Result' ;
    output.Build( True, input.CS, input.Extent, input.BitWidth, input.BitHeight );
    output.Open ;
  end
  else
    output := input ;

  block := sbMaskSize.Position * 2 + 1 ;

  try
    case lbFilter.ItemIndex of
      0  :  begin
              fltr := TGIS_PixelFilterThreshold.Create ;
              TGIS_PixelFilterThreshold( fltr ).Threshold := ( input.MinHeight + input.MaxHeight ) * 0.3 ;
            end ;
      1  :  begin
              fltr := TGIS_PixelFilterNoiseSaltPepper.Create ;
              TGIS_PixelFilterNoiseSaltPepper( fltr ).Amount := 10 ;
            end;
      2  :  begin
              fltr := TGIS_PixelFilterNoiseGaussian.Create ;
              TGIS_PixelFilterNoiseGaussian( fltr ).Amount := 10 ;
            end;
      3  :  begin
              fltr := TGIS_PixelFilterConvolution.Create ;
              case cbMask.ItemIndex of
                0  :
                  mask := TGIS_PixelFilterMaskType.LowPass3x3 ;
                1  :
                  mask := TGIS_PixelFilterMaskType.LowPass5x5 ;
                2  :
                  mask := TGIS_PixelFilterMaskType.LowPass7x7 ;
                3  :
                  mask := TGIS_PixelFilterMaskType.HighPass3x3 ;
                4  :
                  mask := TGIS_PixelFilterMaskType.HighPass5x5 ;
                5  :
                  mask := TGIS_PixelFilterMaskType.HighPass7x7 ;
                6  :
                  mask := TGIS_PixelFilterMaskType.Gaussian3x3 ;
                7  :
                  mask := TGIS_PixelFilterMaskType.Gaussian5x5 ;
                8  :
                  mask := TGIS_PixelFilterMaskType.Gaussian7x7 ;
                9  :
                  mask := TGIS_PixelFilterMaskType.Laplacian3x3 ;
                10 :
                  mask := TGIS_PixelFilterMaskType.Laplacian5x5 ;
                11 :
                  mask := TGIS_PixelFilterMaskType.GradientNorth ;
                12 :
                  mask := TGIS_PixelFilterMaskType.GradientEast ;
                13 :
                  mask := TGIS_PixelFilterMaskType.GradientSouth ;
                14 :
                  mask := TGIS_PixelFilterMaskType.GradientWest ;
                15 :
                  mask := TGIS_PixelFilterMaskType.GradientNorthwest ;
                16 :
                  mask := TGIS_PixelFilterMaskType.GradientNortheast ;
                17 :
                  mask := TGIS_PixelFilterMaskType.GradientSouthwest ;
                18 :
                  mask := TGIS_PixelFilterMaskType.GradientSoutheast ;
                19 :
                  mask := TGIS_PixelFilterMaskType.PointDetector ;
                20 :
                  mask := TGIS_PixelFilterMaskType.LineDetectorHorizontal ;
                21 :
                  mask := TGIS_PixelFilterMaskType.LineDetectorVertical ;
                22 :
                  mask := TGIS_PixelFilterMaskType.LineDetectorLeftDiagonal ;
                23 :
                  mask := TGIS_PixelFilterMaskType.LineDetectorHorizontal ;
              end;
              TGIS_PixelFilterConvolution( fltr ).MaskType := mask ;
            end;
      4  :  begin
              fltr := TGIS_PixelFilterSobelMagnitude.Create ;
              TGIS_PixelFilterSobelMagnitude( fltr ).BlockSize := block ;
            end;
      5  :  begin
              fltr := TGIS_PixelFilterRange.Create ;
              TGIS_PixelFilterRange( fltr ).BlockSize := block ;
            end;
      6  :  begin
              fltr := TGIS_PixelFilterMidpoint.Create ;
              TGIS_PixelFilterMidpoint( fltr ).BlockSize := block ;
            end;
      7  :  begin
              fltr := TGIS_PixelFilterMinimum.Create ;
              TGIS_PixelFilterMinimum( fltr ).BlockSize := block ;
            end;
      8  :  begin
              fltr := TGIS_PixelFilterMaximum.Create ;
              TGIS_PixelFilterMaximum( fltr ).BlockSize := block ;
            end;
      9  :  begin
              fltr := TGIS_PixelFilterArithmeticMean.Create ;
              TGIS_PixelFilterArithmeticMean( fltr ).BlockSize := block ;
            end;
      10 :  begin
              fltr := TGIS_PixelFilterAlphaTrimmedMean.Create ;
              TGIS_PixelFilterAlphaTrimmedMean( fltr ).BlockSize := block ;
            end;
      11 :  begin
              fltr := TGIS_PixelFilterContraHarmonicMean.Create ;
              TGIS_PixelFilterContraHarmonicMean( fltr ).BlockSize := block ;
            end;
      12 :  begin
              fltr := TGIS_PixelFilterGeometricMean.Create ;
              TGIS_PixelFilterGeometricMean( fltr ).BlockSize := block ;
            end;
      13 :  begin
              fltr := TGIS_PixelFilterHarmonicMean.Create ;
              TGIS_PixelFilterHarmonicMean( fltr ).BlockSize := block ;
            end;
      14 :  begin
              fltr := TGIS_PixelFilterWeightedMean.Create ;
              TGIS_PixelFilterWeightedMean( fltr ).BlockSize := block ;
            end;
      15 :  begin
              fltr := TGIS_PixelFilterYpMean.Create ;
              TGIS_PixelFilterYpMean( fltr ).BlockSize := block ;
            end;
      16 :  begin
              fltr := TGIS_PixelFilterMajority.Create ;
              TGIS_PixelFilterMajority( fltr ).BlockSize := block ;
            end;
      17 :  begin
              fltr := TGIS_PixelFilterMinority.Create ;
              TGIS_PixelFilterMinority( fltr ).BlockSize := block ;
            end;
      18 :  begin
              fltr := TGIS_PixelFilterMedian.Create ;
              TGIS_PixelFilterMedian( fltr ).BlockSize := block ;
            end;
      19 :  begin
              fltr := TGIS_PixelFilterWeightedMedian.Create ;
              TGIS_PixelFilterWeightedMedian( fltr ).BlockSize := block ;
            end;
      20 :  begin
              fltr := TGIS_PixelFilterSum.Create ;
              TGIS_PixelFilterSum( fltr ).BlockSize := block ;
            end;
      21 :  begin
              fltr := TGIS_PixelFilterStandardDeviation.Create ;
              TGIS_PixelFilterStandardDeviation( fltr ).BlockSize := block ;
            end;
      22 :  begin
              fltr := TGIS_PixelFilterUniqueCount.Create ;
              TGIS_PixelFilterUniqueCount( fltr ).BlockSize := block ;
            end;
      23 :  begin
              fltr := TGIS_PixelFilterErosion.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterErosion( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterErosion( fltr ).BlockSize := block ;
            end;
      24 :  begin
              fltr := TGIS_PixelFilterDilation.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterDilation( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterDilation( fltr ).BlockSize := block ;
            end;
      25 :  begin
              fltr := TGIS_PixelFilterOpening.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterOpening( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterOpening( fltr ).BlockSize := block ;
            end;
      26 :  begin
              fltr := TGIS_PixelFilterClosing.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterClosing( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterClosing( fltr ).BlockSize := block ;
            end;
      27 :  begin
              fltr := TGIS_PixelFilterTopHat.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterTopHat( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterTopHat( fltr ).BlockSize := block ;
            end;
      28 :  begin
              fltr := TGIS_PixelFilterBottomHat.Create ;
              case cbStructure.ItemIndex of
                0 :
                  struct := TGIS_PixelFilterStructuringElementType.Square             ;
                1 :
                  struct := TGIS_PixelFilterStructuringElementType.Diamond            ;
                2 :
                  struct := TGIS_PixelFilterStructuringElementType.Disk               ;
                3 :
                  struct := TGIS_PixelFilterStructuringElementType.LineHorizontal     ;
                4 :
                  struct := TGIS_PixelFilterStructuringElementType.LineVertical       ;
                5 :
                  struct := TGIS_PixelFilterStructuringElementType.LineLeftDiagonal   ;
                6 :
                  struct := TGIS_PixelFilterStructuringElementType.LineRightDiagonal  ;
              end;
              TGIS_PixelFilterBottomHat( fltr ).StructuringElementType := struct ;
              TGIS_PixelFilterBottomHat( fltr ).BlockSize := block ;
            end;
    end;

    fltr.SourceLayer := input ;
    fltr.DestinationLayer := output ;
    fltr.Band := 1 ;
    fltr.ColorSpace := TGIS_PixelFilterColorSpace.HSL ;
    fltr.BusyEvent := doBusyEvent;
    fltr.Execute ;
  finally
    fltr.Free ;
  end;

  output.Params.Pixel.GridShadow := False ;
  output.ApplyAntialiasSettings( True ) ;

  if bFirst then begin
    GIS.Delete( input.Name );
    GIS.Add( output ) ;
    bFirst := False ;
  end ;
  GIS.InvalidateWholeMap ;

end;

procedure TForm1.btnResetClick(Sender: TObject);
begin
  open ;
end;

procedure TForm1.doBusyEvent(_sender: TObject; _pos: Integer; _end: Integer; var _abort: Boolean);
begin
  case _pos of
    // initialize progress bar
    0  : begin
      pbProgress.Min := 0 ;
      pbProgress.Max := 100 ;
      pbProgress.Position := 0 ;
    end ;
    // end of progress - reset progress bar
    -1 : pbProgress.Position := 0 ;
  else
    pbProgress.Position := _pos ;
  end ;
end ;


procedure TForm1.onFilterChange(Sender: TObject);
begin
  if ( lbFilter.ItemIndex = 0 ) or
     ( lbFilter.ItemIndex = 1 ) or
     ( lbFilter.ItemIndex = 2 ) then begin
     cbStructure.Visible      := False ;
     lblStructuring.Visible   := False ;
     lblMask.Visible          := False ;
     cbMask.Visible           := False ;
     lblMaskSize.Visible      := False ;
     lblMaskSizeValue.Visible := False ;
     sbMaskSize.Visible       := False ;
  end
  else
  begin
    if ( lbFilter.ItemIndex = 23 ) or
     ( lbFilter.ItemIndex = 24 ) or
     ( lbFilter.ItemIndex = 25 ) or
     ( lbFilter.ItemIndex = 26 ) or
     ( lbFilter.ItemIndex = 27 ) or
     ( lbFilter.ItemIndex = 28 ) then
    begin
       cbStructure.Visible      := True  ;
       lblStructuring.Visible   := True  ;
       lblMask.Visible          := True  ;
       cbMask.Visible           := True  ;
       lblMaskSize.Visible      := True  ;
       lblMaskSizeValue.Visible := True  ;
       sbMaskSize.Visible       := True  ;
    end
    else
    begin
       cbStructure.Visible      := False ;
       lblStructuring.Visible   := False ;
       lblMask.Visible          := False ;
       cbMask.Visible           := False ;
       lblMaskSize.Visible      := False ;
       lblMaskSizeValue.Visible := False ;
       sbMaskSize.Visible       := False ;
    end ;

    if lbFilter.ItemIndex = 3 then begin
       cbMask.Visible           := True  ;
       lblMask.Visible          := True  ;
       lblMaskSize.Visible      := False ;
       lblMaskSizeValue.Visible := False ;
       sbMaskSize.Visible       := False ;
    end
    else
    begin
       cbMask.Visible           := False ;
       lblMask.Visible          := False ;
       lblMaskSize.Visible      := True  ;
       lblMaskSizeValue.Visible := True  ;
       sbMaskSize.Visible       := True  ;
    end ;
  end ;


end;

procedure TForm1.open;
var
  ll : TGIS_LayerPixel ;
begin
  GIS.Close ;
  ll := TGIS_LayerPixel(
    TGIS_Utils.GisCreateLayer( '', TGIS_Utils.GisSamplesDataDirDownload +
      'World\Countries\USA\States\California\San Bernardino\NED\w001001.adf' )
  ) ;
  ll.Open ;
  ll.Params.Pixel.AltitudeMapZones.Clear ;
  ll.Params.Pixel.GridShadow := False ;

  GIS.Add( ll );
  GIS.FullExtent ;

  bFirst := True ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lbFilter.ItemIndex := 0 ;
  cbStructure.ItemIndex := 0 ;
  cbMask.ItemIndex := 0 ;

  open ;
end;

procedure TForm1.sbMaskSizeChange(Sender: TObject);
var
  i : Integer ;
begin
  i := 2 * sbMaskSize.Position + 1 ;
  lblMaskSizeValue.Caption := IntToStr( i ) + 'x' + IntToStr( i ) ;
end;

end.
