program d6_1_group_questions;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

type
  TAnswer = 'a'..'c';
var
  Input: TStringList;
  GroupAnswers: TStringList;
  Line: String;
  AnswerFlags: array[TAnswer] of Boolean;
  Answers: String;
  Answer: TAnswer;
  SubTotal, Total: Integer;
begin
  Total := 0;
  GroupAnswers := TStringList.Create;
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Input.Append('');

    for Line in Input do
    begin
      if Line <> '' then
        GroupAnswers.Append(Line)
      else
      begin
        for Answer := Low(TAnswer) to High(TAnswer) do
          AnswerFlags[Answer] := False;

        for Answers in GroupAnswers do
          for Answer in Answers do
            AnswerFlags[Answer] := True;

        SubTotal := 0;
        for Answer := Low(TAnswer) to High(TAnswer) do
          if AnswerFlags[Answer] then
            Inc(SubTotal);
        Inc(Total, SubTotal);

        GroupAnswers.Clear;
      end;
    end;

    WriteLn('Total ', Total);

  finally
    Input.Free;
    GroupAnswers.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
