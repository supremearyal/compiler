{--------------------------------------------------------------}
program interpreter;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look: char; { Lookahead Character }

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
{ Recognize a Decimal Digit }

function IsDigit(c : char): boolean;
begin
   IsDigit := c in ['0'..'9'];
end; { IsDigit }

{--------------------------------------------------------------}
{ Recognize an Addop }

function IsAddop(c : char): boolean;
begin
   IsAddop := c in ['+', '-'];
end; { IsAddop }

{--------------------------------------------------------------}
{ Get a Number }

function GetNum: integer;
begin
   if not IsDigit(Look) then Expected('Integer');
   GetNum := Ord(Look) - Ord('0');
   GetChar;
end; { GetNum }

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
   GetChar;
end; { Init }

{--------------------------------------------------------------}
{ Parse and Translate an Expression }

function Expression: integer;
var Value : integer;
begin
   if IsAddop(Look) then
	  Value := 0
   else
	  Value := GetNum;
	  while IsAddop(Look) do begin
		 case Look of
		   '+' : begin
			  Match('+');
			  Value := Value + GetNum;
		   end;
		   '-' : begin
			  Match('-');
			  Value := Value - GetNum;
		   end;
		 end; { case }
	  end; { while }
   Expression := Value;
end; { Expression }

{--------------------------------------------------------------}
{ Main Program }

begin
   Init;
   Writeln(Expression);
end.
{--------------------------------------------------------------}
