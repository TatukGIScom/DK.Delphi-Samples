//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  GisVis.Debugger.DockForm — RAD Studio debugger dockable window factory (Delphi/VCL).

  What the unit provides:
    - TGisVisDockForm class implementing INTACustomDockableForm interface
    - Factory for creating debugger inspector windows hosting shape visualizers
    - Window state persistence (save/restore position and size)
    - Menu and toolbar integration with RAD Studio IDE
    - Expression-specific visualization windows
    - Helper interface for frame-form communication

  Key concepts:
    INTACustomDockableForm      - RAD Studio dockable window protocol
    TCustomFrameClass           - frame template for visualization UI
    Window state persistence    - INI file storage of window geometry
    IDE integration             - menu/toolbar customization points
}
unit GisVis.Debugger.DockForm ;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles,  vcl.ComCtrls, DesignIntf,
  Vcl.Forms, Vcl.Controls, Vcl.ActnList, Vcl.ImgList, Vcl.Menus,
  ToolsAPI, GisVis.Debugger.ViewerFrame ;

type
  IGisVisFrameFormHelper = interface
    ['{9E2C6B3E-9B9D-4E8B-9E7C-0B7C9F0B7C11}']
    function GetFrame : TCustomFrame ;
    procedure SetForm( AForm : TCustomForm ) ;
  end ;

  TGisVisDockForm = class( TInterfacedObject, INTACustomDockableForm, IGisVisFrameFormHelper )
  private
    FMyFrame : TFrameGisShapeVisualizer ;
    FMyForm : TCustomForm ;
    FExpression : String ;
  public
    constructor Create( const AExpression : String ) ;

    { INTACustomDockableForm }
    function GetCaption : String ;
    function GetFrameClass : TCustomFrameClass ;
    procedure FrameCreated( AFrame : TCustomFrame ) ;
    function GetIdentifier : String ;
    function GetMenuActionList : TCustomActionList ;
    function GetMenuImageList : TCustomImageList ;
    procedure CustomizePopupMenu( PopupMenu : TPopupMenu ) ;
    function GetToolbarActionList : TCustomActionList ;
    function GetToolbarImageList : TCustomImageList ;
    procedure CustomizeToolBar( ToolBar : TToolBar ) ;
    procedure LoadWindowState( Desktop : TCustomIniFile ; const Section : String ) ;
    procedure SaveWindowState( Desktop : TCustomIniFile ; const Section : String ; IsProject : Boolean ) ;
    function GetEditState : TEditState ;
    function EditAction( Action : TEditAction ) : Boolean ;

    { IGisVisFrameFormHelper }
    function GetFrame : TCustomFrame ;
    procedure SetForm( AForm : TCustomForm ) ;
  end ;

implementation

{ TGisVisDockForm }

  constructor TGisVisDockForm.Create( const AExpression : String ) ;
  begin
    inherited Create ;
    FExpression := AExpression ;
  end ;

  procedure TGisVisDockForm.CustomizePopupMenu( PopupMenu : TPopupMenu ) ;
  begin
    // nothing extra
  end ;

  procedure TGisVisDockForm.CustomizeToolBar( ToolBar : TToolBar ) ;
  begin
    // nothing extra
  end ;

  function TGisVisDockForm.EditAction( Action : TEditAction ) : Boolean ;
  begin
    Result := False ;
  end ;

  procedure TGisVisDockForm.FrameCreated( AFrame : TCustomFrame ) ;
  begin
    FMyFrame := TFrameGisShapeVisualizer( AFrame ) ;
  end ;

  function TGisVisDockForm.GetCaption : String ;
  begin
    Result := Format( 'Shape preview  : %s', [FExpression] ) ;
  end ;

  function TGisVisDockForm.GetEditState : TEditState ;
  begin
    Result := [] ;
  end ;

  function TGisVisDockForm.GetFrame : TCustomFrame ;
  begin
    Result := FMyFrame ;
  end ;

  function TGisVisDockForm.GetFrameClass : TCustomFrameClass ;
  begin
    Result := TFrameGisShapeVisualizer ;
  end ;

  function TGisVisDockForm.GetIdentifier : String ;
  begin
    Result := 'GisShapeVisualizer_' + FExpression ;
  end ;

  function TGisVisDockForm.GetMenuActionList : TCustomActionList ;
  begin
    Result := nil ;
  end ;

  function TGisVisDockForm.GetMenuImageList : TCustomImageList ;
  begin
    Result := nil ;
  end ;

  function TGisVisDockForm.GetToolbarActionList : TCustomActionList ;
  begin
    Result := nil ;
  end ;

  function TGisVisDockForm.GetToolbarImageList : TCustomImageList ;
  begin
    Result := nil ;
  end ;

  procedure TGisVisDockForm.LoadWindowState( Desktop : TCustomIniFile ; const Section : String ) ;
  begin
    // rely on IDE default docking behaviour
  end ;

  procedure TGisVisDockForm.SaveWindowState( Desktop : TCustomIniFile ; const Section : String ;
    IsProject : Boolean ) ;
  begin
    // rely on IDE default docking behaviour
  end ;

  procedure TGisVisDockForm.SetForm( AForm : TCustomForm ) ;
  begin
    FMyForm := AForm ;
    if Assigned( FMyFrame ) then
      FMyFrame.SetForm( FMyForm ) ;
  end ;

end.
