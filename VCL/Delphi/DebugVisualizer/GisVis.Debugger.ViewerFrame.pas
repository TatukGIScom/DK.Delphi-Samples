//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  DebugVisualizer — IDE integration for visualizing TatukGIS shapes in the debugger (Delphi/VCL).

  What the sample shows:
    - Custom RAD Studio debugger visualizer plugin architecture
    - Real-time shape visualization during debugging
    - Parsing GIS shape objects from debugger expression evaluator
    - Rendering shapes in an embedded GIS viewer within debugger inspector
    - WKT (Well-Known Text) format export for geometric analysis
    - JSON and GML format exports of shape geometry
    - Shape statistics display (extent, area, length, vertex count)
    - Coordinate system transformation for shape display
    - Clipboard integration for exporting geometry text
    - IOTADebuggerVisualizerExternalViewerUpdater interface implementation
    - Dynamic UI layout with splitters for statistics and geometry display

  Key TatukGIS API concepts shown here:
    TGIS_Shape                  - geometric objects inspected in debugger
    TGIS_LayerVector            - in-memory layer for visualizing shapes
    TGIS_ViewerWnd              - embedded map viewer in debugger window
    GisVisCreateMemoryLayer     - factory for memory-based vector layers
    GisVisBuildShapeFromWKT     - reconstruct shapes from text format
    GisVisComputeStats          - extract shape statistics (area, length, bounds)
    IOTADebuggerVisualizer      - RAD Studio plugin interface
}
unit GisVis.Debugger.ViewerFrame ;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Clipbrd, Vcl.Graphics,
  ToolsAPI,
  GisTypes, GisLayerVector, VCL.GisViewerWnd, GisLayer,
  GisVis.Core, GisVis.Debugger.Evaluator ;

