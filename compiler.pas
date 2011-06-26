{--------------------------------------------------------------}
program compiler;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
const CR  = '\n';

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

procedure SkipWhite; Forward;

procedure Match(x : char);
begin
   if Look <> x then Expected('''' + x + '''')
   else begin
	  GetChar;
	  SkipWhite;
   end;
end; { Match }

{--------------------------------------------------------------}
{ Recognize an Alpha Character }

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
{ Recognize a Decimal Digit }

function IsDigit(c : char): boolean;
begin
   IsDigit := c in ['0'..'9'];
end; { IsDigit }

{--------------------------------------------------------------}
{ Recognize an Alphanumeric }

function IsAlNum(c : char): boolean;
begin
   IsAlNum := IsAlpha(c) or IsDigit(c);
end; { IsAlNum }

{--------------------------------------------------------------}
{ Recognize White Space }

function IsWhite(c : char): boolean;
begin
   IsWhite := c in [' ', TAB];
end; { IsWhite }

{--------------------------------------------------------------}
{ Skip Over Leading White Space }

procedure SkipWhite;
begin
   while IsWhite(Look) do
	  GetChar;
end; { SkipWhite }

{--------------------------------------------------------------}
{ Get an Identifier }

function GetName: string;
var Token : string;
begin
   Token := '';
   if not IsAlpha(Look) then Expected('Name');
   while IsAlNum(Look) do begin
	  Token := Token + UpCase(Look);
	  GetChar;
   end;
   GetName := Token;
   SkipWhite;
end; { GetName }

{--------------------------------------------------------------}
{ Get a Number }

function GetNum: string;
var Value : string;
begin
   Value := '';
   if not IsDigit(Look) then Expected('Integer');
   while IsDigit(Look) do begin
	  Value := Value + Look;
	  GetChar;
   end;
   GetNum := Value;
   SkipWhite;
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
{ Prints text needed for the beginning of the assembly output. }

procedure AsmRequiredBegin;
begin
   WriteLn('segment .data');
   WriteLn('format:');
   EmitLn('db "%ld", 0xA, 0x0');
   WriteLn;
   WriteLn('segment .text');
   EmitLn('global main');
   EmitLn('extern printf');
   WriteLn('main:');
end; { AsmRequiredBegin }

{--------------------------------------------------------------}
{ Prints text needed for the end of the assembly output. }

procedure AsmRequiredEnd;
begin
   WriteLn;
   EmitLn('mov edi, format');
   EmitLn('mov rsi, r8');
   EmitLn('xor rax, rax');
   EmitLn('call printf');
   EmitLn('ret');
   WriteLn;
end; { AsmRequiredEnd }

{--------------------------------------------------------------}
{ Initialize }

procedure Init;
begin
   GetChar;
   SkipWhite;
end; { Init }

{--------------------------------------------------------------}
{ Parse and Translate an Identifier }

procedure Ident;
var Name : string;
begin
   Name := GetName;
   if Look = '(' then begin
	  Match('(');
	  Match(')');
	  EmitLn('call ' + Name);
   end
   else
	  EmitLn('mov r8, ' + Name);
end; { Ident }

{--------------------------------------------------------------}
{ Parse and Translate a Math Factor }

procedure Expression; Forward;

procedure Factor;
begin
   if Look = '(' then begin
	  Match('(');
	  Expression;
	  Match(')');
   end
   else if IsAlpha(Look) then
	  Ident
   else
	  EmitLn('mov r8, ' + GetNum);
end; { Factor }

{--------------------------------------------------------------}
{ Recognize and Translate a Multiply }

procedure Multiply;
begin
   Match('*');
   Factor;
   EmitLn('pop r9');
   EmitLn('mov rax, r9');
   EmitLn('mul r8');
   EmitLn('mov r8, rax');
end; { Multiply }

{--------------------------------------------------------------}
{ Recognize and Translate a Divide }

procedure Divide;
begin
   Match('/');
   Factor;
   EmitLn('pop r9');
   EmitLn('mov rax, r9');
   EmitLn('xor rdx, rdx');
   EmitLn('idiv r8');
   EmitLn('mov r8, rax');
end; { Divide }

{--------------------------------------------------------------}
{ Parse and Translate a Math Term }

procedure Term;
begin
   Factor;
   while Look in ['*', '/'] do begin
	  EmitLn('push r8');
	  case Look of
		'*'	: Multiply;
		'/'	: Divide;
	  end; { case }
   end;
end; { Term }

{--------------------------------------------------------------}
{ Recognize and Translate an Add }

procedure Add;
begin
   Match('+');
   Term;
   EmitLn('pop r9');
   EmitLn('add r8, r9');
end; { Add }

{--------------------------------------------------------------}
{ Recognize and Translate a Subtract }

procedure Subtract;
begin
   Match('-');
   Term;
   EmitLn('pop r9');
   EmitLn('sub r8, r9');
   EmitLn('neg r8');
end; { Add }


{--------------------------------------------------------------}
{ Parse and Translate an Expression }

procedure Expression;
begin
   if IsAddop(Look) then
	  EmitLn('xor r8, r8')
   else
	  Term;
   while IsAddop(Look) do begin
	  EmitLn('push r8');
	  case Look of
		'+' : Add;
		'-' : Subtract;
	  end; { case }
   end; { while }
end; { Expression }

{--------------------------------------------------------------}
{ Parse and Translate an Assignment Statement }

procedure Assignment;
var Name : string;
begin
   Name := GetName;
   Match('=');
   Expression;
   EmitLn('mov ' + 'r8, [' + Name + ']');
end; { Assignment }

{--------------------------------------------------------------}
{ Main Program }

begin
   AsmRequiredBegin;
   
   Init;
   Assignment;

   {if Look <> CR then Expected('Newline');}

   AsmRequiredEnd;
end.
{--------------------------------------------------------------}
