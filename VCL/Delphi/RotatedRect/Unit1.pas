//=============================================================================
// This source code is a part of TatukGIS Developer Kernel.
//=============================================================================
{
  How to draw on viewer canvas.
}
unit Unit1;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Variants,
  System.Types,

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,

  //GisLicense,
  GisEditor,
  GisLayerVector,
  GisParams,
  GisSymbol,
  GisTypes,
  GisTypesUI,
  GisUtils,
  GisViewer,

  Vcl.GisViewerWnd, Vcl.ExtCtrls ;

type
  TForm1 = class(TForm)
    GIS: TGIS_ViewerWnd;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure GISAfterPaintEvent(_sender, _canvas: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end ;

var
  Form1: TForm1;

implementation

{$R *.DFM}

type
  TRectRotated = record
    Center    : TPointF ;
    Corners   : array[0..3] of TPointF ;
    MaxRadius : Single ;
    procedure Draw(Canvas : TCanvas) ;
  end ;

var
  FAngle: Single;

  { --- SAT Logic --- }

function GetRotatedCorners(
  Center : TPointF ;
  W, H, AngleRad : Single
) : TRectRotated ;
var
  CosA, SinA, DX, DY : Single;
  I : Integer;
const
  XMult : array[0..3] of Integer = (-1, 1, 1, -1);
  YMult : array[0..3] of Integer = (-1, -1, 1, 1);
begin
  Result.Center := Center;
  Result.MaxRadius := Sqrt(Sqr(W/2) + Sqr(H/2));
  CosA := Cos(AngleRad); SinA := Sin(AngleRad);
  for I := 0 to 3 do begin
    DX := (XMult[I] * W / 2); DY := (YMult[I] * H / 2);
    Result.Corners[I].X := Center.X + (DX * CosA - DY * SinA);
    Result.Corners[I].Y := Center.Y + (DX * SinA + DY * CosA);
  end ;
end ;

function AreRectsOverlapping(
  const RectA, RectB : TRectRotated
): Boolean;

  function IsAxisSeparating(const Axis : TPointF): Boolean;
  var
    MinA, MaxA, MinB, MaxB, Dot: Single;
    I: Integer;
  begin
    MinA := (RectA.Corners[0].X * Axis.X) + (RectA.Corners[0].Y * Axis.Y); MaxA := MinA;
    for I := 1 to 3 do begin
      Dot := (RectA.Corners[I].X * Axis.X) + (RectA.Corners[I].Y * Axis.Y);
      if Dot < MinA then MinA := Dot else if Dot > MaxA then MaxA := Dot;
    end ;
    MinB := (RectB.Corners[0].X * Axis.X) + (RectB.Corners[0].Y * Axis.Y); MaxB := MinB;
    for I := 1 to 3 do begin
      Dot := (RectB.Corners[I].X * Axis.X) + (RectB.Corners[I].Y * Axis.Y);
      if Dot < MinB then MinB := Dot else if Dot > MaxB then MaxB := Dot;
    end ;
    Result := (MinA > MaxB) or (MinB > MaxA);
  end ;

var
  I, J : Integer;
  Edge, Axis : TPointF;
  DistSq : Single;
begin
  DistSq := Sqr(RectA.Center.X - RectB.Center.X) + Sqr(RectA.Center.Y - RectB.Center.Y);
  if DistSq > Sqr(RectA.MaxRadius + RectB.MaxRadius) then Exit(False);

  for I := 0 to 1 do begin
    for J := 0 to 1 do begin
      if I = 0 then
        Edge := TPointF.Create(RectA.Corners[J+1].X - RectA.Corners[J].X, RectA.Corners[J+1].Y - RectA.Corners[J].Y)
      else
        Edge := TPointF.Create(RectB.Corners[J+1].X - RectB.Corners[J].X, RectB.Corners[J+1].Y - RectB.Corners[J].Y);
      Axis := TPointF.Create(-Edge.Y, Edge.X);
      if IsAxisSeparating(Axis) then Exit(False);
    end ;
  end ;
  Result := True;
end ;

procedure TRectRotated.Draw(Canvas: TCanvas);
var
  Points : array[0..3] of TPoint;
  I : Integer;
begin
  for I := 0 to 3 do
    Points[I] := Point(Round(Corners[I].X), Round(Corners[I].Y));
  Canvas.Polygon(Points);
end ;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GIS.Lock ;
  try
    GIS.Open( TGIS_Utils.GisSamplesDataDirDownload + '\World\VisibleEarth\world_8km.jpg' );
    GIS.Zoom := GIS.Zoom * 4 ;
  finally
    GIS.Unlock ;
  end ;
end ;

procedure TForm1.GISAfterPaintEvent(_sender, _canvas: TObject);
var
  R1, R2 : TRectRotated;
  AABB1, AABB2 : TRectF;
  IsCollision, IsAABBCollision : Boolean;
  MousePos : TPoint;
  canvas : TCanvas ;

  // Helper to calculate the AABB of a rotated rectangle
  function GetAABB(const Rect : TRectRotated): TRectF;
  var
    I: Integer;
  begin
    Result := TRectF.Create(Rect.Corners[0], 0, 0);
    for I := 1 to 3 do begin
      if Rect.Corners[I].X < Result.Left   then Result.Left   := Rect.Corners[I].X;
      if Rect.Corners[I].X > Result.Right  then Result.Right  := Rect.Corners[I].X;
      if Rect.Corners[I].Y < Result.Top    then Result.Top    := Rect.Corners[I].Y;
      if Rect.Corners[I].Y > Result.Bottom then Result.Bottom := Rect.Corners[I].Y;
    end ;
  end ;

begin
  canvas := _canvas as TCanvas ;
  MousePos := GIS.ScreenToClient(Mouse.CursorPos);

  // Define Rectangles
  R1 := GetRotatedCorners(
          TPointF.Create(GIS.Width/2, GIS.Height/2), 160 * GIS.PPI/100, 90* GIS.PPI/100, FAngle
        );
  R2 := GetRotatedCorners(
          TPointF.Create(MousePos.X, MousePos.Y), 120* GIS.PPI/100, 70* GIS.PPI/100, -FAngle * 1.3
        );
  // Get AABBs
  AABB1 := GetAABB(R1);
  AABB2 := GetAABB(R2);

  // Perform Checks
  IsCollision := AreRectsOverlapping(R1, R2);
  IsAABBCollision := TRectF.Intersect(AABB1, AABB2).IsEmpty = False;

  with canvas do begin
    Pen.Color   := clSkyBlue;
    Brush.Style := bsClear;
    Pen.Style   := psDot;

    Ellipse(Round(R1.Center.X - R1.MaxRadius), Round(R1.Center.Y - R1.MaxRadius),
            Round(R1.Center.X + R1.MaxRadius), Round(R1.Center.Y + R1.MaxRadius)
           );
    Pen.Color := clSkyBlue;
    Pen.Style := psDot;

    Ellipse(Round(R2.Center.X - R2.MaxRadius), Round(R2.Center.Y - R2.MaxRadius),
            Round(R2.Center.X + R2.MaxRadius), Round(R2.Center.Y + R2.MaxRadius)
           );
    // 2. Draw AABBs (The "Ghost" boxes)
    Brush.Style := bsClear;
    Pen.Style   := psDash;
    Pen.Color   := clSilver;
    Pen.Width   := 1;

    Rectangle(Round(AABB1.Left), Round(AABB1.Top), Round(AABB1.Right), Round(AABB1.Bottom));
    Rectangle(Round(AABB2.Left), Round(AABB2.Top), Round(AABB2.Right), Round(AABB2.Bottom));

    // 3. Draw Actual Rectangles
    Pen.Style   := psSolid;
    Pen.Width   := 2;
    Brush.Style := bsSolid;

    if IsCollision then begin
      Brush.Color := TColor($CCCCFF); // Reddish
      Pen.Color := clRed;
    end
    else begin
      Brush.Color := TColor($CCFFCC); // Greenish
      Pen.Color := clGreen;
    end ;

    R1.Draw(canvas);
    R2.Draw(canvas);

    // 4. Debug Info
    Brush.Style := bsClear;
    Font.Color := clWhite;
    TextOut(10, 10, 'SAT Collision (Precise): ' + BoolToStr(IsCollision, True));
    TextOut(10, 30, 'AABB Collision (Boxy): ' + BoolToStr(IsAABBCollision, True));

    if IsAABBCollision and not IsCollision then begin
      Font.Color := clWebOrange;
      TextOut(10, 50, 'AABBs overlap, but actual shapes do not');
    end ;
  end ;
end ;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  FAngle := FAngle + 0.02; // Rotate over time
  GIS.Invalidate;    // Trigger redraw
end ;

end.
