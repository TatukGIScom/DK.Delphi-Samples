//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
// (c)2000-2025 TatukGIS. ALL RIGHTS RESERVED.
//=============================================================================
{
  How to prepare small coverage previewer.
  Edit window.
}
unit EditForm;


interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.StdCtrls;

type
  TfEdit = class(TForm)
    Editor: TMemo;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    btnSave: TToolButton;
    ImageList1: TImageList;
    procedure EditorChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fEdit: TfEdit;

implementation

{$R *.DFM}


procedure TfEdit.EditorChange(Sender: TObject);
begin
  if Editor.Modified then
    btnSave.Enabled:=true
  else
    btnSave.Enabled:=true;
end;

procedure TfEdit.btnSaveClick(Sender: TObject);
begin
  // save changes to config/project file
  if StatusBar1.Panels[1].Text <> '' then
  begin
    Editor.Lines.SaveToFile( StatusBar1.Panels[1].Text );
    btnSave.Enabled:=false;
  end;
end;

end.
