unit GisVis.Debugger.Evaluator ;

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics, ToolsAPI, GisVis.Core ;

{$IF CompilerVersion >= 23.0}
  {$DEFINE GISVIS_HAS_THREADNOTIFIER160}
{$IFEND}

const
  CGisVisDefaultEvaluateTimeoutMs = 3000 ;

type
  TGisDebugEvaluator = class( TComponent, IOTAThreadNotifier
    {$IFDEF GISVIS_HAS_THREADNOTIFIER160}, IOTAThreadNotifier160{$ENDIF} )
  private
    FCompleted : Boolean ;
    FDeferredResult : String ;
    FDeferredError : Boolean ;
    FNotifierIndex : Integer ;
  public
    function Evaluate( const AExpression : String ; out AError : String ;
      AMaxWaitMs : Cardinal = CGisVisDefaultEvaluateTimeoutMs ) : String ;
    function EvaluateObjectAddress( const AExpression : String ; out AError : String ;
      AMaxWaitMs : Cardinal = CGisVisDefaultEvaluateTimeoutMs ) : UInt64 ;
    function ShowLayer( const AShapeExpression : String ; out AError : String ;
      AMaxWaitMs : Cardinal = CGisVisDefaultEvaluateTimeoutMs ) : UInt64 ;

    { IOTAThreadNotifier }
    procedure AfterSave ;
    procedure BeforeSave ;
    procedure Destroyed ;
    procedure Modified ;
    procedure ThreadNotify( Reason : TOTANotifyReason ) ;
    procedure ModifyComplete( const ExprStr : String ; const ResultStr : String ; ReturnCode : Integer ) ;
    procedure EvaluateComplete( const ExprStr : String ; const ResultStr : String ;
      CanModify : Boolean ; ResultAddress : LongWord ; ResultSize : LongWord ;
      ReturnCode : Integer ) ;  overload  ;
    {$IFDEF GISVIS_HAS_THREADNOTIFIER160}
    { IOTAThreadNotifier160 }
    procedure EvaluateComplete( const ExprStr : String ; const ResultStr : String ;
      CanModify : Boolean ; ResultAddress : TOTAAddress ; ResultSize : LongWord ;
      ReturnCode : Integer ) ; overload  ;
    {$ENDIF}
  end ;

  function GisVisPtrExpr( const AClassName : String ; AAddress : UInt64 ) : String ;

implementation

