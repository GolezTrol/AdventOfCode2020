program d17_conway_cubes_simple;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, Spring.Collections, System.Generics.Collections;

type
  TAxis = Integer;
  TPosition = record
    X, Y, Z, W: TAxis;
    function ToString: String;
  end;
  TNeighbors = array of TPosition;
  TCubes = ISet<TPosition>;

  TPocketDimension = class
    Cubes: TCubes;
    WRange: array of TAxis;
    constructor Create(W: Boolean);
    destructor Destroy; override;
    procedure Cycle;
    function NeighborsOf(Position: TPosition; IncludeSelf: Boolean): TNeighbors;
  end;

  TInput = record
    PocketDimension: TPocketDimension;
  end;

function Load(W: Boolean): TInput;
var
  Input: TStringList;
  X, Y: Integer;
  Position: TPosition;
  Line: String;
begin
  Position.Z := 0;
  Position.W := 0;
  Result.PocketDimension := TPocketDimension.Create(W);
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    for Y := 0 to Input.Count - 1 do
    begin
      Line := Input[Y];
      for X := 0 to Length(Line) - 1 do
      begin
        if Line[X+1] = '#' then
        begin
          Position.X := X;
          Position.Y := Y;
          Result.PocketDimension.Cubes.Add(Position);
        end;
      end;
    end;
  finally
    Input.Free;
  end;
end;

function Solve1(var Input: TInput): Int64;
var
  i: Integer;
begin
  for i := 0 to 6 do
  begin
    Result := Input.PocketDimension.Cubes.Count;
    WriteLn(i, ': ', Result);
    Input.PocketDimension.Cycle;
  end;
end;

procedure Solve;
var
  Input: TInput;
begin
  Input := Load(False);
  WriteLn('Part 1: ', Solve1(Input));

  Input := Load(True);
  WriteLn('Part 2: ', Solve1(Input));

  if IsDebuggerPresent then ReadLn;
end;

{ TPocketDimension }

constructor TPocketDimension.Create(W: Boolean);
begin
  if W then
  begin
    SetLength(WRange, 3);
    WRange[0] := -1;
    WRange[1] := 0;
    WRange[2] := 1;
  end
  else
  begin
    SetLength(WRange, 1);
    WRange[0] := 0;
  end;

  Cubes := TCollections.CreateSet<TPosition>;
end;

destructor TPocketDimension.Destroy;
begin
  inherited;
end;

procedure TPocketDimension.Cycle;
var
  NewCubes, EOLCubes, ToCheck: TCubes;
  RelevantCubes, Neighbors: TNeighbors;
  CubePos, NeighborPos: TPosition;
  CubeExists: Boolean;
  ActiveNeighborCount: Integer;
begin
  NewCubes := TCollections.CreateSet<TPosition>;
  EOLCubes := TCollections.CreateSet<TPosition>;
  ToCheck := TCollections.CreateSet<TPosition>;

  // Candidates for change are all active cubes, and the cubes around them, deduplicated
  for CubePos in Cubes do
  begin
    RelevantCubes := Self.NeighborsOf(CubePos, True);
    for NeighborPos in RelevantCubes do
      ToCheck.Add(NeighborPos);
  end;
  //WriteLn(ToCheck.Count, ' cubes to check, of which ', Cubes.Count, ' active');

  // Iterate through all relevant cubes, to see if they should change
  for CubePos in ToCheck do
  begin
    CubeExists := Cubes.Contains(CubePos);

    ActiveNeighborCount := 0;
    Neighbors := Self.NeighborsOf(CubePos, False);
    for NeighborPos in Neighbors do
      if Cubes.Contains(NeighborPos) then
        Inc(ActiveNeighborCount);

    if (not CubeExists) and (ActiveNeighborCount = 3) then // Spawn
    begin
      NewCubes.Add(CubePos);
    end
    else if (ActiveNeighborCount = 2) or (ActiveNeighborCount = 3) then // Keep
      // Unchanged
    else if (CubeExists) then // Destroy
      EOLCubes.Add(CubePos);
  end;

  //WriteLn(EOLCubes.Count, ' cubes become inactive. ', NewCubes.Count, ' become active');

  // Finalize the step
  for CubePos in EOLCubes do
    Cubes.Remove(CubePos);
  for CubePos in NewCubes do
    Cubes.Add(CubePos);
end;

function TPocketDimension.NeighborsOf(Position: TPosition; IncludeSelf: Boolean): TNeighbors;
var
  i: Integer;
  X, Y, Z, W: TAxis;
begin
  SetLength(Result, 81);

  i := 0;
  for X := -1 to 1 do
    for Y := -1 to 1 do
      for Z := -1 to 1 do
        for W in WRange do
          if IncludeSelf or (X<>0) or (Y<>0) or (Z<>0) or (W <> 0) then
          begin
            Result[i].X := Position.X + X;
            Result[i].Y := Position.Y + Y;
            Result[i].Z := Position.Z + Z;
            Result[i].W := Position.W + W;
            Inc(i);
          end;

  SetLength(Result, i);
end;

{ TPosition }

function TPosition.ToString: String;
begin
  Result := Format('(%d, %d, %d)', [X, Y, Z]);
end;

begin
  Solve;
end.
