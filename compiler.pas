{--------------------------------------------------------------}
program Cradle;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look  : char;		{ Lookahead Character }
   Lcount : integer;	{ Label Counter }

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
{ Get an Identifier }

function GetName: char;
begin
   if not IsAlpha(Look) then Expected('Name');
   GetName := UpCase(Look);
   GetChar;
end; { GetName }

{--------------------------------------------------------------}
{ Get a Number }

function GetNum: char;
begin
   if not IsDigit(Look) then Expected('Integer');
   GetNum := Look;
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
   LCount := 0;
   GetChar;
end; { Init }

{--------------------------------------------------------------}
{ Recognize and Translate an "Other" }

procedure Other;
begin
   EmitLn(GetName);
end; { Other }

{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure DoIf; Forward;

procedure Block;
begin
   while not(Look in ['e']) do begin
	  case Look of
		'i'	: DoIf;
	  else Other;
	  end; { case }
   end; { while }
end; { Block }

{--------------------------------------------------------------}
{ Parse and Translate a Program }

procedure DoProgram;
begin
   Block;
   if Look <> 'e' then Expected('End');
   EmitLn(';END')
end; { DoProgram }

{--------------------------------------------------------------}
{ Generate a Unique Label }

function NewLabel: string;
var S : string;
begin
   Str(LCount, S);
   NewLabel := 'L' + S;
   Inc(LCount);
end; { NewLabel }

{--------------------------------------------------------------}
{ Post a Label to Output }

procedure PostLabel(L : string);
begin
   WriteLn(L, ':');
end; { PostLabel }

{--------------------------------------------------------------}
{ Parse and Translate a Boolean condition }
{ Dummy function }

procedure Condition;
begin
   EmitLn('<condition>');
end; { Condition }

{--------------------------------------------------------------}
{ Recognize And Translate an IF Construct }

procedure DoIf;
var L1, L2: string;
begin
   Match('i');
   Condition;
   L1 := NewLabel;
   L2 := L1;
   EmitLn('jne ' + L1);
   Block;
   if Look = 'l' then begin
	  Match('l');
	  L2 := NewLabel;
	  EmitLn('jmp ' + L2);
	  PostLabel(L1);
	  Block;
   end;
   Match('e');
   PostLabel(L2);
end; { DoIf }

{--------------------------------------------------------------}
{ Main Program } 

begin
   Init;
   DoProgram;
end.
{--------------------------------------------------------------}
