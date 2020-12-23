program d18_math_myth;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, System.Generics.Collections;

type
  TNumber = Int64;
  TInput = record
    Expressions: TArray<String>
  end;

function Load: TInput;
var
  Input: TStringList;
  Line: String;
  i: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Result.Expressions := Input.ToStringArray;
  finally
    Input.Free;
  end;
end;

function Take(Exp: String; var p: Integer): Char;
begin
  Result := Exp[p];
  Inc(p);
end;

function EvaluateSub(Exp: String; var p: Integer): TNumber;
var
  Num: TNumber;
  c, Op: Char;
begin
  c := Take(Exp, p);
 // Write('> ', c, ' ');

  if CharInSet(c, ['0'..'9']) then
    Exit(Ord(c) - Ord('0'));

  Result := EvaluateSub(Exp, p);

  while p <= Length(Exp) do
  begin
    Op := Take(Exp, p);
    if Op = ')' then
      Break;

    Num := EvaluateSub(Exp, p);
    //Write(Result, Op, Num, ' . . ');
    //Write(Result, ' ', Op, ' ', Num);
    if Op = '*' then
      Result := Result * Num
    else
      Result := Result + Num;
  end;
 // WriteLn('< = ', Result);
end;

function Evaluate(Exp: String): TNumber;
var
  p: Integer;
begin
  p := 1;
  Exp := StringReplace(Exp, ' ', '', [rfReplaceAll]);
  Result := EvaluateSub('('+Exp+')', p);
  WriteLn('Result of ', Exp, ' = ', Result);
  WriteLn;
end;


function Solve1(var Input: TInput): Int64;
var
  Expression: String;
begin
  Result := 0;
  for Expression in Input.Expressions do
    Inc(Result, Evaluate(Expression));
end;

function Solve2(var Input: TInput): Int64;
begin
end;

procedure Solve;
var
  Input: TInput;
begin
  Input := Load;

  WriteLn('Part 1: ', Solve1(Input));
  WriteLn('Part 2: ', Solve2(Input));
  if IsDebuggerPresent then ReadLn;
end;

begin
  Solve;
end.
