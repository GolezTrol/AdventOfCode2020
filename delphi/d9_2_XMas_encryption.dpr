program d9_2_XMas_encryption;

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
  Total, Min, Max, Value: Int64;

  function Check(const Index: Integer): Boolean;
  var a, b: Integer;
  begin
    for a := Index - Preamble to i - 2 do
      for b := a + 1 to i - 1 do
        if Numbers[a] + Numbers[b] = Numbers[Index] then
          Exit(True);
    Exit(False);
  end;

  function CheckSequence(const Index: Integer; const Value: Int64; out Min, Max: Int64): Boolean;
  var
    a: Integer;
    Total: Int64;
  begin
    Total := 0;
    Min := Numbers[i];
    Max := Numbers[i];
    for a := Index to High(Numbers) do
    begin
      Total := Total + Numbers[a];
      if Numbers[a] < Min then Min := Numbers[a];
      if Numbers[a] > Max then Max := Numbers[a];

      if (a-i >= 2) and (Total = Value) then
        Exit(True);
    end;

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
      if not Check(i) then
      begin
        Value := Numbers[i];
        WriteLn('1: Failed at index ', i, ' with value ', Numbers[i]);
        Break;
      end;
    end;

    for i := 0 to High(Numbers)-1 do
    begin
      if CheckSequence(i, Value, Min, Max) then
      begin
        WriteLn('2: Sequence at index ', i, ' with low ', Min, ' and high ', Max, ' sum ', (Min+Max));
        Break;
      end;
    end;

    WriteLn('Done');
  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;
  
end.
