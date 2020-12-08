program d8_1_accumulating;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions, System.Generics.Collections;

var
  Input: TStringList;
  Accumulator: Int64;
  Line: String;
  Instruction: String;
  Operand: Int64;
  CodePointer: Integer;
begin
  Accumulator := 0;
  CodePointer := 0;
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    while CodePointer < Input.Count do
    begin
      Line := Input[CodePointer];
      if Input.Objects[CodePointer] <> nil then
      begin
        WriteLn(Accumulator);
        Break;
      end;
      Input.Objects[CodePointer] := TObject(1);

      Instruction := Copy(Line, 1, 3);
      Operand := Copy(Line, 4, 1000).ToInt64;
      if Instruction = 'acc' then Inc(Accumulator, Operand);

      if Instruction = 'jmp' then
        Inc(CodePointer, Operand)
      else
        Inc(CodePointer);
    end;

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
