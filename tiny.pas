{--------------------------------------------------------------}
program TINY;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
       CR = ^M;
       LF = ^J;

{--------------------------------------------------------------}
   { Variable Declarations }

var Look   : char;       { Lookahead Character }
    LCount : integer;    { Label Counter }

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
{ Recognize a Mulop }
function IsMulop(c : char) : boolean;
begin
   IsMulop := c in ['*', '/'];
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
   if Look <> x then Expected('''' + x + '''');
   GetChar;
   SkipWhite;
end;


{--------------------------------------------------------------}
{ Skip a CRLF }

procedure Fin;
begin
   if Look = CR then GetChar;
   if Look = LF then GetChar;
   SkipWhite;
end;


{------------------------------------------------------------------------------}
{ Generate a Unique Label }

function NewLabel : string;
var S : string;
begin
   Str(LCount, S);
   NewLabel := 'L' + S;
   Inc(LCount);
end;


{------------------------------------------------------------------------------}
{ Post a Label To Output }

procedure PostLabel(L : string);
begin
   WriteLn(L, ':');
end;


{--------------------------------------------------------------}
{ Get an Identifier }

function GetName : char;
begin
   if not IsAlpha(Look) then Expected('Name');
   GetName := UpCase(Look);
   GetChar;
end;


{--------------------------------------------------------------}
{ Get a Number }

function GetNum : char;
begin
   if not IsDigit(Look) then Expected('Integer');
   GetNum := Look;
   GetChar;
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
{ Write Header Info }

procedure Header;
begin
   WriteLn('WARMST', TAB, 'EQU $A01E');
end;


{--------------------------------------------------------------}
{ Write the Prolog }

procedure Prolog;
begin
   PostLabel('MAIN');
end;


{--------------------------------------------------------------}
{ Write the Epilog }

procedure Epilog;
begin
   EmitLn('DC WARMST');
   EmitLn('END MAIN');
end;


{--------------------------------------------------------------}
{ Parse and Translate a Main Program }

procedure Main;
begin
   Match('b');
   Prolog;
   Match('e');
   Epilog;
end;


{--------------------------------------------------------------}
{ Allocate Storage for a Variable }

procedure Alloc(N : char);
begin
   WriteLn(N, ':', TAB, 'DC 0');
end;


{--------------------------------------------------------------}
{ Process a Data Declaration }

procedure Decl;
var Name : char;
begin
   Match('v');
   Alloc(GetName);
end;


{--------------------------------------------------------------}
{ Parse and Translate Global Declarations }

procedure TopDecls;
begin
   while Look <> 'b' do
      case Look of
        'v' : Decl;
      else Abort('Unrecognized Keyword ''' + Look + '''');
      end;
end;


{--------------------------------------------------------------}
{ Parse and Translate a Program }

procedure Prog;
begin
   Match('p');
   Header;
   TopDecls;
   Main;
   Match('.');
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
   Prog;
   if Look <> LF then Abort('Unexpected data after ''.''');
end.
{--------------------------------------------------------------}
