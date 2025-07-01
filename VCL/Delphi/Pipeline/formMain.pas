//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to utilize the pipeline functionality.
}
unit formMain;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,


  VCL.GisViewerWnd,
  VCL.GisPipelineParamsEditor,
  GisClasses,
  GisPipeline,
  GisAllLayers,
  GisUtils,
  GisAllPipelineOperations, VCL.GisControlLegend, Vcl.ComCtrls, Vcl.ExtCtrls ;

type
  TfrmMain = class(TForm)
    GIS: TGIS_ViewerWnd;
    memoCode: TMemo;
    btnExecute: TButton;
    btnExit: TButton;
    btnHelp: TButton;
    lstbxCommands: TListBox;
    lblCommands: TLabel;
    lblCode: TLabel;
    btnOpen: TButton;
    btnSave: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    GIS_ControlLegend1: TGIS_ControlLegend;
    lbl1: TLabel;
    pnlDynamicProgress: TPanel;
    procedure btnExitClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure memoCodeDblClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure lstbxCommandsDblClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private // pipeline
    oPipeline         : TGIS_Pipeline ;
    oPipelineCommands : TStringList ;
    oPipelineLine     : Integer ;
    abrt              : Boolean ;
    nameLabelList     : TObjectList<TComponent> ;
    etlLabelList      : TObjectList<TComponent> ;
    progressBarList   : TObjectList<TComponent> ;
  private
    procedure prepareCommands ;

    procedure AddProgressBar ;
    procedure DeleteProgressBar ;

    procedure AddInfoLabel ;
    procedure DeleteInfoLabel ;

    procedure AddEtlLabel ;
    procedure DeleteEtlLabel ;

    procedure doBusyEvent(    _sender : TObject ;
                              _pos    : Integer ;
                              _end    : Integer ;
                          var _abort  : Boolean
                         ) ;
    procedure doPipelineMessage(
      const _message : String
    ) ;
    procedure doPipelineForm(
      _operation : TGIS_PipelineOperationAbstract
    ) ;
    procedure doPipelineHelp(
      _sender : TObject ;
      _name   : String
    ) ;
  end ;

var
  frmMain: TfrmMain;

implementation
  const
    FILE_EXT = '.ttkpipeline' ;
    PROGRESS_SMALL_MARGIN = 15 ;
    PROGRESS_BIG_MARGIN   = 45 ;
    PROGRESS_FONT_SIZE    = 7 ;

{$R *.dfm}

procedure TfrmMain.doBusyEvent(
      _sender : TObject ;
      _pos    : Integer ;
      _end    : Integer ;
  var _abort  : Boolean
) ;
var
  i             : Integer ;
  pos, max_val  : Integer ;
  name          : String ;
  etl           : Int64 ;
  etl_label     : TLabel ;
  name_label    : TLabel ;
  progress      : TProgressBar ;
  event_manager : TGIS_BusyEventManager ;
begin
  if _sender is TGIS_BusyEventManager then begin
    event_manager := TGIS_BusyEventManager( _sender ) ;

    for i := event_manager.Count - 1 downto 0 do begin

      // dynamically add or remove progress controls
      if progressBarList.Count <= i then begin
        AddInfoLabel ;
        AddEtlLabel ;
        AddProgressBar ;
      end ;

      if progressBarList.Count > event_manager.Count then begin
        DeleteInfoLabel ;
        DeleteEtlLabel ;
        DeleteProgressBar ;
      end;

      progress := TProgressBar( progressBarList[i] ) ;
      etl_label := TLabel( etlLabelList[i] ) ;
      name_label := TLabel( nameLabelList[i] ) ;

      name := event_manager.Name[i] ;
      pos := event_manager.Position[i] ;
      case pos of
        -1 : begin
          progress.Position := 0 ;
          name_label.Caption := '' ;
          etl_label.Caption := '' ;
        end ;
        0 : begin
          name_label.Caption := name ;

          max_val := event_manager.Max[i] ;
          progress.Min := 0 ;
          progress.Max := max_val ;
          progress.Position := pos ;
        end ;
        else begin
          name_label.Caption := name ;
          progress.Position := pos ;

          etl := event_manager.EstimatedTimeLeft[i] ;
          etl_label.Caption := 'End time: ' +
            TimeToStr( IncMilliSecond( Now, etl ) ) ;
        end ;
      end ;
    end ;
  end
  else begin
    progress := TProgressBar( progressBarList[0] ) ;

    case _pos of
      -1 : progress.Position := 0 ;
      0 : begin
        progress.Min := 0 ;
        progress.Max := _end ;
        progress.Position := 0 ;
      end
      else
        progress.Position := _pos ;
    end ;
  end ;
  _abort := abrt ;

  Application.ProcessMessages ;
