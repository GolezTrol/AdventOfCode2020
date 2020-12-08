program d8_2_debugging;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions, System.Generics.Collections;

var
  Input: TStringList;
  Code: TStringList;
  Accumulator: Int64;
  Line: String;
  Instruction: String;
  Operand: Int64;
  i, j, CodePointer: Integer;
  Org, New: String;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    for i := 0 to Input.Count -1 do
    begin
      // Patch
      Org := Input[i];
      Instruction := Copy(Org, 1, 3);
      if Instruction = 'acc' then Continue;

      if Instruction = 'nop' then
        Input[i] := 'jmp ' + Copy(Org, 4, 1000)
      else
        Input[i] := 'nop ' + Copy(Org, 4, 1000);

      // Try
      Accumulator := 0;
      CodePointer := 0;

      while CodePointer < Input.Count do
      begin
        if Input.Objects[CodePointer] <> nil then
          Break;
        Input.Objects[CodePointer] := TObject(1);

        Line := Input[CodePointer];
        Instruction := Copy(Line, 1, 3);
        Operand := Copy(Line, 4, 1000).ToInt64;
        if Instruction = 'acc' then Inc(Accumulator, Operand);

        if Instruction = 'jmp' then
          Inc(CodePointer, Operand)
        else
          Inc(CodePointer);
      end;

      if CodePointer >= Input.Count then
      begin
        WriteLn('After patching line ', i, ' the program returns');
        WriteLn(Accumulator);
        Break;
      end
      else
      begin
        // Restore
        for j := 0 to Input.Count - 1 do
          Input.Objects[j] := nil;
        Input[i] := Org;
      end;
    end;

    WriteLn('Done');

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
