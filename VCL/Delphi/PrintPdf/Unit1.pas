unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, VCL.GisViewerWnd, VCL.GisControlLegend,
  GisUtils, GisTypes, Vcl.StdCtrls, VCL.GisPrintManager, VCL.GisPrinters,
  GisRendererAbstract, GisTypesUI, VCL.GisControlScale, GisTemplatePrint;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ToolBar1: TToolBar;
    btnFullExtent: TToolButton;
    ToolButton1: TToolButton;
    btnZoom: TToolButton;
    btnDrag: TToolButton;
    ImageList1: TImageList;
    GISLegend: TGIS_ControlLegend;
    Splitter1: TSplitter;
    GIS: TGIS_ViewerWnd;
    RadioGroup1: TRadioGroup;
    PrintPdf: TButton;
    StatusBar1: TStatusBar;
    GISScale: TGIS_ControlScale;
    procedure btnFullExtentClick(Sender: TObject);
    procedure btnDragClick(Sender: TObject);
    procedure btnZoomClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PrintPdfClick(Sender: TObject);
    procedure BeforePrintPage
                       (    _sender       : TObject  ;
                            _printmanager : TGIS_PrintManager ;
                        var _lastpage     : Boolean
                       );
    procedure PrintPage(    _sender       : TObject  ;
                            _printmanager : TGIS_PrintManager ;
                        var _lastpage     : Boolean
                       );
  private
    { Private declarations }
  public
    { Public declarations }
    PdfFileName : String ;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnDragClick(Sender: TObject);
begin
  // set drag mode
  GIS.Mode := TGIS_ViewerMode.Drag ;
end;

procedure TForm1.btnFullExtentClick(Sender: TObject);
begin
  // show full map
  GIS.FullExtent ;
end;

procedure TForm1.btnZoomClick(Sender: TObject);
begin
  // set zoom mode
  GIS.Mode := TGIS_ViewerMode.Zoom ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // open a file
  GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\Countries\Poland\DCW\poland.ttkproject' ) ;
  PdfFileName := '';
end;

procedure TForm1.PrintPdfClick(Sender: TObject);
var
  dlg : TSaveDialog ;
  pm  : TGIS_PrintManager ;
  tp  : TGIS_TemplatePrint ;
begin
  dlg := TSaveDialog.Create(nil);
  try
    // choose a file
    dlg.Title := 'Select a file';
    dlg.DefaultExt := '.pdf';
    dlg.Filter := 'Pdf files (*.pdf)|*.pdf';
    dlg.Options := dlg.Options + [ofOverwritePrompt];
    if PdfFileName = '' then begin
      dlg.InitialDir := GetCurrentDir ;
      dlg.FileName := '';
    end
    else begin
      dlg.InitialDir := ExtractFilePath(PdfFileName);
      dlg.FileName := ExtractFileName(PdfFileName);
    end ;

    if not dlg.Execute then exit ;
    PdfFileName := dlg.FileName ;
    StatusBar1.SimpleText := PdfFileName;

    // all PrintPdf methods below
    // have its versions with a stream instead of file name
    if RadioGroup1.ItemIndex = 0 then begin
      // GIS.PrintPdf
      GIS.PrintPdf( PdfFileName,
                    210 * 72 / 25.4,
                    297 * 72 / 25.4
                  ) ;
    end
    else if RadioGroup1.ItemIndex = 1 then begin
      // standard print
      pm := TGIS_PrintManager.Create ;
      try
        pm.PrintPdf( GIS, PdfFileName,
                     210 * 72 / 25.4,
                     297 * 72 / 25.4
                   ) ;
      finally
        pm.Free ;
      end ;
    end
    else if RadioGroup1.ItemIndex = 2 then begin
      // template
      tp := TGIS_TemplatePrint.Create ;
      tp.TemplatePath := TGIS_Utils.GisSamplesDataDirDownload + 'Samples\PrintTemplate\printtemplate.tpl' ;
      tp.GIS_Viewer[ 1 ] := GIS ;
      tp.GIS_ViewerExtent[ 1 ] := GIS.VisibleExtent ;
      tp.GIS_ViewerScale[ 1 ]  := 0 ;
      tp.GIS_Scale[ 1 ] := GISScale ;
      tp.GIS_Legend[ 1 ] := GISLegend ;
      tp.Text[ 1 ] := 'Title Title' ;
      tp.Text[ 2 ] := 'Copyright' ;

      pm := TGIS_PrintManager.Create ;
      try
        pm.Template := tp ;
        pm.PrintPdf( GIS, PdfFileName,
                     210 * 72 / 25.4,
                     297 * 72 / 25.4
                   ) ;
      finally
        pm.Free ;
      end ;
    end
    else if RadioGroup1.ItemIndex = 3 then begin
      //PrintPage event
      pm := TGIS_PrintManager.Create ;
      try
        // PrintPage for custom paint
        pm.PrintPageEvent := PrintPage ;
        pm.PrintPdf( GIS, PdfFileName,
                     210 * 72 / 25.4,
                     297 * 72 / 25.4
                   ) ;
      finally
        pm.Free ;
      end ;
    end
    else if RadioGroup1.ItemIndex = 4 then begin
      // multi-page: mix of different scenarios
      pm := TGIS_PrintManager.Create ;
      try
        // BeforePrintPage defines the way a page will be printed
        pm.BeforePrintPageEvent := BeforePrintPage ;
        pm.PrintPdf( GIS, PdfFileName,
                     210 * 72 / 25.4,
                     297 * 72 / 25.4
                   ) ;
      finally
        pm.Free ;
      end ;
    end ;
  finally
    dlg.Free ;
  end;
