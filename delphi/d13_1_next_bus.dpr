program d13_1_next_bus;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Input: TStringList;
  Now, Later: Integer;
  Bus: String;
  BusNr: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    Now := Input[0].ToInteger;
    Input.CommaText := Input[1];

    Later := Now;
    repeat
      for Bus in Input do
      begin
        if Bus = 'x' then Continue;

        BusNr := Bus.ToInteger;

        if Later mod BusNr = 0 then
        begin
          WriteLn('Bus ', BusNr, ' will leave at ', Later, ', in ', (Later - Now), ' minutes. Answer: ', BusNr * (Later - Now));
          if IsDebuggerPresent then ReadLn;

          Exit;
        end;
      end;
      Inc(Later);
    until False;

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
