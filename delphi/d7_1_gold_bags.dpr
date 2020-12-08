program d7_1_gold_bags;

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
const InputColor = 'shiny gold';
var
  Input: TStringList;
  Line: String;
  Matches: TMatchCollection;
  Match: TMatch;
  BagRule: TBagRule;
  ContentRule: TContentRule;
  Color: TColor;
  Rules: TBagRules;
  Search, Found: TStringList;
  ColorName: String;
  FoundCount: Integer;
begin
  Rules := TBagRules.Create;
  Input := TStringList.Create;
  Search := TStringList.Create;
  Search.Add(InputColor);
  Found := TStringList.Create;
  Found.Sorted := True;
  Found.Duplicates := dupIgnore;
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

    // Search is a stack of colors to search
    while Search.Count > 0 do
    begin
      ColorName := Search[Search.Count-1];
      Search.Delete(Search.Count-1);
      for BagRule in Rules do
        for ContentRule in BagRule.ContentRules do
          if ContentRule.Color.Name = ColorName then
          begin
            // Track if the found color was found already, if not, add it to
            // the stack so it is searched recursively.
            FoundCount := Found.Count;
            Found.Add(BagRule.Color.Name);
            if FoundCount < Found.Count then // Was it added?
              Search.Add(BagRule.Color.Name);
          end;
    end;

    WriteLn(Found.Count, ' types of bag can directly or indirectly contain a ', InputColor, ' bag' );


  finally
    Input.Free;
    Rules.Free;
    Search.Free;
    Found.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