end;

procedure TfrmMain.doPipelineHelp(
  _sender : TObject ;
  _name   : String
) ;
var
  url : String ;
begin
  url := 'https://docs.tatukgis.com/EDT5/guide:help:dkbuiltin:' +
         _name ;
  ShellExecute( 0, 'open', PChar( url ), nil, nil, SW_SHOWNORMAL ) ;
end ;

procedure TfrmMain.doPipelineMessage(
  const _message : String
) ;
begin
  ShowMessage( _message ) ;
end ;

procedure TfrmMain.doPipelineForm(
  _operation : TGIS_PipelineOperationAbstract
) ;
var
  frm : TGIS_PipelineParamsEditor ;
begin
  // alternative ways of bringing up the TGIS_PipelineParamsEditor
  // if TGIS_PipelineParamsEditor.ShowPipelineOperationParams( Self, _operation, doPipelineHelp ) = mrOK then
  // if TGIS_PipelineParamsEditor.ShowPipelineOperationParams( _operation, doPipelineHelp ) = mrOK then

  frm := TGIS_PipelineParamsEditor.Create( Self ) ;
  try
    if frm.Execute( _operation, doPipelineHelp ) = mrOK then
      memoCode.Lines[oPipelineLine-1] := _operation.AsText ;
  finally
    frm.Free ;
  end ;
end ;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  nameLabelList.Free ;
  etlLabelList.Free ;
  progressBarList.Free ;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  memoCode.Lines.LoadFromFile( TGIS_Utils.GisSamplesDataDirDownload + '\Samples\Pipeline\Contouring.ttkpipeline' );

  oPipeline := TGIS_Pipeline.Create ;
  oPipeline.GIS := GIS ;
  oPipeline.ShowMessageEvent := doPipelineMessage ;
  oPipeline.ShowFormEvent    := doPipelineForm ;
  oPipeline.LogErrorEvent    := doPipelineMessage ;
  oPipeline.LogWarningEvent  := doPipelineMessage ;

  oPipeline.BusyEvent := doBusyEvent ;

  prepareCommands ;

  lstbxCommands.Items.AddStrings( oPipelineCommands ) ;

  nameLabelList := TObjectList< TComponent >.Create ;
  etlLabelList := TObjectList< TComponent >.Create ;
  progressBarList := TObjectList< TComponent >.Create ;
end ;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  oPipeline.Free ;
end ;

procedure TfrmMain.prepareCommands ;
begin
  oPipelineCommands := PipelineOperations.Names ;
end ;

procedure TfrmMain.DeleteProgressBar ;
begin
  progressbarList.Delete( progressbarList.Count - 1 ) ;
end;

procedure TfrmMain.DeleteInfoLabel ;
begin
  nameLabelList.Delete( nameLabelList.Count - 1 ) ;
end;

procedure TfrmMain.DeleteEtlLabel ;
begin
  etlLabelList.Delete( etlLabelList.Count - 1 ) ;
end;

procedure TfrmMain.AddProgressBar ;
var
  index : Integer ;
  progressbar : TProgressBar ;
