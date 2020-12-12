program d12_2_ship_way_ahoy;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Input: TStringList;
  SX, SY, DX, DY, WX, WY, Dir, Rot: Integer;
  Line: String;
  Instr: Char;
  Value: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    SX := 0; SY := 0;
    WX := 10; WY := -1;
    //Rot := 0; // E=0, S=90, W=180, N=270
    for Line in Input do
    begin
      Instr := Line[1];
      Value := Copy(Line, 2, 1000).ToInteger();

      DX := 0;
      DY := 0;
      Dir := -1;
      if Instr='L' then
      begin
        while Value > 0 do
        begin
          DX := WY;
          WY := -WX;
          WX := DX;
          Dec(Value, 90);
        end;
      end
      else if Instr='R' then
      begin
        while Value > 0 do
        begin
          DX := -WY;
          WY := WX;
          WX := DX;
          Dec(Value, 90);
        end;
      end
      else if Instr='F' then
      begin
        SX := SX + WX * Value;
        SY := SY + WY * Value;
      end
      else
      begin
        if Instr='N' then
          Dir := 270
        else if Instr='E' then
          Dir := 0
        else if Instr='S' then
          Dir := 90
        else if Instr='W' then
          Dir := 180;

         if Dir mod 180 = 0 then
           DX := 1 - Dir div 90
         else
           DY := 2 - Dir div 90;

         DX := DX * Value;
         DY := DY * Value;
         Inc(WX, DX);
         Inc(WY, DY);
      end;

      WriteLn(Line:5, ', ', Instr, Value:4, ' Dir=', Dir:3, ', Del (', DX:4, ',', DY:4, ') Way (', WX:4, ',', WY:4, ') Pos (', SX:4, ',', SY:4, ')');
    end;

    WriteLn(SX, '+', SY, ' = ', Abs(SX) + Abs(SY));

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
