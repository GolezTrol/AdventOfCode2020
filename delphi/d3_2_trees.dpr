program d3_2_trees;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

type
  TSlope = record
    Right, Down: Integer;
  end;
var
  Slopes: array[1..5] of TSlope = (
    (Right: 1; Down: 1),
    (Right: 3; Down: 1),
    (Right: 5; Down: 1),
    (Right: 7; Down: 1),
    (Right: 1; Down: 2)
  );
var
  Input: TStringList;
  i, X, Y, PX, Count: Integer;
  Result: Int64;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Result := 1;
    for i := Low(Slopes) to High(Slopes) do
    begin
      X := 0; Y := 0;
      Count := 0;
      while True do
      begin
        Inc(Y, Slopes[i].Down);
        if Y >= Input.Count then Break;
        Inc(X, Slopes[i].Right);
        PX := X mod Input[Y].Length;
        if Input[Y][PX + 1] = '#' then
          Inc(Count);
      end;
      Result := Result * Count;
    end;

    WriteLn(Result, ' multiplied');

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
