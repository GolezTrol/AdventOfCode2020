program d11_game_of_seats;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

const
  Half = Char($2580); // Upper front, lower back
const Halfs: array[0..3] of Char = (
  ' ',
  Char($2580), // Upper
  Char($2584), // Lower
  Char($2588) // Full
);

type
  TTile = (tNone, TFloor, TEmpty, TOccupied);
const
  TileChar: array[TTile] of Char = (' ', '.', 'L', '#');
const
  Esc = Char($1B);
type
  TOdd = 0..1;
  TModified = Boolean;
const
  Colors: array[TOdd, TModified, TTile] of string = (
    (
      (Esc+'[30m',Esc+'[34m',Esc+'[32m',Esc+'[31m'),
      (Esc+'[90m',Esc+'[94m',Esc+'[92m',Esc+'[91m')
    ),
    (
      (Esc+'[40m',Esc+'[44m',Esc+'[42m',Esc+'[41m'),
      (Esc+'[100m',Esc+'[104m',Esc+'[102m',Esc+'[101m')
    )
  );

type
  TCell = record
    Tile, TileBefore: TTile;
    Adjacent: Integer;
    function Modified: Boolean;
  end;
  TCells = array of TCell;
  TGrid = record
  private
    function GetCell(X, Y: Integer): TCell;
    procedure SetCell(X, Y: Integer; const Value: TCell);
    function TryIndex(X, Y: Integer; out Index: Integer): Boolean;
  public
    Width, Height: Integer;
    Cells: TCells;
    Stable: Boolean;
    constructor Create(Width, Height: Integer);
    property Cell[X, Y: Integer]: TCell read GetCell write SetCell;
    procedure SetTile(X, Y: Integer; const Value: TTile);
    function WasChanged(X, Y: Integer): Boolean;
    procedure Step(LineOfSight: Boolean);
  end;

function BuildGridStr(const Grid: TGrid): String;
var
  X, Y: Integer;
  c1, c2: TCell;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try

    Y := 0;
    while Y < Grid.Height do
    begin
      for X := 0 to Grid.Width - 1 do
      begin
        c1 := Grid.Cell[X, Y];
        c2 := Grid.Cell[X, Y+1];
        sb.Append(Colors[0, c1.Modified, c1.Tile]).Append(Colors[1, c2.Modified, c2.Tile]).Append(Half);
      end;
      sb.Append(sLineBreak);
      Inc(Y, 2);
    end;

    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function LoadGrid(Input: TStringList): TGrid;
var
  x, y: Integer;
  Tile: TTile;
  Cell: TCell;
begin
  Result := TGrid.Create(Input[0].Length, Input.Count);
  for y := 0 to Input.Count -1 do
    for x := 0 to Input[y].Length - 1 do
      for Tile := Low(TTile) to High(TTile) do
        if Input[y][x+1] = TileChar[Tile] then
        begin
          Cell.Tile := Tile;
          Result.SetCell(X, Y, Cell);
          Break;
        end;
end;

var
  Input: TStringList;

{ TGrid }

constructor TGrid.Create(Width, Height: Integer);
begin
  Self.Width := Width;
  Self.Height := Height;
  SetLength(Cells, Width * Height);
end;

function TGrid.GetCell(X, Y: Integer): TCell;
var
  Index: Integer;
begin
  Result.Tile := tNone;

  if TryIndex(X, Y, Index) then
    Exit(Cells[Index]);
end;

procedure TGrid.SetCell(X, Y: Integer; const Value: TCell);
var
  Index: Integer;
begin
  if TryIndex(X, Y, Index) then
  begin
    Cells[Index] := Value;
  end;
end;

procedure TGrid.SetTile(X, Y: Integer; const Value: TTile);
var
  Index: Integer;
begin
  if TryIndex(X, Y, Index) then
  begin
    Cells[Index].TileBefore := Cells[Index].Tile;
    Cells[Index].Tile := Value;
  end;
end;

procedure TGrid.Step(LineOfSight: Boolean);
var
  X, Y: Integer;
  dx, dy: Integer;
  a: Integer;
  c: TCell;
  j: Integer;
  Index: Integer;
begin
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
    begin
      a := 0;
      for dy := -1 to 1 do
        for dx := -1 to 1 do
          if (dx <> 0) or (dy <> 0) then
          begin
            j := 1;
            while TryIndex(X+(dx*j), Y+(dy*j), Index) do
            begin
              if Cells[Index].Tile = tOccupied then
              begin
                Inc(a);
                Break;
              end
              else if Cells[Index].Tile = TEmpty then
                Break;
              Inc(j);
              if not LineOfSight then
                Break;
            end;
          end;
      c := Cell[X,Y];
      c.Adjacent := a;
      Cell[X, Y] := c;
    end;
  Stable := True;
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
    begin
      c := Cell[X,Y];
      if (c.Tile = tEmpty) and (c.Adjacent = 0) then
        SetTile(X, Y, tOccupied)
      else if (c.Tile = tOccupied) and (c.Adjacent >= 4 + Ord(LineOfSight)) then
        SetTile(X, Y, tEmpty)
      else
        SetTile(X, Y, c.Tile);

      c := Cell[X,Y];

      if c.Modified then
        Stable := False;
    end;

end;

function TGrid.TryIndex(X, Y: Integer; out Index: Integer): Boolean;
begin
  Index := -1;
  Result := (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height);
  if Result then
    Index := Y * Width + X;
end;

function TGrid.WasChanged(X, Y: Integer): Boolean;
var
  Index: Integer;
begin
  Result := TryIndex(X, Y, Index) and (Cells[Index].Tile <> Cells[Index].TileBefore);
end;

{ TCell }

function TCell.Modified: Boolean;
begin
  Result := Tile <> TileBefore;
end;

procedure DoDay(DayNr: Integer; out StepCount, Occupied: Integer);
var
  Grid: TGrid;
  X, Y: Integer;
  c: TCell;
begin
  Grid := LoadGrid(Input);
  StepCount := 0;

  Write(Esc, '[?1049h');

  repeat
    Grid.Step(DayNr = 2);
    Inc(StepCount);
    Write(ESC, '[0;0H', Esc, '[40m', Esc, '[2J'); // Reset cursor position, color, and clear screen
    WriteLn(BuildGridStr(Grid));
    Sleep(50);
  until Grid.Stable;

  Occupied := 0;
  for Y := 0 to Grid.Height - 1 do
    for X := 0 to Grid.Width - 1 do
    begin
      c := Grid.Cell[X,Y];
      if c.Tile = tOccupied then
        Inc(Occupied);
    end;

  Write(Esc, '[?1049l');
end;

var
  Day, StepCount, Occupied: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    for Day := 1 to 2 do
    begin
      DoDay(Day, StepCount, Occupied);
      WriteLn(Esc, '[93m', 'Day ', Day, '. Stable after ', StepCount, ' steps. ', Occupied, ' seats occupied.');
      Sleep(1000);
    end;

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
