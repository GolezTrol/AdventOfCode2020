program d12_1_ship_ahoy;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Input: TStringList;
  SX, SY, DX, DY, X, Y, Rot, Dir: Integer;
  Line: String;
  Instr: Char;
  Value: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    SX := 0; SY := 0;
    X := SX; Y := SY;
    Rot := 0; // E=0, S=90, W=180, N=270
    for Line in Input do
    begin
      Instr := Line[1];
      Value := Copy(Line, 2, 1000).ToInteger();

      DX := 0;
      DY := 0;
      Dir := Rot;
      if Instr='L' then
        Rot := Rot - Value
      else if Instr='R' then
        Rot := Rot + Value
      else
      begin
        if Instr='N' then
          Dir := 270
        else if Instr='E' then
          Dir := 0
        else if Instr='S' then
          Dir := 90
        else if Instr='W' then
          Dir := 180
        else if Instr='F' then
          Dir := Dir
        else
          WriteLn(Instr, ', ', Line);

         if Dir mod 180 = 0 then
           DX := 1 - Dir div 90
         else
           DY := 2 - Dir div 90;

         DX := DX * Value;
         DY := DY * Value;
         Inc(X, DX);
         Inc(Y, DY);
      end;

      while Rot < 0 do Inc(Rot, 360);
      Rot := Rot mod 360;

      WriteLn(Line:5, ', ', Instr, Value:4, ' Rot=', Rot:3, ' Dir=', Dir:3, ', Del (', DX:4, ',', DY:4, ') Pos (', X:4, ',', Y:4, ')');
    end;

    WriteLn(X, '+', Y, ' = ', Abs(X) + Abs(Y));

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
