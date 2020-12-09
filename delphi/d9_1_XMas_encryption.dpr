program d9_1_XMas_encryption;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

const
  Preamble = 25;
var
  Input: TStringList;
  Line: String;
  Numbers: TArray<Int64>;
  i: Integer;
  Sum: Int64;

  function Check(const i: Integer): Boolean;
  var a, b: Integer;
  begin
    for a := i - Preamble to i - 2 do
      for b := a + 1 to i - 1 do
        if Numbers[a] + Numbers[b] = Numbers[i] then
          Exit(True);
    Exit(False);
  end;

begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    SetLength(Numbers, Input.Count);
    for i := 0 to Input.Count - 1 do
      Numbers[i] := Input[i].ToInt64();

    for i := Preamble to High(Numbers) do
    begin
      WriteLn(i);
      if not Check(i) then
      begin
        WriteLn('Failed at index ', i, ' with value ', Numbers[i]);
        Break;
      end;
    end;

    WriteLn('Done');
  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;
  
end.