begin
  index := progressbarList.Count ;

  progressbar := TProgressBar.Create( pnlDynamicProgress ) ;
  progressbar.Parent := pnlDynamicProgress ;
  progressbar.Left := 3 ;
  progressbar.Width := pnlDynamicProgress.Width - 6 ;
  progressbar.Height := 8 ;
  progressbar.Top := 3 + 2 * PROGRESS_SMALL_MARGIN + index * PROGRESS_BIG_MARGIN ;
  progressbar.AlignWithMargins := True ;
  progressbarList.Add( progressbar ) ;
end;

procedure TfrmMain.AddEtlLabel ;
var
  index : Integer ;
  etlLabel : TLabel ;
begin
  index := etlLabelList.Count ;

  etlLabel := TLabel.Create( pnlDynamicProgress ) ;
  etlLabel.Parent := pnlDynamicProgress ;
  etlLabel.Left := 3 ;
  etlLabel.Top := 3 + 1 * PROGRESS_SMALL_MARGIN + index * PROGRESS_BIG_MARGIN ;
  etlLabel.Font.Size := PROGRESS_FONT_SIZE ;
  etlLabel.AlignWithMargins := True ;
  etlLabel.Caption := '' ;
  etlLabelList.Add( etlLabel ) ;
end;

procedure TfrmMain.AddInfoLabel ;
var
  index : Integer ;
  infoLabel : TLabel ;
begin
  index := nameLabelList.Count ;

  infoLabel := TLabel.Create( pnlDynamicProgress ) ;
  infoLabel.Parent := pnlDynamicProgress ;
  infoLabel.Left := 3 ;
  infoLabel.Top := 3 + index * PROGRESS_BIG_MARGIN ;
  infoLabel.Font.Size := PROGRESS_FONT_SIZE ;
  infoLabel.AlignWithMargins := True ;
  infoLabel.Caption := '' ;
  nameLabelList.Add( infoLabel ) ;
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
var
  url : String ;
begin
  url := 'https://docs.tatukgis.com/DK11/doc:pipeline' ;
  ShellExecute(0, 'open', PChar( url ), nil, nil, SW_SHOWNORMAL);
end ;

procedure TfrmMain.btnOpenClick(Sender: TObject);
var
  str   : String      ;
  ext   : String      ;
  lines : TStringList ;
begin
  if not dlgOpen.Execute then exit ;

  str := dlgOpen.FileName ;
  ext := ExtractFileExt( str ) ;

  if CompareText( ext, FILE_EXT ) = 0 then begin
    lines := TStringList.Create ;
    try
      lines.LoadFromFile( str );
      memoCode.Lines.Text := lines.Text ;
    finally
      FreeAndNil( lines );
    end;
  end;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  str   : String      ;
  ext   : String      ;
  lines : TStringList ;
begin
  if not dlgSave.Execute then exit ;

  str := dlgSave.FileName ;
  ext := ExtractFileExt( str ) ;

  if CompareText( ext, FILE_EXT ) = 0 then begin
    lines := TStringList.Create ;
    lines.AddStrings( memoCode.Lines ) ;
    try
      lines.SaveToFile( str );
    finally
      FreeAndNil( lines );
    end;
  end;
end;

procedure TfrmMain.btnExecuteClick(Sender: TObject);
begin
  oPipeline.SourceCode := memoCode.Text ;
  oPipeline.Execute ;
end ;

procedure TfrmMain.memoCodeDblClick(Sender: TObject);
begin
  oPipelineLine := memoCode.CaretPos.Y + 1 ;
  oPipeline.SourceCode := memoCode.Text ;
  oPipeline.ShowForm( oPipelineLine ) ;
end ;

procedure TfrmMain.lstbxCommandsDblClick(Sender: TObject);
begin
  oPipeline.ShowForm( lstbxCommands.Items[lstbxCommands.ItemIndex], memoCode.CaretPos.Y ) ;
end ;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Application.Terminate ;
end ;

end.
