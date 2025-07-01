//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to provide basic pixel support.
}

unit Unit1;

interface

uses
  System.Classes,
  System.Types,
  System.SysUtils,
  System.Variants,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ToolWin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,

  //GisLicense,
  GisEditor,
  GisLayerADF,
  GisLayerSHP,
  GisLayerVector,
  GisLayerJPG,
  GisLayerPixel,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    paTop: TPanel;
    gbOriginal: TGroupBox;
    gbChannels: TGroupBox;
    lbRGBValueC: TLabel;
    paColorC: TPanel;
    GroupBox1: TGroupBox;
    tbBrightness: TTrackBar;
    Memo1: TMemo;
    btnImage: TButton;
    btnGrid: TButton;
    procedure GISMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbBrightnessChange(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure btnGridClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.btnGridClick(Sender: TObject);
begin
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\Countries\USA\States\California\San Bernardino\NED\w001001.adf') ;
  tbBrightness.Enabled := false ;
  tbBrightness.Position := 0 ;
end;

procedure TForm1.btnImageClick(Sender: TObject);
begin
  GIS.Open(TGIS_Utils.GisSamplesDataDirDownload() + '\World\Countries\USA\States\California\San Bernardino\DOQ\37134877.jpg') ;
  tbBrightness.Enabled := true ;
  tbBrightness.Position := 0 ;
end;

procedure TForm1.GISMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ptg         : TGIS_Point ;
  ll          : TGIS_LayerPixel ;
  rgbMapped   : TGIS_Color ;
  nativesVals : TGIS_DoubleArray ;
  bT          : Boolean;
  i           : Integer;
begin
  if GIS.IsEmpty then exit ;

  if GIS.Mode <> TGIS_ViewerMode.Select then exit;
  ptg := GIS.ScreenToMap( Point(x, y ) );
  ll := TGIS_LayerPixel( GIS.Items[0] );
  if not Assigned(ll) then exit;
  if not GIS.InPaint then begin
  if ll.Locate( ptg, rgbMapped, nativesVals, bT) then
    begin
      paColorC.Color := RGB(rgbMapped.R,
                                   rgbMapped.G,
                                   rgbMapped.B);
      lbRGBValueC.Caption := Format( 'RGB :  %d , %d , %d ',
                                    [ rgbMapped.R, rgbMapped.G, rgbMapped.B ]
                                     );
      Memo1.Clear;
      for i:= 0 to (Length(nativesVals) - 1) do
        Memo1.Lines.Add( Format( 'CH%d =  %.0f', [ i, nativesVals[i] ] ) );
    end;
  end;
end;

procedure TForm1.tbBrightnessChange(Sender: TObject);
var
  ll : TGIS_LayerPixel ;
begin
  ll := TGIS_LayerPixel( GIS.Items.Items[0] );
  if not Assigned(ll) then exit;

  ll.Params.Pixel.Brightness := tbBrightness.Position;
  GIS.InvalidateWholeMap;
end;

end.
