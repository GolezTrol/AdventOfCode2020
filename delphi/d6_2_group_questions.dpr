program d6_2_group_questions;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

type
  TAnswer = 'a'..'z';
var
  Input: TStringList;
  GroupAnswers: TStringList;
  Line: String;
  AnswerFlags: array[TAnswer] of Boolean;
  PersonAnswerFlags: array[TAnswer] of Boolean;
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
          AnswerFlags[Answer] := True;

        for Answers in GroupAnswers do
        begin
          for Answer := Low(TAnswer) to High(TAnswer) do
            PersonAnswerFlags[Answer] := False;
          for Answer in Answers do
            PersonAnswerFlags[Answer] := True;
          for Answer := Low(TAnswer) to High(TAnswer) do
            if not PersonAnswerFlags[Answer] then
              AnswerFlags[Answer] := False;
        end;

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
