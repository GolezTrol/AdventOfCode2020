program d18_math_myth;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes,
  System.Generics.Collections,
  System.Diagnostics;

type
  TInput = record
    Expressions: TArray<String>
  end;

function Load: TInput;
var
  Input: TStringList;
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

type
  TNumber = Int64;
  TOperator = Char;
  TExpression = class
    function Evaluate: Int64; virtual; abstract;
  end;

  TNumericExpression = class(TExpression)
    FValue: Int64;
    constructor Create(AValue: Int64);
    function Evaluate: Int64; override;
    function ToString: String; override;
  end;

  TComplexExpression = class(TExpression)
    Operands: TList<TExpression>;
    Operators: TList<TOperator>;
    constructor Create;
    function Evaluate: Int64; override;
    function ToString: String; override;
  end;


function Parse(Expression: String; var From: Integer): TExpression;
var
  c: Char;
  Ex: TComplexExpression;
begin
  c := Take(Expression, From);
  if CharInSet(c, ['0'..'9']) then
    Exit(TNumericExpression.Create(Ord(c) - Ord('0')));

  Ex := TComplexExpression.Create;
  Result := Ex;

  Ex.Operands.Add(Parse(Expression, From));

  c := Take(Expression, From);
  while (From < Length(Expression)) and (c <> ')') do
  begin
    Ex.Operators.Add(c);

    Ex.Operands.Add(Parse(Expression, From));

    c := Take(Expression, From);
  end;
end;

function Nest(Expression: TExpression): TExpression;
var
  Ex, Sub: TComplexExpression;
  i, s, e: Integer;
begin
  Result := Expression;
  if not (Result is TComplexExpression) then
    Exit;

  Ex := TComplexExpression(Result);


  for i := 0 to Ex.Operands.Count - 1 do
  begin
    Ex.Operands.Insert(i, Nest(Ex.Operands.Extract(Ex.Operands[i])));
  end;

  s := 0;
  e := 0;
  while e < Ex.Operators.Count do
  begin
    while (s < Ex.Operators.Count) and (Ex.Operators[s] = '*') do Inc(s);
    e := s;
    while (e < Ex.Operators.Count) and (Ex.Operators[e] = '+') do Inc(e);
    Dec(e);

    // Sequences of +'es are moved to a sub-expression, so 2*3+4+5*6 becomes 2*(3+4+5)*6
    if (s > 0) and (e >= s) then // -1 is no '+' at all, 0 means, started at the start of the expression, so no need to nest
    begin
      Sub := TComplexExpression.Create;
      for i := s to e do
      begin
        Sub.Operands.Add(Ex.Operands.Extract(Ex.Operands[s]));
        Sub.Operators.Add(Ex.Operators[s]);
        Ex.Operators.Delete(s);
      end;
      Sub.Operands.Add(Ex.Operands.Extract(Ex.Operands[s]));
      Ex.Operands.Insert(s, Sub);
    end;
    Inc(s);
    e := s;
  end;
end;

function Evaluate(Expression: String): Int64;
var
  p: Integer;
begin
  p := 1;
  Write(Expression, ' = ');
  Expression := '(' + StringReplace(Expression, ' ', '', [rfReplaceAll]) + ')';
  Result := Parse(Expression, p).Evaluate;
  WriteLn(Result);
end;

function Evaluate2(Expression: String): Int64;
var
  p: Integer;
  Ex: TExpression;
begin
  p := 1;
   WriteLn('Input : ', Expression);
  Expression := '(' + StringReplace(Expression, ' ', '', [rfReplaceAll]) + ')';
  Ex := Parse(Expression, p);
   WriteLn('Parsed: ', Ex.ToString);
  Ex := Nest(Ex); // This is the extra step, compared to Evaluate 1
   WriteLn('Nested: ', Ex.ToString);
  Result := Ex.Evaluate;
   WriteLn('Result: ', Result);
   WriteLn;
end;

function Solve1(var Input: TInput): Int64;
var
  Expression: String;
begin
  Result := 0;
  for Expression in Input.Expressions do
    Result := Result + Evaluate(Expression);
end;

function Solve2(var Input: TInput): Int64;
var
  Expression: String;
begin
  Result := 0;
  for Expression in Input.Expressions do
    Result := Result + Evaluate2(Expression);
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

{ TNumericExpression }

constructor TNumericExpression.Create(AValue: Int64);
begin
  inherited Create;
  FValue := AValue;
end;

function TNumericExpression.Evaluate: TNumber;
begin
  Result := FValue;
end;

function TNumericExpression.ToString: String;
begin
  Result := FValue.ToString;
end;

{ TComplexExpression }

constructor TComplexExpression.Create;
begin
  inherited Create;
  Operands := TObjectList<TExpression>.Create(True);
  Operators := TList<TOperator>.Create;
end;

function TComplexExpression.Evaluate: TNumber;
var
  Numi: Integer;
  Num: TNumber;
  Op: TOperator;
begin
  Numi := 0;
  Result := Operands[0].Evaluate;
  while Numi < Operators.Count do
  begin
    Op := Operators[Numi];
    Inc(Numi);
    Num := Operands[Numi].Evaluate;
    if Op = '*' then
      Result := Result * Num
    else
      Result := Result + Num;
  end;
end;

function TComplexExpression.ToString: String;
var
  i: Integer;
begin
  Result := '(';
  for i := 0 to Operators.Count - 1 do
  begin
    Result := Result + Operands[i].ToString + ' ' + Operators[i] + ' ';
  end;
  Result := Result + Operands.Last.ToString + ')';
end;

begin
  Solve;
end.
