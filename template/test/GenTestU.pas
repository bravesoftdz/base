{$Include GDefines.inc}
unit GenTestU;
interface

uses
  TestFramework, SysUtils, Template, BaseTypes, Basics, Timer;

type
  _MapKeyType = AnsiString;
  _MapValueType = AnsiString;

  TestGenericSort = class(TTestCase)
  private
    arr, arr2: TIndArray;
    strarr, strarr2: TAnsiStringArray;
    function ForPair(const Key: Integer; const Value: String; Data: Pointer): Boolean;
    function ForCollEl(const e: Integer; Data: Pointer): Boolean;
  protected
    procedure SetUp; override;
  public
    procedure PrepareArray;

    procedure testSortStr();
    procedure testOldSortStr();

    procedure testOldSortAcc();

    procedure testOldSortDsc();

  published
    procedure TestSortAcc();
    procedure TestSortDsc();

    procedure TestHasmMap();
    procedure TestVector();
    procedure TestLinkedList();
  end;

  _HashMapKeyType = Integer;
  _HashMapValueType = String;
  {$MESSAGE 'Instantiating TIntStrHashMap interface'}
  {$I gen_coll_hashmap.inc}
  TIntStrHashMap = class(_GenHashMap) end;

  _VectorValueType = Integer;
  {$MESSAGE 'Instantiating TIntVector interface'}
  {$I gen_coll_vector.inc}
  TIntVector = _GenVector;

  _LinkedListValueType = Integer;
  {$MESSAGE 'Instantiating TIntLinkedList interface'}
  {$I gen_coll_linkedlist.inc}
  TIntLinkedList = _GenLinkedList;

implementation

  {$MESSAGE 'Instantiating TIntStrHashMap'}
  {$I gen_coll_hashmap.inc}

  const _VectorOptions = [];
  {$MESSAGE 'Instantiating TIntVector'}
  {$I gen_coll_vector.inc}

  const _LinkedListOptions = [dsRangeCheck];
  {$MESSAGE 'Instantiating TIntLinkedList'}
  {$I gen_coll_linkedlist.inc}

var
  tmr: TTimer;
  tm: TTimeMark;
  Rnd: TRandomGenerator;

const
  TESTCOUNT = 1024*8*4;//*256;//*1000*10;
  HashMapElCnt = 1024*8;
  CollElCnt = 1024*8;
_SORT_INSERTION_THRESHOLD = 44;
//type TestData = Integer;

procedure Sort(const Count: Integer; const Data: TIndArray);
//  const _SortOptions = [soBadData];
  type _SortDataType = Integer;
  function _SortCompare2(const V1, V2: _SortDataType): Integer; {$I inline.inc}
  begin
    Result := (V1 - V2);         // As usual
  end;
  {$MESSAGE 'Instantiating sort algorithm <Integer>'}
  {$I gen_algo_sort.inc}
end;

procedure SortStr(const Count: Integer; const Data: TAnsiStringArray);
//  const _SortOptions = [soBadData];
  type _SortDataType = AnsiString;
  {$MESSAGE 'Instantiating sort algorithm <AnsiString>'}
  {$I gen_algo_sort.inc}
end;

procedure SortDsc(const Count: Integer; const Data: TIndArray);
  const _SortOptions = [soDescending];
  type _SortDataType = Integer; _SortValueType = Integer;
  function _SortGetValue2(const V: _SortDataType): _SortValueType; {$I inline.inc}
  begin
    Result := V;
  end;
  {.$DEFINE _SORTBADDATA}
  {.$DEFINE _SORTDESCENDING}
  {$MESSAGE 'Instantiating sort algorithm <Integer>'}
  {$I gen_algo_sort.inc}
end;

procedure SortRec(Count: Integer; Data: TIndArray);
type _DataType = Integer;
{$DEFINE COMPARABLE}
{$MESSAGE 'Instantiating sort algorithm <Integer>'}
{$I gen_algo_sort_rec.inc}
{$IFNDEF ForCodeNavigationWork} begin end; {$ENDIF}

// Initialize array and fill it with random values
procedure ShuffleArray(data: TIndArray); overload;
var i, v, vi: Integer;
begin
  Randomize;
  for i := 0 to TESTCOUNT-1 do data[i] := Random(TESTCOUNT);
//  for i := 0 to TESTCOUNT-1 do data[i] := Round(Sin(i/TESTCOUNT*pi*3.234)*TESTCOUNT);
(*  v := TESTCOUNT div 2;
  vi := Random(2)*2-1;
  for i := 0 to TESTCOUNT-1 do begin

    data[i] := v;
    v := v + vi;
    if i mod (TESTCOUNT div 50) = 0 then vi := Random(2)*2-1;

  end;*)
