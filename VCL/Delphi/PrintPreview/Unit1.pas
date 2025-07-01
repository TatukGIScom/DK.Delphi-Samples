//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
   How to use PrintPreview controls
}
unit Unit1;

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Winapi.Windows,

  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Printers,
  Vcl.Forms,

  //GisLicense,
  GisControlPrintPreviewSimple,
  GisRendererAbstract,
  GisEditor,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisPrinters,
  Vcl.GisControlLegend,
  Vcl.GisControlPrintPreview,
  Vcl.GisPrintManager,
  Vcl.GisViewerWnd;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    GIS_ControlLegend1: TGIS_ControlLegend;
    ToolBar1: TToolBar;
    Button1: TButton;
    Button2: TButton;
    lbPrintTitle: TLabel;
    lbPrintSubtitle: TLabel;
    edPrintTitle: TEdit;
    edPrintSubTitle: TEdit;
    btTitleFont: TButton;
    btSubTitleFont: TButton;
    dlgFontT: TFontDialog;
    dlgFontST: TFontDialog;
    chkStandardPrint: TCheckBox;
    GIS_ControlPrintPreview1: TGIS_ControlPrintPreview;
    GIS_ControlPrintPreviewSimple1: TGIS_ControlPrintPreviewSimple;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GISPrintPage(_sender: TObject;
      _printManager: TGIS_PrintManager; var _lastpage: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure btTitleFontClick(Sender: TObject);
    procedure dlgFontTApply(Sender: TObject; Wnd: HWND);
    procedure btSubTitleFontClick(Sender: TObject);
    procedure dlgFontSTApply(Sender: TObject; Wnd: HWND);
    procedure edPrintTitleChange(Sender: TObject);
    procedure edPrintSubTitleChange(Sender: TObject);
    procedure chkStandardPrintClick(Sender: TObject);
  private
    { Private declarations }
    printManager : TGIS_PrintManager ;
  private
    function to_native_color    ( _cl : TGIS_Color      ) : TColor ;
    function to_gis_color       ( _cl : TColor          ) : TGIS_Color ;
    function to_native_fontstyle( _st : TGIS_FontStyles ) : TFontStyles ;
    function to_gis_fontstyle   ( _st : TFontStyles     ) : TGIS_FontStyles ;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  VCL.GisFramework,
  GisAllLayers ;

{$R *.DFM}


procedure TForm1.Button1Click(Sender: TObject);
begin
  GIS_ControlPrintPreview1.Preview( 1, printManager ) ;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  GIS_ControlPrintPreviewSimple1.Preview( printManager ) ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;

  printManager := TGIS_PrintManager.Create ;
  printManager.Title := edPrintTitle.Text;
  printManager.Subtitle := edPrintSubTitle.Text;
  printManager.Footer := 'Footer';

  printManager.TitleFont.Name := 'Arial' ;
  printManager.TitleFont.Size := 36 ;
  printManager.TitleFont.Style := [TGIS_FontStyle.Bold];
  printManager.TitleFont.Color := TGIS_Color.Black ;

  printManager.SubtitleFont.Name := 'Arial';
  printManager.SubtitleFont.Size := 14;
  printManager.SubtitleFont.Style := [TGIS_FontStyle.Italic];
  printManager.SubtitleFont.Color := TGIS_Color.Black ;

  printManager.FooterFont.Name := 'Arial';
  printManager.FooterFont.Size := 8;
  printManager.FooterFont.Style := [];
  printManager.FooterFont.Color := TGIS_Color.Black ;

  printManager.PrintPageEvent := self.GISPrintPage;
  GIS_ControlPrintPreview1.Preview( 1, printManager ) ;
end;

function TForm1.to_native_color(
  _cl : TGIS_Color
) : TColor ;
begin
  Result := VCLColor( _cl ) ;
end ;

function TForm1.to_gis_color(
  _cl : TColor
) : TGIS_Color ;
begin
   Result := GisColor( _cl ) ;
end ;

function TForm1.to_native_fontstyle(
  _st : TGIS_FontStyles
) : TFontStyles ;
begin
  Result := [];
  if TGIS_FontStyle.Bold in _st then
    Result := Result + [TFontStyle.fsBold];
  if TGIS_FontStyle.Italic in _st then
    Result := Result + [TFontStyle.fsItalic];
  if TGIS_FontStyle.StrikeOut in _st then
    Result := Result + [TFontStyle.fsStrikeout];
  if TGIS_FontStyle.Underline in _st then
    Result := Result + [TFontStyle.fsUnderline];
end ;

function TForm1.to_gis_fontstyle(
  _st : TFontStyles
) : TGIS_FontStyles ;
begin
  Result := [];
  if TFontStyle.fsBold in _st then
    Result := Result + [TGIS_FontStyle.Bold];
  if TFontStyle.fsItalic in _st then
    Result := Result + [TGIS_FontStyle.Italic];
  if TFontStyle.fsStrikeOut in _st then
    Result := Result + [TGIS_FontStyle.Strikeout];
  if TFontStyle.fsUnderline in _st then
    Result := Result + [TGIS_FontStyle.Underline];
end ;

procedure TForm1.GISPrintPage(
  _sender : TObject;
  _printManager : TGIS_PrintManager ;
  var _lastpage : Boolean
) ;
var
  pm : TGIS_PrintManager ;
  pr : TGIS_Printer ;
  rnd : TGIS_RendererAbstract ;
  scale : Double ;
  r  : TRect ;
  fr : TRect ;
  mr : TRect ;
  h: Integer ;
  h_margin: Integer ;
  w: Integer ;
  x: Integer ;
  c: Integer ;
  txt : String ;

  function inch( const _value : Double ) : Integer ;
  begin
    Result := Round( _value * rnd.PPI ) ;
  end ;

begin
  pm := _printManager ;
  pr := pm.Printer ;

  rnd := pr.Renderer ;

  // left panel
  r.Left   := inch( 0.2 ) ;
  r.Top    := inch( 0.5 ) ;
  r.Right  := pr.PageWidth  ;
  r.Bottom := pr.PageHeight ;

  // left panel: gray rectangle
  r.Right := r.Right  - pr.TwipsToX( 2*1440 ) - inch( 0.2 ) ;
  rnd.CanvasBrush.Color := TGIS_Color.Gray ;
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Clear ;
  rnd.CanvasDrawRectangle( r );

  // left panel: white rectangle
  r.Left   := r.Left   - inch( 0.1 ) ;
  r.Top    := r.Top    - inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  rnd.CanvasBrush.Color  := TGIS_Color.White ;
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Clear ;
  rnd.CanvasDrawRectangle( r );
  fr := r ;

  // left panel: map
  r.Left   := r.Left   + inch( 0.1 ) ;
  r.Top    := r.Top    + inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  scale := 0 ;
  // 'scale' returned by the function is the real map scale used during printing.
  // It should be passed to the following DrawControl methods.
  // If legend or scale controls have to be printed before map (for some reason)
  // use the following frame:
  //    scale := 0 ;
  //    pm.GetDrawingParams( GIS, GIS.Extent, r, scale ) ; ...
  //    pm.DrawControl( GIS_ControlLegend1, r1, scale ) ;  ...
  //    pm.DrawMap( GIS, GIS.Extent, r, scale ) ;
  pm.DrawMap( GIS, GIS.Extent, r, scale ) ;
  mr := r ;

  // left panel: black frame
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Clear ;
  rnd.CanvasPen.Color := TGIS_Color.Black ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Solid ;
  rnd.CanvasDrawRectangle( fr );

  // right panel
  r.Left   := 0 ;
  r.Top    := inch( 0.5 ) ;
  r.Right  := pr.PageWidth  ;
  r.Bottom := pr.PageHeight ;

  // right panel: gray rectangle
  r.Left := r.Right  - pr.TwipsToX( 2*1440 ) ;
  rnd.CanvasBrush.Color := TGIS_Color.Gray ;
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Clear ;
  rnd.CanvasDrawRectangle( r );

  // right panel: white rectangle
  r.Left   := r.Left   - inch( 0.1 ) ;
  r.Top    := r.Top    - inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  rnd.CanvasBrush.Color := TGIS_Color.White ;
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Clear ;
  rnd.CanvasDrawRectangle( r );
  fr := r ;

  // right panel: legend
  r.Left   := r.Left   + inch( 0.1 ) ;
  r.Top    := r.Top    + inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  pm.DrawControl( GIS_ControlLegend1, r, scale ) ;

   // right panel: black frame
  rnd.CanvasBrush.Style := TGIS_BrushStyle.Clear ;
  rnd.CanvasPen.Color := TGIS_Color.Black ;
  rnd.CanvasPen.Style := TGIS_PenStyle.Solid ;
  rnd.CanvasDrawRectangle( fr );

  r := mr ;
  // page number
  rnd.CanvasBrush.Color := TGIS_Color.White ;
  rnd.CanvasFont.Name := 'Arial' ;
  rnd.CanvasFont.Size := 12 ;
  rnd.CanvasFont.Color := TGIS_Color.Black ;
  txt := Format('Page %d', [pr.PageNumber] ) ;
  h := rnd.CanvasTextExtent( txt ).Y ;
  w := rnd.CanvasTextExtent( txt ).X;
  x := r.Left ;
  rnd.CanvasDrawText( Rect( x,     r.Bottom - h ,
                            x + w, r.Bottom
                          ),
                      Format('Page %d', [pr.PageNumber] )
                    );

  // title
  rnd.CanvasFont.Name := pm.TitleFont.Name;
  rnd.CanvasFont.Size := pm.TitleFont.Size;
  rnd.CanvasFont.Style := pm.TitleFont.Style ;
  rnd.CanvasFont.Color := pm.TitleFont.Color ;
  h := rnd.CanvasTextExtent( pm.Title ).Y ;
  w := rnd.CanvasTextExtent( pm.Title ).X;
  x := ( r.Left + r.Right - w) div 2;
  rnd.CanvasDrawText( Rect( x    , pr.TwipsToY( 720 ),
                            x + w, pr.TwipsToY( 720 )+h
                          ),
                      pm.Title
                    );
  h_margin := h ;

  // subtitle
  rnd.CanvasFont.Name := pm.SubtitleFont.Name;
  rnd.CanvasFont.Size := pm.SubtitleFont.Size;
  rnd.CanvasFont.Style := pm.SubtitleFont.Style ;
  rnd.CanvasFont.Color := pm.SubtitleFont.Color ;
  h := rnd.CanvasTextExtent( pm.SubTitle ).Y ;
  w := rnd.CanvasTextExtent( pm.SubTitle ).X;
  x := ( r.Left + r.Right - w) div 2;
  rnd.CanvasDrawText( Rect( x    , pr.TwipsToY( 720 ) + h_margin,
                            x + w, pr.TwipsToY( 720 ) + h_margin + h
                          ),
                      pm.SubTitle
                    );

  _lastpage := True ;
end;


procedure TForm1.btTitleFontClick(Sender: TObject);
begin
  dlgFontT.Font.Name := printManager.TitleFont.Name;
  dlgFontT.Font.Size := printManager.TitleFont.Size;
  dlgFontT.Font.Style := to_native_fontstyle( printManager.TitleFont.Style ) ;
  dlgFontT.Font.Color := to_native_color( printManager.TitleFont.Color ) ;
  if not dlgFontT.Execute then exit;
  printManager.TitleFont.Name := dlgFontT.Font.Name ;
  printManager.TitleFont.Size := dlgFontT.Font.Size ;
  printManager.TitleFont.Style := to_gis_fontstyle( dlgFontT.Font.Style ) ;
  printManager.TitleFont.Color := to_gis_color( dlgFontT.Font.Color ) ;
end;

procedure TForm1.btSubTitleFontClick(Sender: TObject);
begin
  dlgFontST.Font.Name := printManager.SubtitleFont.Name;
  dlgFontST.Font.Size := printManager.SubtitleFont.Size;
  dlgFontST.Font.Style := to_native_fontstyle( printManager.SubtitleFont.Style ) ;
  dlgFontST.Font.Color := to_native_color( printManager.SubtitleFont.Color ) ;
  if not dlgFontST.Execute then exit;
  printManager.SubtitleFont.Name := dlgFontST.Font.Name ;
  printManager.SubtitleFont.Size := dlgFontST.Font.Size ;
  printManager.SubtitleFont.Style := to_gis_fontstyle( dlgFontST.Font.Style ) ;
  printManager.SubtitleFont.Color := to_gis_color( dlgFontST.Font.Color ) ;
end;

procedure TForm1.dlgFontTApply(Sender: TObject; Wnd: HWND);
begin
  printManager.TitleFont.Name := dlgFontT.Font.Name ;
  printManager.TitleFont.Size := dlgFontT.Font.Size ;
  printManager.TitleFont.Style := to_gis_fontstyle( dlgFontT.Font.Style ) ;
  printManager.TitleFont.Color := to_gis_color( dlgFontT.Font.Color ) ;
  GIS_ControlPrintPreview1.Preview( 1, printManager ) ;
end;

procedure TForm1.dlgFontSTApply(Sender: TObject; Wnd: HWND);
begin
  printManager.SubtitleFont.Name := dlgFontST.Font.Name ;
  printManager.SubtitleFont.Size := dlgFontST.Font.Size ;
  printManager.SubtitleFont.Style := to_gis_fontstyle( dlgFontST.Font.Style ) ;
  printManager.SubtitleFont.Color := to_gis_color( dlgFontST.Font.Color ) ;
  GIS_ControlPrintPreview1.Preview( 1, printManager ) ;
end;

procedure TForm1.edPrintTitleChange(Sender: TObject);
begin
  printManager.Title := edPrintTitle.Text;
end;

procedure TForm1.edPrintSubTitleChange(Sender: TObject);
begin
  printManager.SubTitle := edPrintSubTitle.Text;
end;

procedure TForm1.chkStandardPrintClick(Sender: TObject);
begin
  if chkStandardPrint.Checked
  then printManager.PrintPageEvent := nil
  else printManager.PrintPageEvent := self.GISPrintPage;

  GIS_ControlPrintPreview1.Preview( 1, printManager ) ;
end;

end.

