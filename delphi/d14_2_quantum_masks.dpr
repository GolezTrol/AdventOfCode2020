program d14_2_quantum_masks;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, System.Generics.Collections;

type
  TAddress = Int64;
  TAddresses = array of TAddress;
  TValue = Int64;
  TValues = array of TValue;
  TMask = record
    OrMasks: TAddresses;
    ClearMask: TAddress;
    constructor Create(const Mask: String);
    function ApplyTo(const Address: TAddress): TAddresses;
  end;

  TMemory = class(TDictionary<TAddress, TValue>)
    procedure Write(const Address: TAddress; const Value: TValue; const Mask: TMask);
  end;

function SetBit(const Value: TValue; const Index: Integer; const Bit: Boolean): TValue;
var
  Rec: Int64Rec;
  h, i: Integer;
begin
  Rec := Int64Rec(Value);
  i := Index;
  h := 0;
  if i > 31 then
  begin
    i := i - 32;
    h := 1;
  end;
  if Bit then
    Rec.Cardinals[h] := Rec.Cardinals[h] or (Cardinal(1) shl i)
  else
    Rec.Cardinals[h] := Rec.Cardinals[h] and not (Cardinal(1) shl i);
  Result := Int64(Rec);
end;

function AsBin(Value: TValue): String;
var
  i: Integer;
begin
  SetLength(Result, 36);
  for i := 0 to 35 do
    if Value and SetBit(0, i, True) <> 0 then
      Result[36-i] := '1'
    else
      Result[36-i] := '0';
end;

{ TMask }

function TMask.ApplyTo(const Address: TAddress): TAddresses;
var
  i: Integer;
begin
  SetLength(Result, Length(OrMasks));
  for i := Low(OrMasks) to High(OrMasks) do
    Result[i] := (Address and ClearMask) or OrMasks[i];
end;

constructor TMask.Create(const Mask: String);
var
  OrValue: TAddress;
  VarValue: TAddress;
  i: Integer;
  c: Char;
  VarBits, VarCount: Integer;
  VarIndex: array of Integer;
  v: Integer;
begin
  OrValue := 0;
  VarBits := 0;
  SetLength(VarIndex, 35);
  ClearMask := not 0;
  for i := 0 to 35 do
  begin
    c := Mask[36-i];
    if c = '1' then
      OrValue := SetBit(OrValue, i, True)
    else if c = 'X' then
    begin
      VarIndex[VarBits] := i;
      Inc(VarBits);
      ClearMask := SetBit(ClearMask, i, False);
    end;
  end;
  if VarBits >= 31 then
    raise Exception.CreateFmt('Unexpected number of variable bits in %s. Change to 64 bit-compatible shifting.', [Mask]);
  VarCount := 1 shl VarBits;

  SetLength(OrMasks, VarCount);
  for v := 0 to VarCount - 1 do
  begin
    VarValue := OrValue;
    for i := 0 to VarBits do
      if v and (1 shl i) > 0 then
        VarValue := SetBit(VarValue, VarIndex[i], True);
    OrMasks[v] := VarValue;
  end;
end;

{ TMemory }

procedure TMemory.Write(const Address: TAddress; const Value: TValue; const Mask: TMask);
var
  Masked: TAddress;
begin
  for Masked in Mask.ApplyTo(Address) do
  begin
    //WriteLn(Address, ' -> ', Masked, ', ', AsBin(Address), ' -> ', AsBin(Masked));
    Self.AddOrSetValue(Masked, Value);
  end;
end;

var
  Input: TStringList;
  i, p: Integer;
  Mask: TMask;
  Memory: TMemory;
  Address: TAddress;
  Value: TValue;
  Sum: TValue;
  Line: String;
begin
  Memory := TMemory.Create();
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    for i := 0 to Input.Count - 1 do
    begin
      Line := Input[i];

      if Copy(Line, 1, 7) = 'mask = ' then
        Mask := TMask.Create(Copy(Line, 8, 36))
      else
      begin
        p := Pos(']', Line);
        Address := Copy(Line, 5, p - 5).ToInt64();
        Value := Copy(Line, p + 4, 100).ToInt64();
        Memory.Write(Address, Value, Mask);
      end;

    end;

    Sum := 0;
    for Value in Memory.Values do
      Sum := Sum + Value;

    WriteLn(Sum);

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;
end.