end;

// Initialize array and fill it with random values
procedure ShuffleArray(data: TAnsiStringArray); overload;
var i, j: Integer;
begin
  Randomize;
  for i := 0 to TESTCOUNT-1 do begin
    SetLength(data[i], 3 + Random(10));
    for j := 1 to Length(data[i]) do data[i] := AnsiChar(Ord('0') + Random(Ord('z')-Ord('0')));
  end;
end;

// Check if the array is sorted in ascending order
function isArraySortedAcc(arr: TIndArray): boolean;
var i: Integer;
begin
  i := Length(arr)-2;
  while (i >= 0) and (arr[i] <= arr[i+1]) do Dec(i);
  Result := i < 0;
end;

// Check if the array is sorted in ascending order
function isArraySortedStr(arr: TAnsiStringArray): boolean;
var i: Integer;
begin
  i := Length(arr)-2;
  while (i >= 0) and (arr[i] <= arr[i+1]) do Dec(i);
  Result := i < 0;
end;

// Check if the array is sorted in descending order
function isArraySortedDsc(arr: TIndArray): boolean;
var i: Integer;
begin
  i := Length(arr)-2;
  while (i >= 0) and (arr[i] >= arr[i+1]) do Dec(i);
  Result := i < 0;
end;

procedure TestGenericSort.PrepareArray;
begin
  arr := Copy(arr2, 0, Length(arr2));
  strarr := Copy(strarr2, 0, Length(strarr2));
end;

procedure TestGenericSort.testSortAcc;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  Sort(TESTCOUNT, arr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedAcc(arr), 'Sort failed');
end;

procedure TestGenericSort.testSortStr;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  SortStr(TESTCOUNT, strarr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedStr(strarr), 'Sort failed');
end;

procedure TestGenericSort.SetUp;
begin
  inherited;
  if Length(arr2) <> TESTCOUNT then SetLength(arr2, TESTCOUNT);
  ShuffleArray(arr2);
//  if Length(strarr2) <> TESTCOUNT then SetLength(strarr2, TESTCOUNT);
//  ShuffleArray(strarr2);
end;

procedure TestGenericSort.testOldSortAcc;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  Basics.QuickSortInt(TESTCOUNT, arr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedAcc(arr), 'Sort failed');
end;

procedure TestGenericSort.testOldSortStr;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  Basics.QuickSortStr(TESTCOUNT, strarr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedStr(strarr), 'Sort failed');
end;

procedure TestGenericSort.testOldSortDsc;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  Basics.QuickSortIntDsc(TESTCOUNT, arr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedDsc(arr), 'Sort failed');
end;

procedure TestGenericSort.testSortDsc;
begin
  PrepareArray;
  tmr.GetInterval(tm, True);
  SortDsc(TESTCOUNT, arr);
  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
  Check(isArraySortedDsc(arr), 'Sort failed');
end;

function TestGenericSort.ForPair(const Key: Integer; const Value: String; Data: Pointer): Boolean;
begin
//  Writeln(Key, ' = ', Value);
  Check((Key) = StrToInt(Value), 'Value check in for each fail');
end;

function TestGenericSort.ForCollEl(const e: Integer; Data: Pointer): Boolean;
begin
  Check(e = Rnd.RndI(CollElCnt), 'Value check in for each fail');
end;

procedure TestGenericSort.TestHasmMap;
var i, cnt, t: NativeInt; Map: TIntStrHashMap;
begin
  tmr.GetInterval(tm, True);
  Map := TIntStrHashMap.Create(256);

  cnt := 0;
  for i := 0 to HashMapElCnt-1 do begin
    t := Random(HashMapElCnt);

    if not Map.ContainsKey(t) then Inc(cnt);

    Map[t] := IntToStr(t);
    Check(Map.ContainsKey(t) and Map.ContainsValue(IntToStr(t)));
  end;

  Map.ForEach(ForPair, nil);

  Check(Map.Count = cnt);

  Map.Clear;
  Check(Map.IsEmpty);
  Map.Free;

  Writeln(GetName, ': ', tmr.GetInterval(tm, True):3:3);
end;

procedure TestGenericSort.TestLinkedList;
var Coll: TIntLinkedList; i, cnt, t: Integer;
begin
  Coll := TIntLinkedList.Create();
  {$I TestList.inc}
end;

procedure TestGenericSort.TestVector;
var Coll: TIntVector; i, cnt, t: Integer;

begin
  Coll := TIntVector.Create();
  {$I TestList.inc}
end;

initialization
  tmr := TTimer.Create(nil);
  Rnd := TRandomGenerator.Create();
  RegisterTest(TestGenericSort.Suite);

finalization
  tmr.Free();
  Rnd.Free();

end.
