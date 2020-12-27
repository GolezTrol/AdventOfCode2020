program d19_Satelite_love;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes,
  System.Diagnostics, System.Generics.Collections, System.Character;

type
  TInput = record
    Rules: TArray<String>;
    Inputs: TArray<String>;
    constructor Create(Lines: TArray<String>);
  end;

function Load: TInput;
var
  Input: TStringList;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Result := TInput.Create(Input.ToStringArray);
  finally
    Input.Free;
  end;
end;

type
  TRule = class
    Constant: String;
    Options: array of array of Integer;
  end;
  TRules = TObjectDictionary<Integer, TRule>;

function SubMatch(const s: String; var Position: Integer; const Rules: TRules; const RuleNr: Integer; Depth: Integer): Boolean;
var
  Start: Integer;
  Rule: TRule;
  Option, Sub: Integer;
  Indent: String;
begin
  Start := Position;
  Indent := StringOfChar(' ', Depth * 2);
  Result := Rules.TryGetValue(RuleNr, Rule);
  Assert(Result, 'Rule ' + RuleNr.ToString + ' should exist');

  //Write(Indent, 'Checking rule ', RuleNr);

  if Rule.Constant <> '' then
  begin
    Result := (Position <= Length(s)) and (s[Position] = Rule.Constant);
    Inc(Position);
    //WriteLn(' literal ', Rule.Constant, ' found: ', Result);
  end
  else
  begin
    //WriteLn;
    for Option := Low(Rule.Options) to High(Rule.Options) do
    begin
      //WriteLn(Indent, RuleNr, '.', Option);
      Result := True;
      for Sub := Low(Rule.Options[Option]) to High(Rule.Options[Option]) do
      begin
        Result := Result and SubMatch(s, Position, Rules, Rule.Options[Option][Sub], Depth+1);
        if not Result then
        begin
          //WriteLn(Indent, ' failed at sub ', Sub, ' rulenr ', Rule.Options[Option][Sub]);
          Break;
        end
      end;
      if Result then
        Break;
      Position := Start;
    end;
    //WriteLn(Indent, 'rule ', RuleNr, ' found: ', Result);
  end;
end;

function Match(const s: String; const Rules: TRules; const RuleNr: Integer): Boolean;
var
  Position: Integer;
begin
  Position := 1;
  WriteLn('matching ', s, ' against rule ', RuleNr);
  Result := SubMatch(s, Position, Rules, RuleNr, 0) and (Position > Length(s));
  WriteLn('matching ', s, ' against rule ', RuleNr, ' found: ', Result);
  WriteLn;
end;


procedure Prepare(const Input: TInput; const Rules: TRules);
var
  Rule: TRule;
  Parser: TStringList;
  Item, InputRule: String;
  Option, Index, Count: Integer;
begin
  Parser := TStringList.Create;
  Parser.NameValueSeparator := ':';
  try
    for InputRule in Input.Rules do
    begin
      Parser.Text := InputRule;
      WriteLn(Parser.Text);
      Rule := TRule.Create;
      Rules.Add(Parser.Names[0].ToInteger(), Rule);

      if Parser.ValueFromIndex[0][2] = '"' then // Awkward indexing bcs untrimmed
        Rule.Constant := Parser.ValueFromIndex[0][3]
      else
      begin
        Parser.CommaText := Parser.ValueFromIndex[0];
        Count := 1;
        for Item in Parser do
          if Item = '|' then
            Inc(Count);
        SetLength(Rule.Options, Count);
        Option := 0;
        while Parser.Count > 0 do
        begin
          Count := 0;
          for Item in Parser do
          begin
            if Item = '|' then
              Break;
            Inc(Count);
          end;
          SetLength(Rule.Options[Option], Count);
          for Index := 0 to Count -1 do
          begin
            Rule.Options[Option][Index] := Parser[0].ToInteger;
            Parser.Delete(0);
          end;
          Inc(Option);
          if Option < Length(Rule.Options) then // Delete separator
            Parser.Delete(0);
        end;

      end;

    end;
  finally
    Parser.Free;
  end;
end;

function Solve1(var Input: TInput): Int64;
var
  Rules: TRules;
  s: String;
begin
  Rules := TRules.Create;
  Prepare(Input, Rules);
  for s in Input.Inputs do
  begin
    if Match(s, Rules, 0) then
    begin
      Inc(Result);
      WriteLn(s, ' matches');
   end else
     WriteLn(s, ' does not match');

  end;
end;

function Solve2(var Input: TInput): Int64;
begin

end;

procedure Solve;
var
  Input: TInput;
begin
  try
    Input := Load;

    WriteLn('Part 1: ', Solve1(Input));
    WriteLn('Part 2: ', Solve2(Input));
  finally
    if IsDebuggerPresent then ReadLn;
  end;
end;

{ TInput }

constructor TInput.Create(Lines: TArray<String>);
var
  i: Integer;
begin
  for i := Low(Lines) to High(Lines) do
  begin
    if Lines[i] = '' then
    begin
      Rules := Copy(Lines, 0, i);
      Inputs := Copy(Lines, i+1, Length(Lines));
      Break;
    end;
  end;
end;

begin
  Solve;
end.