end;

procedure TForm1.BeforePrintPage(
       _sender       : TObject  ;
       _printmanager : TGIS_PrintManager ;
  var  _lastpage     : Boolean
) ;
var
  pm : TGIS_PrintManager ;
  pr : TGIS_Printer ;
  tp : TGIS_TemplatePrint ;
begin
  pm := _printmanager ;
  pr := pm.Printer ;

  if pr.PageNumber = 1 then begin
    // prepare first page: PrintPage event
    pm.Template := nil ;
    pm.PrintPageEvent := PrintPage ;
  end
  else if pr.PageNumber = 2 then begin
    // prepare second page: standard print
    pm.Template := nil ;
    pm.PrintPageEvent := nil ;
  end
  else if pr.PageNumber = 3 then begin
    // prepare third page: ttktemplate
    tp := TGIS_TemplatePrint.Create ;
    tp.TemplatePath := TGIS_Utils.GisSamplesDataDirDownload + 'Samples\PrintTemplate\printtemplate.tpl' ;
    tp.GIS_Viewer[ 1 ] := GIS ;
    tp.GIS_ViewerExtent[ 1 ] := GIS.VisibleExtent ;
    tp.GIS_ViewerScale[ 1 ]  := GIS.ScaleAsFloat ;
    tp.GIS_Scale[ 1 ] := GISScale ;
    tp.GIS_Legend[ 1 ] := GISLegend ;
    tp.Text[ 1 ] := 'Page ' + pr.PageNumber.ToString ;
    tp.Text[ 2 ] := tp.TemplatePath ;
    pm.Template := tp;
    pm.PrintPageEvent := nil ;
  end;

  if pr.PageNumber >= 3  then _lastpage := True
                         else _lastpage := False ;
end ;

procedure TForm1.PrintPage(
       _sender       : TObject  ;
       _printmanager : TGIS_PrintManager ;
  var  _lastpage     : Boolean
) ;
var
  r  : TRect ;
  r1 : TRect ;
  scale : Double ;
  s  : String ;
  h  : Integer ;
  pt : TPoint ;
  pm : TGIS_PrintManager ;
  pr : TGIS_Printer ;
  rd : TGIS_RendererAbstract ;

  function inch( const _value : Double ) : Integer ;
  begin
    Result := Round( _value * pr.PPI ) ;
  end ;