{ TGisDebugEvaluator }

  function TGisDebugEvaluator.Evaluate( const AExpression : String ; out AError : String ;
    AMaxWaitMs : Cardinal
   ) : String ;
  var
    CurProcess : IOTAProcess ;
    CurThread : IOTAThread ;
    ResultBuf : array [0 .. 1048576] of Char ;
    CanModify : Boolean ;
    Done, TimedOut : Boolean ;
    ResultAddr, ResultSize, ResultVal : LongWord ;
    EvalRes : TOTAEvaluateResult ;
    DebugSvcs : IOTADebuggerServices ;
    Stopwatch : TStopwatch ;
  begin
    Result := '' ;
    AError := '' ;
    TimedOut := False ;

    if not Supports( BorlandIDEServices, IOTADebuggerServices, DebugSvcs ) then
    begin
      AError := 'IOTADebuggerServices not available.' ;
      Exit ;
    end ;

    CurProcess := DebugSvcs.CurrentProcess ;
    if CurProcess = nil then
    begin
      AError := 'No active debug process. Run to a breakpoint first.' ;
      Exit ;
    end ;

    CurThread := CurProcess.CurrentThread ;
    if CurThread = nil then
    begin
      AError := 'No current debug thread.' ;
      Exit ;
    end ;

    Stopwatch := TStopwatch.StartNew ;
    try
      repeat
        Done := True ;
        EvalRes := CurThread.Evaluate( AExpression, @ResultBuf, Length( ResultBuf ),
          CanModify, eseAll, '', ResultAddr, ResultSize, ResultVal, '', 0 ) ;
        case EvalRes of
          erOK:
            Result := ResultBuf ;
          erDeferred:
            begin
              FCompleted := False ;
              FDeferredResult := '' ;
              FDeferredError := False ;
              FNotifierIndex := CurThread.AddNotifier( Self ) ;
              try
                while not FCompleted do
                begin
                  DebugSvcs.ProcessDebugEvents ;
                  if Stopwatch.ElapsedMilliseconds > AMaxWaitMs then
                  begin
                    TimedOut := True ;
                    Break ;
                  end ;
                  Sleep( 5 ) ;
                end ;
              finally
                CurThread.RemoveNotifier( FNotifierIndex ) ;
                FNotifierIndex := -1 ;
              end ;
              if TimedOut then
                AError := Format( 'Evaluation of "%s" timed out after %dms - the ' +
                  'debugger did not report completion.', [AExpression, AMaxWaitMs] )
              else if FDeferredError then
                AError := 'Evaluation failed for : ' + AExpression
              else if FDeferredResult <> '' then
                Result := FDeferredResult
              else
                Result := ResultBuf ;
            end ;
          erBusy:
            begin
              if Stopwatch.ElapsedMilliseconds > AMaxWaitMs then
              begin
                AError := Format( 'Evaluation of "%s" timed out after %dms ' +
                  '( debugger kept reporting busy ).', [AExpression, AMaxWaitMs] ) ;
                Done := True ;
              end
              else
              begin
                DebugSvcs.ProcessDebugEvents ;
                Sleep( 5 ) ;
                Done := False ;
              end ;
            end ;
          erError:
            AError := 'Evaluation error for : ' + AExpression ;
        end ;
      until Done ;
    except
      on E : Exception do
        AError := 'Evaluate raised : ' + E.Message ;
    end ;

    if AError = '' then
      Result := GisVisStripQuotes( Result ) ;
  end ;

  function TGisDebugEvaluator.EvaluateObjectAddress( const AExpression : String ;
    out AError : String ; AMaxWaitMs : Cardinal
   ) : UInt64 ;
  var
    LAddrStr : String ;
  begin
    Result := 0 ;
    LAddrStr := Evaluate( 'NativeUInt(' + AExpression + ')', AError, AMaxWaitMs ) ;
    if AError <> '' then
      Exit ;

    if not TryStrToUInt64( Trim( LAddrStr ), Result ) then
    begin
      AError := Format( 'Evaluating "NativeUInt( %s )" did not return a plain ' +
        'number ( got "%s" ).', [AExpression, LAddrStr] ) ;
      Result := 0 ;
    end ;
  end ;

  function TGisDebugEvaluator.ShowLayer( const AShapeExpression : String ;
    out AError : String ; AMaxWaitMs : Cardinal
   ) : UInt64 ;
  begin
    Result := EvaluateObjectAddress( AShapeExpression + '.Layer', AError, AMaxWaitMs ) ;
  end ;

  function GisVisPtrExpr( const AClassName : String ; AAddress : UInt64 ) : String ;
  begin
    Result := Format( '%s(Pointer($%x)).', [AClassName, AAddress] ) ;
  end ;

  procedure TGisDebugEvaluator.AfterSave ;
  begin
    // not interested
  end ;

  procedure TGisDebugEvaluator.BeforeSave ;
  begin
    // not interested
  end ;

  procedure TGisDebugEvaluator.Destroyed ;
  begin
    // not interested
  end ;

  procedure TGisDebugEvaluator.Modified ;
  begin
    // not interested
  end ;

  procedure TGisDebugEvaluator.ThreadNotify( Reason : TOTANotifyReason ) ;
  begin
    // not interested - we only care about EvaluateComplete
  end ;

  procedure TGisDebugEvaluator.EvaluateComplete( const ExprStr, ResultStr : String ; CanModify : Boolean ;
    ResultAddress, ResultSize : LongWord ; ReturnCode : Integer
   ) ;
  begin
    {$IFDEF GISVIS_HAS_THREADNOTIFIER160}
    // Forward to the wider-address overload so there is exactly one place
    // that records the deferred result.
    EvaluateComplete( ExprStr, ResultStr, CanModify, TOTAAddress( ResultAddress ),
      ResultSize, ReturnCode ) ;
    {$ELSE}
    FCompleted := True ;
    FDeferredResult := ResultStr ;
    FDeferredError := ReturnCode <> 0 ;
    {$ENDIF}
  end ;

  {$IFDEF GISVIS_HAS_THREADNOTIFIER160}
  procedure TGisDebugEvaluator.EvaluateComplete( const ExprStr : String ;
    const ResultStr : String ; CanModify : Boolean ; ResultAddress : TOTAAddress ;
    ResultSize : LongWord ; ReturnCode : Integer
   ) ;
  begin
    FCompleted := True ;
    FDeferredResult := ResultStr ;
    FDeferredError := ReturnCode <> 0 ;
  end ;
  {$ENDIF}

  procedure TGisDebugEvaluator.ModifyComplete( const ExprStr, ResultStr : String ;
    ReturnCode : Integer
   ) ;
  begin
    // not interested - read-only visualizer
  end ;

end.
