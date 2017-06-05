{--------------------------------------------------------------}
program scanner;


{--------------------------------------------------------------}
{ Type Declarations }

type Symbol = string[8];
     SymTab = array[1..1000] of Symbol;
     TabPtr = ^SymTab;
    SymType = (IfSym, ElseSym, EndifSym, EndSym, Ident, Number, Op);


{--------------------------------------------------------------}
{ Definition of Keywords and Token Types }

const KWlist : array [1..4] of Symbol = ('IF', 'ELSE', 'ENDIF', 'END');


{--------------------------------------------------------------}
{ Table Lookup }

{ If the input string matches a table entry, return the entry
  index. If not, return a zero. }

function Lookup(T : TabPtr; s : string; n : integer) : integer;
var i     : integer;
    found : boolean;
begin
   found := false;
   i := n;
   while (i > 0) and not found do
      if s = T^[i] then
         found := true
      else
         dec(i);
   Lookup := i;
end;


{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
       CR = ^M;
       LF = ^J;


{--------------------------------------------------------------}
   { Variable Declarations }

var Look : char;       { Lookahead Character }
   Token : Symtype;    { Lexical Token }
   Value : string[16]; { Value of Token }


{--------------------------------------------------------------}
   { Read New Character From Input Stream }

procedure GetChar;
begin
   Read(Look);
end;


{--------------------------------------------------------------}
{ Report an Error }

procedure Error(s : string);
begin
   WriteLn;
   WriteLn(^G, 'Error: ', s, '.');
end;


{--------------------------------------------------------------}
{ Report Error and Halt }

procedure Abort(s : string);
begin
   Error(s);
   Halt;
end;


{--------------------------------------------------------------}
{ Report What Was Expected }

procedure Expected(s : string);
begin
   Abort(s + ' Expected');
end;

{--------------------------------------------------------------}
{ Match a Specific Input Character }

procedure Match(x : char);
begin
   if Look = x then GetChar
   else Expected('''' + x + '''');
end;


{--------------------------------------------------------------}
{ Recognize an Alpha Character }

function IsAlpha(c : char) : boolean;
begin
   IsAlpha := upcase(c) in ['A'..'Z'];
end;


{--------------------------------------------------------------}

{ Recognize a Decimal Digit }

function IsDigit(c : char) : boolean;
begin
   IsDigit := c in ['0'..'9'];
end;


{--------------------------------------------------------------}
{ Recognize an Alphanumeric }

function IsAlNum(c : char) : boolean;
begin
   IsAlNum := IsAlpha(c) or IsDigit(c);
end;


{--------------------------------------------------------------}
{ Recognize an Addop }

function IsAddop(c : char) : boolean;
begin
   IsAddop := c in ['+', '-'];
end;


{--------------------------------------------------------------}
{ Recognize Any Operator }

function IsOp(c : char) : boolean;
begin
   IsOp := c in ['+', '-', '*', '/', '<', '>', ':', '='];
end;


{--------------------------------------------------------------}
{ Recognize White Space }

function IsWhite(c : char) : boolean;
begin
   IsWhite := c in [' ', TAB];
end;


{--------------------------------------------------------------}
{ Skip Over Leading White Space }

procedure SkipWhite;
begin
   while IsWhite(Look) do
      GetChar;
end;


{--------------------------------------------------------------}
{ Skip Over a Comma }

procedure SkipComma;
begin
   SkipWhite;
   if Look = ',' then begin
      GetChar;
      SkipWhite;
   end;
end;


{--------------------------------------------------------------}
{ Get an Identifier }

procedure GetName;
var k : integer;
begin
   Value := '';
   if not IsAlpha(Look) then Expected('Name');
   while IsAlNum(Look) do begin
      Value := Value + UpCase(Look);
      GetChar;
   end;
   k := Lookup(Addr(KWlist), Value, 4);
   if k = 0 then
      Token := Ident
   else
      Token := SymType(k-1);
end;


{--------------------------------------------------------------}
{ Get a Number }

procedure GetNum;
begin
   Value := '';
   if not IsDigit(Look) then Expected('Integer');
   while IsDigit(Look) do begin
      Value := Value + Look;
      GetChar;
   end;
   Token := Number
end;


{--------------------------------------------------------------}
{ Get an Operator }

procedure GetOp;
begin
   Value := '';
   if not IsOp(Look) then Expected('Operator');
   while IsOp(Look) do begin
      Value := Value + Look;
      GetChar;
   end;
   Token := Op;
end;


{--------------------------------------------------------------}
{ Skip a CRLF }

procedure Fin;
begin
   if Look = CR then GetChar;
   if Look = LF then GetChar;
end;


{--------------------------------------------------------------}
{ Lexical Scanner }

procedure Scan;
var k : integer;
begin
   while Look = LF do
      Fin;
   if IsAlpha(Look) then
      GetName
   else if IsDigit(Look) then
      GetNum
   else if IsOp(Look) then
      GetOp
   else begin
      Value := Look;
      Token := Op;
      GetChar;
   end;
   SkipWhite;
end;


{--------------------------------------------------------------}
{ Output a String with Tab }

procedure Emit(s : string);
begin
   Write(TAB, s);
end;


{--------------------------------------------------------------}
{ Output a String with Tab and CRLF }

procedure EmitLn(s : string);
begin
   Emit(s);
   WriteLn;
end;


{--------------------------------------------------------------}
{ Initialize }

procedure Init;
begin
   GetChar;
end;


{--------------------------------------------------------------}
{ Main Program }

begin
   Init;
   repeat
      Scan;
      case Token of
        Ident                            : Write('Ident ');
        Number                           : Write('Number ');
        Op                               : Write('Operator ');
        IfSym, ElseSym, EndifSym, EndSym : Write('Keyword ');
      end;
      Writeln(Value);
   until Token = EndSym;
end.
{--------------------------------------------------------------}