begin
  pm := _printmanager ;
  pr := pm.Printer ;
  rd := TGIS_RendererAbstract(pr.Renderer) ;

  rd.CanvasBrush.Color := TGIS_Color.Black ;
  rd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;

  r.Left   := 0 ;
  r.Top    := inch( 0.5 ) ;
  r.Right  := pr.PageWidth  ;
  r.Bottom := pr.PageHeight ;

  // right panel
  r.Left := r.Right  - pr.TwipsToX( 2*1440 ) ;
  rd.CanvasBrush.Color := TGIS_Color.Gray ;
  rd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rd.CanvasPen.Style   := TGIS_PenStyle.Clear ;
  rd.CanvasDrawRectangle( r ) ;

  r.Left   := r.Left   - inch( 0.1 ) ;
  r.Top    := r.Top    - inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  rd.CanvasBrush.Color := TGIS_Color.White ;
  rd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rd.CanvasPen.Color   := TGIS_Color.Black ;
  rd.CanvasPen.Style   := TGIS_PenStyle.Solid ;
  rd.CanvasPen.Width   := rd.TwipsToPoints( 20 ) ;
  rd.CanvasDrawRectangle( r ) ;

  // legend
  r.Left   := r.Left   + 1 ;
  r.Top    := r.Top    + 1 ;
  r.Right  := r.Right  - 1 ;
  r.Bottom := r.Bottom - 1 ;
  pm.DrawControl( GISLegend, r ) ;

  r.Left   := inch( 0.1 ) ;
  r.Top    := inch( 0.5 ) ;
  r.Right  := pr.PageWidth  ;
  r.Bottom := pr.PageHeight ;

  // left panel
  r.Right := r.Right  - pr.TwipsToX( 2*1440 ) - inch( 0.2 ) ;
  rd.CanvasBrush.Color := TGIS_Color.Gray ;
  rd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rd.CanvasPen.Style   := TGIS_PenStyle.Clear ;
  rd.CanvasDrawRectangle( r ) ;
  // for future use
  r1 := r ;

  r.Left   := r.Left   - inch( 0.1 ) ;
  r.Top    := r.Top    - inch( 0.1 ) ;
  r.Right  := r.Right  - inch( 0.1 ) ;
  r.Bottom := r.Bottom - inch( 0.1 ) ;
  rd.CanvasBrush.Color := TGIS_Color.White ;
  rd.CanvasBrush.Style := TGIS_BrushStyle.Solid ;
  rd.CanvasPen.Color   := TGIS_Color.Black ;
  rd.CanvasPen.Style   := TGIS_PenStyle.Solid ;
  rd.CanvasPen.Width   := rd.TwipsToPoints( 20 ) ;
  rd.CanvasDrawRectangle( r ) ;

  // map
  r.Left   := r.Left   + 1 ;
  r.Top    := r.Top    + 1 ;
  r.Right  := r.Right  - 1 ;
  r.Bottom := r.Bottom - 1 ;
  scale := 0 ;
  pm.DrawMap( GIS, GIS.Extent, r, scale ) ;

  // scale
  r.Left   := r.Left   + inch( 0.5 ) ;
  r.Top    := r.Bottom - inch( 1.0 ) ;
  r.Right  := r.Left   + inch( 3.0 ) ;
  r.Bottom := r.Bottom - inch( 0.5 ) ;
  pm.DrawControl( GISScale, r ) ;

  // page number
  rd.CanvasBrush.Color := TGIS_Color.White ;
  rd.CanvasFont.Color := TGIS_Color.Black ;
  rd.CanvasFont.Name := 'Arial' ;
  rd.CanvasFont.Size := 12 ;
  s := Format('Page %d', [pr.PageNumber] ) ;
  pt := rd.CanvasTextExtent( s ) ;
  r.Left   := pr.TwipsToX(720) ;
  r.Top    := r1.Top + pr.TwipsToY(720) ;
  r.Right  := r.Left + pt.X ;
  r.Bottom := r.Top + pt.Y ;
  rd.CanvasDrawText( r, s );

  // title
  pm.Title := 'Print Title';
  s := pm.Title ;
  rd.CanvasFont.Assign( pm.TitleFont ) ;
  pt := rd.CanvasTextExtent( pm.Title ) ;
  r.Left   := Round( (r1.Right - r1.Left) / 2 ) - Round( pt.X / 2 ) ;
  r.Top    := r1.Top + pr.TwipsToY(720) ;
  r.Right  := r.Left + pt.X ;
  r.Bottom := r.Top + pt.Y ;
  rd.CanvasDrawText( r, s );
  h := r.Height ;

  // subitle
  pm.Subtitle := 'Print Subtitle';
  s := pm.Subtitle ;
  rd.CanvasFont.Assign( pm.SubtitleFont ) ;
  pt := rd.CanvasTextExtent( pm.Subtitle ) ;
  r.Left   := Round( (r1.Right - r1.Left) / 2 ) - Round( pt.X / 2 ) ;
  r.Top    := r1.Top + pr.TwipsToY(720) + h + pr.TwipsToY(200) ;
  r.Right  := r.Left + pt.X ;
  r.Bottom := r.Top + pt.Y ;
  rd.CanvasDrawText( r, s );

  if pr.PageNumber >= 2  then _lastpage := True
                         else _lastpage := False ;
end ;

end.
