program d4_2_passport_data_check;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, StrUtils, Classes, System.Generics.Collections,
  RegularExpressions, System.Character;

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
{
byr (Birth Year) - four digits; at least 1920 and at most 2002.
iyr (Issue Year) - four digits; at least 2010 and at most 2020.
eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
hgt (Height) - a number followed by either cm or in:
If cm, the number must be at least 150 and at most 193.
If in, the number must be at least 59 and at most 76.
hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
pid (Passport ID) - a nine-digit number, including leading zeroes.
cid (Country ID) - ignored, missing or not.
}
type
  TValidation = reference to function (Value: String): Boolean;
var
  Input: TStringList;
  Passport: String;
  Fields: TStringList;
  Validations: TDictionary<String, TValidation>;
  i, f: Integer;
  FieldIndex: Integer;
  Valid: Boolean;
  Count: Integer;
begin
  Validations := TDictionary<String, TValidation>.Create(7);
  Validations.Add('byr',
    function(Value: String): Boolean
    var v: Integer;
    begin
      v := Value.ToInteger;
      Result := (v >= 1920) and (v <= 2002);
    end);
  Validations.Add('iyr',
    function(Value: String): Boolean
    var v: Integer;
    begin
      v := Value.ToInteger;
      Result := (v >= 2010) and (v <= 2020);
    end);
  Validations.Add('eyr',
    function(Value: String): Boolean
    var v: Integer;
    begin
      v := Value.ToInteger;
      Result := (v >= 2020) and (v <= 2030);
    end);
  Validations.Add('hgt',
    function(Value: String): Boolean
    var
      u: String;
      v: Integer;
    begin
      u := RightStr(Value, 2);
      v := LeftStr(Value, Value.Length - 2).ToInteger;
      if u = 'cm' then
        Result := (v >= 150) and (v <= 193)
      else if u = 'in' then
        Result := (v >= 59) and (v <= 76)
      else
        Result := False;
    end);
  Validations.Add('hcl',
    function(Value: String): Boolean
    var
      v: Integer;
    begin
      Result :=
        (Value.Length = 7) and
        (Value[1] = '#') and
        TryStrToInt('$' + RightStr(Value, 6), v);
    end);
  Validations.Add('ecl',
    function(Value: String): Boolean
    const
      Colors: array of string = ['amb','blu','brn','gry','grn','hzl','oth'];
    var
      v: Integer;
    begin
      for v := Low(Colors) to High(Colors) do
        if Value = Colors[v] then
          Exit(True);
      Exit(False);
    end);
  Validations.Add('pid',
    function(Value: String): Boolean
    var
      c: Char;
    begin
      Result := Value.Length = 9;
      if Result then
        for c in Value do
          if not c.IsNumber then
            Exit(False);
    end);
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
        begin
          FieldIndex := Fields.IndexOfName(RequiredFields[f]);
          if (FieldIndex = -1) or
            not Validations[RequiredFields[f]](Fields.ValueFromIndex[FieldIndex]) then
          begin
            Valid := False;
            Break;
          end;
        end;

        if Valid then
          Inc(Count);

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