type
  TFrameGisShapeVisualizer = class( TFrame, IOTADebuggerVisualizerExternalViewerUpdater )
  private
    FPanelTop      : TPanel ;
    FMemoStats     : TMemo ;
    FSplitterTop   : TSplitter ;
    FPanelBottom   : TPanel ;
    FMemoWKT       : TMemo ;
    FButtonCopyWkt : TButton ;
    FSplitterBottom: TSplitter ;
    FFormat        : TComboBox ;

    FGIS      : TGIS_ViewerWnd ;
    FMemLayer : TGIS_LayerVector ;
    LShape    : TGIS_Shape ;

    FEvaluator  : TGisDebugEvaluator ;
    FExpression : String ;
    FOwningForm : TCustomForm ;
    FClosedProc : TOTAVisualizerClosedProcedure ;

    procedure BuildUI ;
    procedure ButtonCopyWktClick( Sender : TObject ) ;
    procedure ShowStatus( const AText : String ) ;
    procedure ShowStats( const AStats : TGisVisShapeStats ) ;
  protected
    procedure SetParent( AParent : TWinControl ) ; override ;
    procedure doFormatChange( sender  : TObject )  ;
  public
    constructor Create( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;

    procedure DisplayShape( const AExpression, ATypeName, AEvalResult : String ) ;
    procedure SetForm( AForm : TCustomForm ) ;

    { IOTADebuggerVisualizerExternalViewerUpdater }
    procedure CloseVisualizer ;
    procedure MarkUnavailable( Reason : TOTAVisualizerUnavailableReason ) ;
    procedure RefreshVisualizer( const Expression, TypeName, EvalResult : String ) ;
    procedure SetClosedCallback( ClosedProc : TOTAVisualizerClosedProcedure ) ;
  end ;

implementation

{$R *.dfm}

{ TFrameGisShapeVisualizer }

  { Constructor
    Initializes the visualizer frame with debugger evaluator, memory layer,
    and UI layout (map viewer, statistics pane, geometry export pane). }
  constructor TFrameGisShapeVisualizer.Create( AOwner : TComponent ) ;
  begin
    inherited Create( AOwner ) ;
    FEvaluator := TGisDebugEvaluator.Create( nil ) ;
    FMemLayer := GisVisCreateMemoryLayer ;
    BuildUI ;
    FGIS.Add( FMemLayer ) ;
  end ;

  { Destructor
    Releases the debugger evaluator and inherited resources. }
  destructor TFrameGisShapeVisualizer.Destroy ;
  begin
    FreeAndNil( FEvaluator ) ;
    inherited Destroy ;
  end ;

  { BuildUI
    Creates the layout with three sections: top (map viewer), middle (splitter),
    bottom-upper (shape statistics), bottom-middle (splitter), bottom-lower (WKT/JSON/GML export).

    Layout (top to bottom):
      - FGIS (map viewer) - alClient
      - FSplitterTop
      - FPanelTop (FMemoStats) - 130px height
      - FSplitterBottom
      - FPanelBottom (FFormat + FMemoWKT + FButtonCopyWkt) - 160px height }
  procedure TFrameGisShapeVisualizer.BuildUI ;
  begin
    Self.DoubleBuffered := True ;

    // Bottom panel: geometry export (WKT, JSON, GML)
    FPanelBottom := TPanel.Create( Self ) ;
    FPanelBottom.Parent := Self ;
    FPanelBottom.Align := alBottom ;
    FPanelBottom.Height := 160 ;
    FPanelBottom.BevelOuter := bvNone ;
    FPanelBottom.Caption := '' ;

    // Copy button for clipboard export
    FButtonCopyWkt := TButton.Create( Self ) ;
    FButtonCopyWkt.Parent := FPanelBottom ;
    FButtonCopyWkt.Align := alBottom ;
    FButtonCopyWkt.Caption := 'Copy to Clipboard' ;
    FButtonCopyWkt.OnClick := ButtonCopyWktClick ;

    // Geometry text export (WKT/JSON/GML)
    FMemoWKT := TMemo.Create( Self ) ;
    FMemoWKT.Parent := FPanelBottom ;
    FMemoWKT.Align := alClient ;
    FMemoWKT.ScrollBars := ssVertical ;
    FMemoWKT.WordWrap := True ;
    FMemoWKT.ReadOnly := True ;
    FMemoWKT.Font.Name := 'Consolas' ;

    // Format selector (WKT, JSON, GML)
    FFormat := TComboBox.Create( Self )  ;
    FFormat.Parent := FPanelBottom ;
    FFormat.Align := alTop ;
    FFormat.Items.Add( 'WKT' ) ;
    FFormat.Items.Add( 'JSON' ) ;
    FFormat.Items.Add( 'GML' ) ;
    FFormat.Style := TcomboBoxStyle.csDropDownList  ;
    FFormat.ItemIndex := 0  ;
    FFormat.onChange := doFormatChange  ;

    // Splitter between geometry export and statistics
    FSplitterBottom := TSplitter.Create( Self ) ;
    FSplitterBottom.Parent := Self ;
    FSplitterBottom.Align := alBottom ;

    // Top panel: shape statistics (extent, area, length, vertex count)
    FPanelTop := TPanel.Create( Self ) ;
    FPanelTop.Parent := Self ;
    FPanelTop.Align := alTop ;
    FPanelTop.Height := 130 ;
    FPanelTop.BevelOuter := bvNone ;
    FPanelTop.Caption := '' ;

    FMemoStats := TMemo.Create( Self ) ;
    FMemoStats.Parent := FPanelTop ;
    FMemoStats.Align := alClient ;
    FMemoStats.ReadOnly := True ;
    FMemoStats.ScrollBars := ssVertical ;
    FMemoStats.Color := clBtnFace ;
    FMemoStats.Font.Name := 'Consolas' ;

    // Splitter between map viewer and statistics
    FSplitterTop := TSplitter.Create( Self ) ;
    FSplitterTop.Parent := Self ;
    FSplitterTop.Align := alTop ;

    // Embedded GIS viewer (bottom section, alClient fills remaining space)
    FGIS := TGIS_ViewerWnd.Create( Self ) ;
    FGIS.Parent := Self ;
    FGIS.Align := alClient ;
    FGIS.Mode := TGIS_ViewerMode.Zoom  ;
    FGIS.AutoStyle := True  ;
  end ;

  { ButtonCopyWktClick
    Copies the current geometry export text (WKT/JSON/GML) to the clipboard. }
  procedure TFrameGisShapeVisualizer.ButtonCopyWktClick( Sender : TObject ) ;
  begin
    Clipboard.AsText := FMemoWKT.Text ;
  end ;

  { ShowStatus
    Displays a status message in the statistics panel (used during evaluation). }
  procedure TFrameGisShapeVisualizer.ShowStatus( const AText : String ) ;
  begin
    FMemoStats.Lines.Text := AText ;
  end ;

  { ShowStats
    Displays shape metadata and geometric properties in the statistics pane.
    Shows: UID, class name, geometry type, vertex/part counts, extent, area, length.
    Properties only shown if available for that geometry type. }
  procedure TFrameGisShapeVisualizer.ShowStats( const AStats : TGisVisShapeStats ) ;
  var
    L : TStrings ;
  begin
    L := FMemoStats.Lines ;
    L.BeginUpdate ;
    try
      L.Clear ;
      L.Add( Format( 'Uid:     %d', [AStats.Uid] ) ) ;
      L.Add( Format( 'Class:   %s', [AStats.ShapeClassName] ) ) ;
      L.Add( Format( 'Type:    %s', [AStats.GeometryType] ) ) ;
      L.Add( Format( 'Parts:   %d', [AStats.NumParts] ) ) ;
      L.Add( Format( 'Points:  %d',  [AStats.NumPoints] ) ) ;
      if AStats.HasExtent then
        L.Add( Format( 'Extent:  [%.6f, %.6f] - [%.6f, %.6f]',
          [AStats.XMin, AStats.YMin, AStats.XMax, AStats.YMax] ) )
      else
        L.Add( 'Extent:  n/a' ) ;
      if AStats.HasArea then
        L.Add( Format( 'Area:    %.6f', [AStats.Area] ) ) ;
      if AStats.HasLength then
        L.Add( Format( 'Length:  %.6f', [AStats.Length] ) ) ;
    finally
      L.EndUpdate ;
    end ;
  end ;

  procedure TFrameGisShapeVisualizer.DisplayShape( const AExpression, ATypeName,
    AEvalResult : String ) ;
  var
    LError, LWkt : String ;
    LStats : TGisVisShapeStats ;
    expr   : String  ;
    LLayerAddr : UInt64 ;
    err : String;
  begin
    FExpression := AExpression ;

    expr := '.ExportTo' + FFormat.Items[FFormat.ItemIndex]  ;
    ShowStatus( 'Evaluating ' + AExpression + expr + '...' ) ;
    FMemoStats.Update ;

    LWkt := FEvaluator.Evaluate( AExpression + expr, LError ) ;
    if LError <> '' then
    begin
      ShowStatus( 'Could not evaluate ' + AExpression + expr + sLineBreak + LError ) ;
      FMemoWKT.Lines.Clear ;
      Exit ;
    end ;

    if not GisVisBuildShapeFromWKT( FFormat.ItemIndex, LWkt, FMemLayer, LShape, err ) then
    begin
      ShowStatus( expr + ' returned text that could not be parsed. ' + #13#10 + err ) ;
      FMemoWKT.Lines.Text := LWkt ;
      Exit ;
    end ;

    LStats := GisVisComputeStats( LShape, LWkt ) ;
    ShowStats( LStats ) ;
    FMemoWKT.Lines.Text := LWkt ;

    LLayerAddr := FEvaluator.ShowLayer( 'shp', LError ) ;
    if LError = '' then begin
      FMemoStats.Lines.Add(  'Layer:   ' +
        FEvaluator.Evaluate(
        GisVisPtrExpr( 'TGIS_Layer', LLayerAddr ) + 'Name', LError )
       ) ;
    end ;

    FMemLayer.RecalcExtent ;
    FGIS.FullExtent ;
    FGIS.InvalidateWholeMap ;
  end ;

  procedure TFrameGisShapeVisualizer.doFormatChange( sender : TObject ) ;
  begin
    if not assigned(  LShape  ) then exit  ;
    case FFormat.ItemIndex of
      0  : FMemoWKT.Lines.Text := LShape.ExportToWKT  ;
      1  : FMemoWKT.Lines.Text := LShape.ExportToJSON  ;
      2  : FMemoWKT.Lines.Text := LShape.ExportToGML  ;
    end ;
  end ;

  procedure TFrameGisShapeVisualizer.SetForm( AForm : TCustomForm ) ;
  begin
    FOwningForm := AForm ;
  end ;

  procedure TFrameGisShapeVisualizer.SetParent( AParent : TWinControl ) ;
  begin
    if AParent = nil then
    begin
      if Assigned( FClosedProc ) then
        try
          FClosedProc ;
        except
          // swallow - we are tearing down anyway
        end ;
    end ;
    inherited SetParent( AParent ) ;
  end ;

  procedure TFrameGisShapeVisualizer.CloseVisualizer ;
  begin
    if FOwningForm <> nil then
      FOwningForm.Close ;
  end ;

  procedure TFrameGisShapeVisualizer.MarkUnavailable( Reason : TOTAVisualizerUnavailableReason ) ;
  begin
    case Reason of
      ovurProcessRunning : ShowStatus( '( process running - stop at a breakpoint to refresh )' ) ;
      ovurOutOfScope : ShowStatus( '( out of scope )' ) ;
    else
      ShowStatus( '( value not currently available )' ) ;
    end ;
  end ;

  procedure TFrameGisShapeVisualizer.RefreshVisualizer( const Expression, TypeName,
    EvalResult : String ) ;
  begin
    DisplayShape( Expression, TypeName, EvalResult ) ;
  end ;

  procedure TFrameGisShapeVisualizer.SetClosedCallback( ClosedProc : TOTAVisualizerClosedProcedure ) ;
  begin
    FClosedProc := ClosedProc ;
  end ;

end.
