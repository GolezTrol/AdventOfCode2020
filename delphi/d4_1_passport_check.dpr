program d4_1_passport_check;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

{
byr (Birth Year)
iyr (Issue Year)
eyr (Expiration Year)
hgt (Height)
hcl (Hair Color)
ecl (Eye Color)
pid (Passport ID)
cid (Country ID)
}

const
  RequiredFields: array[1..7] of String = (
    'byr','iyr','eyr','hgt','hcl','ecl','pid' //,'cid'
  );
var
  Input: TStringList;
  Passport: String;
  Fields: TStringList;
  i, f: Integer;
  Valid: Boolean;
  Count: Integer;
begin
  Input := TStringList.Create;
  Fields := TStringList.Create;
  Fields.NameValueSeparator := ':';
  Fields.Delimiter := ' ';
  try
    Input.LoadFromFile(ParamStr(1));

    Passport := '';
    Count := 0;
    for i := 0 to Input.Count do
    begin
      if (i = Input.Count) or (Input[i] = '') then
      begin
        Fields.DelimitedText := Passport;
        Valid := True;
        for f := Low(RequiredFields) to High(RequiredFields) do
          if Fields.IndexOfName(RequiredFields[f]) = -1 then
          begin
            Valid := False;
            Break;
          end;

        if Valid then Inc(Count);

        WriteLn(Fields.Text, 'Valid: ', Valid, sLineBreak);

        Passport := '';
      end
      else
        Passport := Passport + Input[i] + ' ';


    end;

    WriteLn(Count, ' valid password');

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
