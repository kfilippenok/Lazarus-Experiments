unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BGRABitmap;

type

  { TCache }

  { TCacheStorage }

  TCacheStorage = class
  strict private
    FBitmaps: Array of TBGRABitmap;
    function GetBitmap(Index: Integer): TBGRABitmap;
    function GetCount: Integer;
    procedure SetBitmap(Index: Integer; AValue: TBGRABitmap);
    procedure ValidateIndex(Index: Integer);
  public
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Bimaps[Index: Integer]: TBGRABitmap read GetBitmap write SetBitmap;
  end;

  { TCachedGraphic }

  TDrawProc = procedure (ACanvas: TCanvas) of object;

  TCachedGraphic = class
  const
    defUseCache = False;
    defSize = 100;
  strict private
    FUseCache: Boolean;
    FDrawProc: TDrawProc;
    FCacheStorage: TCacheStorage;
    procedure SetUseCache(AValue: Boolean);
    procedure DrawCache(ACanvas: TCanvas);
    procedure DrawPure(ACanvas: TCanvas);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(ACanvas: TCanvas);
    property UseCache: Boolean read FUseCache write SetUseCache;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btnDrawPure: TButton;
    btnDrawCache: TButton;
    Memo: TMemo;
    PaintBox: TPaintBox;
    procedure btnDrawCacheClick(Sender: TObject);
    procedure btnDrawPureClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    CachedGraphics: Array [0..100] of TCachedGraphic;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  Unix;

function GetTickCountMS: Int64;
var
  lTimeVal: TTimeVal;
begin
  fpgettimeofday(@lTimeVal, nil);
  Result := lTimeVal.tv_sec * 1000 + Round(lTimeVal.tv_usec / 1000);
end;

function GetTickCountMCS: Int64;
var
  lTimeVal: TTimeVal;
begin
  fpgettimeofday(@lTimeVal, nil);
  Result := lTimeVal.tv_sec * 1000000 + lTimeVal.tv_usec;
end;

{ TCacheStorage }

function TCacheStorage.GetBitmap(Index: Integer): TBGRABitmap;
begin
  ValidateIndex(Index);
  Result := FBitmaps[Index];
end;

function TCacheStorage.GetCount: Integer;
begin
  Result := Length(FBitmaps);
end;

procedure TCacheStorage.SetBitmap(Index: Integer; AValue: TBGRABitmap);
begin
  ValidateIndex(Index);
  if Assigned(FBitmaps[Index]) then
    FBitmaps[Index].Free;
  FBitmaps[Index] := AValue;
end;

procedure TCacheStorage.ValidateIndex(Index: Integer);
var
  OldCount, CurCount, i: Integer;
begin
  OldCount := Count;
  if Count < Index + 1 then
  begin
    SetLength(FBitmaps, Index + 1);
    if OldCount = 0 then OldCount := 1;
    CurCount := Count;
    for i := Pred(OldCount) to Pred(CurCount) do
      FBitmaps[i] := nil;
  end;
end;

destructor TCacheStorage.Destroy;
var
  i: Integer;
begin
  inherited Destroy;

  for i := 0 to Pred(Count) do
    FBitmaps[i].Free;
end;

{ TCachedGraphic }

procedure TCachedGraphic.SetUseCache(AValue: Boolean);
begin
  if AValue = FUseCache then
    Exit;

  FUseCache := AValue;
  if FUseCache then
    FDrawProc := @DrawCache
  else
    FDrawProc := @DrawPure;
end;

procedure TCachedGraphic.DrawCache(ACanvas: TCanvas);
begin
  if FCacheStorage.Bimaps[0] = nil then
  begin
    FCacheStorage.Bimaps[0] := TBGRABitmap.Create(defSize, defSize);
    DrawPure(FCacheStorage.Bimaps[0].Canvas);
  end;
  FCacheStorage.Bimaps[0].Draw(ACanvas, defSize, defSize);
end;

procedure TCachedGraphic.DrawPure(ACanvas: TCanvas);
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := clRed;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Width := 5;
  ACanvas.Rectangle(0, 0, defSize, defSize);
end;

constructor TCachedGraphic.Create;
begin
  FUseCache := defUseCache;
  FDrawProc := @DrawPure;
  FCacheStorage := TCacheStorage.Create;
end;

destructor TCachedGraphic.Destroy;
begin
  inherited Destroy;

  FreeAndNil(FCacheStorage);
end;

procedure TCachedGraphic.Draw(ACanvas: TCanvas);
begin
  FDrawProc(ACanvas);
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Length(CachedGraphics) do
  begin
    CachedGraphics[i] := TCachedGraphic.Create;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Pred(Length(CachedGraphics)) do
    FreeAndNil(CachedGraphics[i]);
end;

procedure TForm1.btnDrawPureClick(Sender: TObject);
var
  i: Integer;
  StartTime, EndTime: Int64;
begin
  for i := 0 to Pred(Length(CachedGraphics)) do
    CachedGraphics[i].UseCache := False;
  StartTime := GetTickCountMS;
  for i := 0 to Pred(Length(CachedGraphics)) do
    CachedGraphics[i].Draw(PaintBox.Canvas);
  EndTime := GetTickCountMS;
  Memo.Lines.Add('Pure: ' + IntToStr(EndTime - StartTime));
end;

procedure TForm1.btnDrawCacheClick(Sender: TObject);
var
  i: Integer;
  StartTime, EndTime: Int64;
begin
  for i := 0 to Pred(Length(CachedGraphics)) do
    CachedGraphics[i].UseCache := True;
  StartTime := GetTickCountMS;
  for i := 0 to Pred(Length(CachedGraphics)) do
    CachedGraphics[i].Draw(PaintBox.Canvas);
  EndTime := GetTickCountMS;
  Memo.Lines.Add('Cache: ' + IntToStr(EndTime - StartTime));
end;

end.

