program d2_1_passwords;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Report: TStringList;
  LineParser: TRegEx;
  i: Integer;
  Match: TMatch;
  Pass: String;
  Min, Max, Count, Valid: Integer;
  c, PasswordChar: Char;
begin
  Valid := 0;
  Report := TStringList.Create;
  try
    Report.LoadFromFile(ParamStr(1));
    LineParser := TRegEx.Create('(?P<min>\d+)-(?P<max>\d+)\s(?P<char>.)[:]\s(?P<pass>.*)');
    for i := 0 to Report.Count - 1 do
    begin
      Match := LineParser.Match(Report[i]);
      //WriteLn(Format('"%s" -> %s{%s,%s} "%s"', [Report[i], Match.Groups['char'].Value, Match.Groups['min'].Value, Match.Groups['max'].Value, Match.Groups['pass'].Value]));
      Count := 0;
      Min := Match.Groups['min'].Value.ToInteger;
      Max := Match.Groups['max'].Value.ToInteger;
      PasswordChar := Match.Groups['char'].Value[1];
      Pass := Match.Groups['pass'].Value;
      for c in Pass do
        if c = PasswordChar then
          Inc(Count);

      if (Count >= Min) and (Count <= Max) then
        Inc(Valid);
    end;
  finally
    Report.Free;
  end;

  WriteLn('Valid passwords:', Valid);

  if IsDebuggerPresent then ReadLn;
  
end.
