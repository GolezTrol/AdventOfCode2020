program d15_1_memory_game;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, System.Generics.Collections;

type
  TNumber = type Int64;
  TTurn = type Int64;
  TMemory = TDictionary<TNumber, TTurn>;
const
  OutputTurns: array[1..3] of TTurn = (2020, 30000000, 30000001);
var
  OutputIndex: Integer;
  Input: TStringList;
  Line: String;
  Spoken: TMemory;
  Turn, LastTurn, SpokenTurn: TTurn;
  Last, Next: TNumber;
  Output, Loop: Boolean;
begin
  Loop := True;
  OutputIndex := Low(OutputTurns);
  Last := 0; LastTurn := 0;
  Spoken := TMemory.Create;
  Input := TStringList.Create;
  try
    Turn := 1;
    Input.LoadFromFile(ParamStr(1));
    Input.CommaText := Input[0];
    for Line in Input do
    begin
      Next := Line.ToInt64;
      WriteLn(Turn, ': ', Next, ' was read from the list');
      Spoken.AddOrSetValue(Last, LastTurn);
      Last := Next;
      LastTurn := Turn;
      Inc(Turn);
    end;

    while Loop do
    begin
      if Spoken.TryGetValue(Last, SpokenTurn) then
      begin
        Next := Turn - 1 - SpokenTurn;
        if Output then
          WriteLn(Turn, ': ', Last, ' was said in turn ', SpokenTurn, ', ', Next, ' turns apart. Speaking ', Next);
      end else
      begin
        Next := 0;
        if Output then
          WriteLn(Turn, ': ', Last, ' was not said before. Speaking 0');
      end;
      //WriteLn('Remembering that ', Last, ' was said in turn ', LastTurn);
      Spoken.AddOrSetValue(Last, LastTurn);
      Last := Next;
      LastTurn := Turn;
      Inc(Turn);

      Output := False;
      if OutputTurns[OutputIndex] = Turn then
      begin
        Output := True;
        if OutputIndex = High(OutputTurns) then
          Break;
        Inc(OutputIndex);
      end;
    end;

    WriteLn('done');

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;
end.
