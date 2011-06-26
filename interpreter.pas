{--------------------------------------------------------------}
program interpreter;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
const LF = '\n';

{--------------------------------------------------------------}
{ Variable Declarations }

var Look : char; { Lookahead Character }
   Table : Array['A'..'Z'] of integer; { Variable table }

{--------------------------------------------------------------}
{ Initialize the Variable Area }
   
procedure InitTable;
var i : char;
begin
   for i := 'A' to 'Z' do
	  Table[i] := 0;
end; { InitTable }

{--------------------------------------------------------------}
{ Read New Character From Input Stream }

procedure GetChar;
begin
   Read(Look);
end; { GetChar }

{--------------------------------------------------------------}
{ Report an Error }

procedure Error(s : string);
begin
   WriteLn;
   WriteLn(^G, 'Error: ', s, '.');
end; { Error }

{--------------------------------------------------------------}
{ Report Error And Halt }

procedure Abort(s : string);
begin
   Error(s);
   Halt;
end; { Abort }

{--------------------------------------------------------------}
{ Report What Was Expected }

procedure Expected(s : string);
begin
   Abort(s + ' Expected');
end; { Expected }

{--------------------------------------------------------------}
{ Match a Specific Input Character }

procedure Match(x : char);
begin
   if Look = x then GetChar
   else Expected('''' + x + '''');
end; { Match }

{--------------------------------------------------------------}
{ Recognize and Skip Over a Newline }
procedure NewLine;
begin
   if Look = LF then
	  GetChar;
   GetChar;
end; { NewLine }

{--------------------------------------------------------------}
{ Recognize a Decimal Digit }

function IsDigit(c : char): boolean;
begin
   IsDigit := c in ['0'..'9'];
end; { IsDigit }

{--------------------------------------------------------------}
{ Recognize an alphabet character }

function IsAlpha(c : char): boolean;
begin
   IsAlpha := upcase(c) in ['A'..'Z'];
end; { IsAlpha }

{--------------------------------------------------------------}
{ Recognize an Addop }

function IsAddop(c : char): boolean;
begin
   IsAddop := c in ['+', '-'];
end; { IsAddop }

{--------------------------------------------------------------}
{ Get a Number }

function GetNum: integer;
var Value : integer;
begin
   Value := 0;
   if not IsDigit(Look) then Expected('Integer');
   while IsDigit(Look) do begin
	  Value := 10 * Value + Ord(Look) - Ord('0');
	  GetChar;
   end; { while }
   GetNum := Value;
end; { GetNum }

{--------------------------------------------------------------}
{ Get a Name }

function GetName: char;
begin
   if not IsAlpha(Look) then Expected('Name');
   GetName := Upcase(Look);
   GetChar;
end; { GetName }

{--------------------------------------------------------------}
{ Output a String with Tab }

procedure Emit(s : string);
begin
   Write(TAB, s);
end; { Emit }

{--------------------------------------------------------------}
{ Output a tab with Tab and new line }

procedure EmitLn(s : string);
begin
   Emit(s);
   WriteLn;
end; { EmitLn }

{--------------------------------------------------------------}
{ Initialize }

procedure Init;
begin
   InitTable;
   GetChar;
end; { Init }

{--------------------------------------------------------------}
{ Parse and Translate a Math Factor }

function Expression: integer; Forward;

function Factor: integer;
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
end; { Factor }

{--------------------------------------------------------------}
{ Parse and Translate a Math Term }

function Term: integer;
var Value : integer;
begin
   Value := Factor;
   while Look in ['*', '/'] do begin
	  case Look of
		'*'	: begin
		   Match('*');
		   Value := Value * Factor;
		end;
		'/'	: begin
		   Match('/');
		   Value := Value div Factor;
		end;
	  end; { case }
   end; { while }
   Term := Value;
end; { Term }

{--------------------------------------------------------------}
{ Parse and Translate an Expression }

function Expression: integer;
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
		 end; { case }
	  end; { while }
   Expression := Value;
end; { Expression }

{--------------------------------------------------------------}
{ Parse and Translate an Assignment Statement }

procedure Assignment;
var Name : char;
begin
   Name := GetName;
   Match('=');
   Table[Name] := Expression;
end; { Assignment }

{--------------------------------------------------------------}
{ Input Routine }

procedure Input;
begin
   Match('?');
   Read(Table[GetName]);
end; { Input }

{--------------------------------------------------------------}
{ Output Routine }

procedure Output;
begin
   Match('!');
   WriteLn(Table[GetName]);
end; { Output }

{--------------------------------------------------------------}
{ Main Program }

begin
   Init;
   repeat
	  case Look of
		'?'	: Input;
		'!'	: Output;
	  else Assignment;
	  end; { case }
	  NewLine;
   until Look = '.';
end.
{--------------------------------------------------------------}
