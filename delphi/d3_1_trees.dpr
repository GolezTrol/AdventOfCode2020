program d3_1_trees;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Input: TStringList;
  Line: String;
  X, Y, PX, Count: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Input.Delete(0);

    X := 0;
    Count := 0;
    for Line in Input do
    begin
      Inc(X, 3);
      PX := X mod Line.Length;
      if Line[PX + 1] = '#' then
        Inc(Count);
    end;

    WriteLn(Count, ' trees');

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
