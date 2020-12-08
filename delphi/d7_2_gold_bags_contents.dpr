program d7_2_gold_bags_contents;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions, System.Generics.Collections;

type
  TColor = record
    Modifier: String;
    Base: String;
    Name: String;
    constructor Create(const AModifier, ABase: String);
  end;
  TContentRule = record
    Color: TColor;
    Quantity: Integer;
  end;

  TContentRules = TArray<TContentRule>;

  TBagRule = record
    Color: TColor;
    ContentRules: TContentRules;
  end;

  TBagRules = TList<TBagRule>;
  TSearchStack = TList<TContentRule>;

constructor TColor.Create(const AModifier, ABase: String);
begin
  Modifier := AModifier;
  Base := ABase;
  Name := Modifier + ' ' + Base;
end;

const Pattern =
  // Isolate an optional count, a color and the two parts of it, and an optional terminator.
  // No terminator: Rule identifier
  // Terminator, but no count: no bags (could also check if color 1 = 'no'
  '(?:(?P<count>\d+)\s)?  (?P<color> (?P<color1>\w+)\s(?P<color2>\w+) ) \sbag[s]? (?P<terminator>[,\.]?)';
var
  Input: TStringList;
  Matches: TMatchCollection;
  Match: TMatch;
  BagRule: TBagRule;
  ContentRule: TContentRule;
  Color: TColor;
  Rules: TBagRules;
  Count: Integer;

function GetRequiredBagCount(Color: TColor): Integer;
var
  Rule: TBagRule;
  ContentRule: TContentRule;
begin
  Result := 0;
  for Rule in Rules do // Could be optimized by changing it to a dictionary
    if Rule.Color.Name = Color.Name then
      for ContentRule in Rule.ContentRules do
        Result := Result + ContentRule.Quantity + ContentRule.Quantity * GetRequiredBagCount(ContentRule.Color);
end;

begin
  Rules := TBagRules.Create;
  Input := TStringList.Create;

  try
    Input.LoadFromFile(ParamStr(1));

    Matches := TRegEx.Matches(Input.Text, Pattern, [roIgnorePatternSpace]);
    for Match in Matches do
    begin
      Color := TColor.Create(Match.Groups['color1'].Value, Match.Groups['color2'].Value);
      if Match.Groups['terminator'].Value = '' then
      begin
        //WriteLn('Bags with color "', Match.Groups['color'].Value, '" may contain:');

        BagRule.Color := Color;
        SetLength(BagRule.ContentRules, 0);
      end;
      if Match.Groups['terminator'].Value <> '' then
      begin
        //WriteLn('- ', Match.Groups['count'].Value, ' bags of color "',  Match.Groups['color'].Value, '"');

        if Match.Groups['count'].Value <> '' then
        begin
          ContentRule.Quantity := Match.Groups['count'].Value.ToInteger;
          ContentRule.Color := Color;

          SetLength(BagRule.ContentRules, Length(BagRule.ContentRules)+1);
          BagRule.ContentRules[High(BagRule.ContentRules)] := ContentRule;
        end;
      end;
      if Match.Groups['terminator'].Value = '.' then
      begin
        //WriteLn;
        Rules.Add(BagRule);
      end;
    end;

    Color := TColor.Create('shiny', 'gold');
    Count := GetRequiredBagCount(Color);

    WriteLn(Count, ' types of bag can directly or indirectly contain a ', Color.Name, ' bag' );

  finally
    Input.Free;
    Rules.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
