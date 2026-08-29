unit GisVis.Debugger.Notifier ;

interface

uses
  System.SysUtils, System.Classes,
  ToolsAPI, Forms,
  GisVis.Debugger.DockForm, GisVis.Debugger.ViewerFrame ;

type
  TGisShapeDebugVisualizer = class( TInterfacedObject, IOTADebuggerVisualizer,
    IOTADebuggerVisualizerValueReplacer, IOTADebuggerVisualizerExternalViewer )
  public
    { IOTADebuggerVisualizer }
    function GetSupportedTypeCount : Integer ;
    procedure GetSupportedType( Index : Integer ; var TypeName : String ;
      var AllDescendants : Boolean ) ;
    function GetVisualizerIdentifier : String ;
    function GetVisualizerName : String ;
    function GetVisualizerDescription : String ;

    { IOTADebuggerVisualizerValueReplacer }
    function GetReplacementValue( const Expression, TypeName, EvalResult : String ) : String ;

    { IOTADebuggerVisualizerExternalViewer }
    function GetMenuText : String ;
    function Show( const Expression, TypeName, EvalResult : String ;
      SuggestedLeft, SuggestedTop : Integer ) : IOTADebuggerVisualizerExternalViewerUpdater ;
  end ;

procedure Register ;

implementation

resourcestring
  SVisualizerName = 'TatukGIS Shape Visualizer' ;
  SVisualizerDescription = 'Renders a TGIS_Shape ( and descendants ) as a map, ' +
    'with geometry stats and its WKT representation.' ;
  SMenuText = 'Show on TatukGIS Map...' ;

const
  CSupportedType = 'TGIS_Shape' ;

{ TGisShapeDebugVisualizer }

  function TGisShapeDebugVisualizer.GetSupportedTypeCount : Integer ;
  begin
    Result := 1 ;
  end ;

  procedure TGisShapeDebugVisualizer.GetSupportedType( Index : Integer ;
    var TypeName : String ; var AllDescendants : Boolean ) ;
  begin
    TypeName := CSupportedType ;
    AllDescendants := True ;
  end ;

  function TGisShapeDebugVisualizer.GetVisualizerIdentifier : String ;
  begin
    Result := 'TatukGIS.GisVis.ShapeDebugVisualizer' ;
  end ;

  function TGisShapeDebugVisualizer.GetVisualizerName : String ;
  begin
    Result := SVisualizerName ;
  end ;

  function TGisShapeDebugVisualizer.GetVisualizerDescription : String ;
  begin
    Result := SVisualizerDescription ;
  end ;

  function TGisShapeDebugVisualizer.GetReplacementValue( const Expression, TypeName,
    EvalResult : String ) : String ;
  begin
    Result := TypeName + ' (click to preview)' ;
  end ;

  function TGisShapeDebugVisualizer.GetMenuText : String ;
  begin
    Result := SMenuText ;
  end ;

  function TGisShapeDebugVisualizer.Show( const Expression, TypeName, EvalResult : String ;
    SuggestedLeft, SuggestedTop : Integer ) : IOTADebuggerVisualizerExternalViewerUpdater ;
  var
    LDockForm : INTACustomDockableForm ;
    LForm : TCustomForm ;
    LFrame : TFrameGisShapeVisualizer ;
  begin
    LDockForm := TGisVisDockForm.Create( Expression ) as INTACustomDockableForm ;
    LForm := ( BorlandIDEServices as INTAServices ).CreateDockableForm( LDockForm ) ;
    LForm.Left := SuggestedLeft ;
    LForm.Top := SuggestedTop ;

    ( LDockForm as IGisVisFrameFormHelper ).SetForm( LForm ) ;
    LFrame := ( LDockForm as IGisVisFrameFormHelper ).GetFrame as TFrameGisShapeVisualizer ;
    LFrame.DisplayShape( Expression, TypeName, EvalResult ) ;

    Result := LFrame as IOTADebuggerVisualizerExternalViewerUpdater ;
  end ;

  var
    GisShapeVisualizer : IOTADebuggerVisualizer ;

  procedure Register ;
  var
    DebuggerServices : IOTADebuggerServices ;
  begin
    if Supports( BorlandIDEServices, IOTADebuggerServices, DebuggerServices ) then
    begin
      GisShapeVisualizer := TGisShapeDebugVisualizer.Create ;
      DebuggerServices.RegisterDebugVisualizer( GisShapeVisualizer ) ;
    end ;
  end ;

  procedure RemoveVisualizer ;
  var
    DebuggerServices : IOTADebuggerServices ;
  begin
    if Supports( BorlandIDEServices, IOTADebuggerServices, DebuggerServices ) then
    begin
      DebuggerServices.UnregisterDebugVisualizer( GisShapeVisualizer ) ;
      GisShapeVisualizer := nil ;
    end ;
  end ;

initialization

finalization
  RemoveVisualizer ;

end.
