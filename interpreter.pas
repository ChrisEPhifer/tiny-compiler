{--------------------------------------------------------------}
program interpreter;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
       CR = ^J;

{--------------------------------------------------------------}
   { Variable Declarations }

var Look : char;       { Lookahead Character }
   Table : Array['A'..'Z'] of integer;

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
{ Recognize and Skip Over a Newline }

procedure Newline;
begin
   if Look = CR then 
      GetChar;
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
{ Match a Specific Input Character }

procedure Match(x : char);
begin
   if Look <> x then Expected('''' + x + '''')
   else begin
      GetChar;
      SkipWhite;
   end;
end;


{--------------------------------------------------------------}
{ Get an Identifier }

function GetName : char;
begin
   if not IsAlpha(Look) then Expected('Name');
   GetName := UpCase(Look);
   GetChar;
   SkipWhite;
end;


{--------------------------------------------------------------}
{ Get a Number }

function GetNum : integer;
var Value : integer;
begin
   Value := 0;
   if not IsDigit(Look) then Expected('Integer');
   while IsDigit(Look) do begin
      Value := 10 * Value + Ord(Look) - Ord('0');
      GetChar;
   end;
   GetNum := Value;
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
{ Parse and Translate a Math Factor }

function Expression : integer; Forward;

   function Factor : integer;
   begin
      if Look = '(' then begin
         Match('(');
         Factor := Expression;
         Match(')');
      end
   else if IsAlpha(Look) then
      Factor := Table[GetName]
   else
      Factor := GetNum;
   end;


{--------------------------------------------------------------}
{ Parse and Translate a Math Term }

function Term : integer;
var Value : integer;
begin
   Value := Factor;
   while Look in ['*', '/'] do begin
      case Look of
        '*' : begin
           Match('*');
           Value := Value * Factor;
        end;
        '/' : begin
           Match('/');
           Value := Value div Factor;
        end;
      end;
   end;
   Term := Value;
end;


{--------------------------------------------------------------}
{ Parse and Translate an Expression }

function Expression : integer;
var Value : integer;
begin
   if IsAddop(Look) then
      Value := 0
   else
      Value := Term;
   while IsAddop(Look) do begin
      case Look of
        '+' : begin
           Match('+');
           Value := Value + Term;
        end;
        '-' : begin
           Match('-');
           Value := Value - Term;
        end;
      end;
   end;
   Expression := Value;
end;


{--------------------------------------------------------------}
{ Parse and Translate an Assignment Statement }

procedure Assignment;
var Name : char;
begin
   Name := GetName;
   Match('=');
   Table[Name] := Expression;
end;


{--------------------------------------------------------------}
{ Input Routine }

procedure Input;
begin
   Match('?');
   Read(Table[GetName]);
end;


{--------------------------------------------------------------}
{ Output Routine }

procedure Output;
begin
   Match('!');
   WriteLn(Table[GetName]);
end;


{--------------------------------------------------------------}
{ Initialize the Variable Area }

procedure InitTable;
var i : char;
begin
   for i := 'A' to 'Z' do
      Table[i] := 0;
end;


{--------------------------------------------------------------}
{ Initialize }

procedure Init;
begin
   InitTable;
   GetChar;
end;


{--------------------------------------------------------------}
{ Main Program }

begin
   Init;
   repeat
      case Look of
        '?' : Input;
        '!' : Output;
      else Assignment;
      end;
      Newline;
   until Look = '.';
end.
{--------------------------------------------------------------}
