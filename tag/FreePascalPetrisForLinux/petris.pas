{//$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,R+,S+,V+,X+}
{//$M 16384,0,655360}

{//$DEFINE CGA}
{//$DEFINE DOS}
{$DEFINE UNIX}

uses
    Crt;


const
{$IFDEF UNIX}
  FILLER='*';
  BRICKWALL0='@@@@';
  BRICKWALL1='@@@@';
  BRICKWALL2='@@@@';
{$ENDIF}
{$IFDEF DOS}
  FILLER='Î';
  BRICKWALL0='ÄÄÂÄ';
  BRICKWALL1='ÂÄÁÄ';
  BRICKWALL2='ÁÄÂÄ';
{$ENDIF}

const
  TopTenFile = 'top.ten';
  Ten        = 10;

  DeDelay = 150;

  BX      = 36;
  BY      = 1;
  SizeX   = 12;
  SizeY   = 22;
  NFig    = 6;
  ss      = 4;
  _elem   : array [0..1] of String[2] = ('  ', FILLER + FILLER);
  Scorez  : array [0..9] of Word =
              ( 480, 240, 80, 40, 20, 10, 8, 6, 4, 2 );
  Figurez : array [0..NFig, 0..ss, 0..ss] of Byte = (
              ( (0, 1, 1, 0, 0),
                (0, 1, 1, 0, 0),
                (0, 0, 0, 0, 0),
                (0, 0, 0, 0, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 1, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 0, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 1, 1, 1, 0),
                (0, 0, 0, 0, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 0, 0, 0),
                (0, 0, 0, 1, 0),
                (0, 1, 1, 1, 0),
                (0, 0, 0, 0, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 0, 0, 0),
                (0, 0, 0, 0, 0),
                (0, 1, 1, 1, 0),
                (0, 0, 0, 1, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 0, 0, 0),
                (0, 1, 0, 0, 0),
                (0, 1, 1, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 0, 0, 0, 0) ),

              ( (0, 0, 0, 0, 0),
                (0, 0, 1, 0, 0),
                (0, 1, 1, 0, 0),
                (0, 1, 0, 0, 0),
                (0, 0, 0, 0, 0) ) );


type
  tfig = array [0..ss, 0..ss] of Byte;
  TopRecord = record score: longint; name: string[21]; level: integer; end;


var
  Level        : Integer;
  Score, Lines : LongInt;
  Map          : array [0..SizeX+1, 0..SizeY+1] of Byte;
  Fig          : tfig;
  snd          : Boolean;

  lastkey      : String[1];

  TopTen         : array [1..Ten] of TopRecord;
  TopTenModified : boolean;
  TopTenPathName : string[64];



{function ReadKey : Char;
  begin

  end;


function KeyPressed : Boolean;
  begin

  end;
}

procedure Sound(hz : Word);
  begin
    if snd then Crt.Sound(hz)
  end;


procedure LoadTopTen;
var f: file of TopRecord;
    i: integer; sc: longint;
const
    dummyname: array [1..Ten] of string [21] =
      ('Mudryi Lox', 'Mudro Sdox', 'Potom Oglox', 'I Mudro Umer', 'Xrr', 'Mrr', 'Brr', 'Drr', 'Cook', 'Ilya Muromets');
begin
  assign(f, TopTenPathName);
  {$i-} reset(f); {$i+}
  if IOResult <> 0 then
  begin
    sc:= 1;
    for i:= 1 to Ten do with TopTen[Ten+1 - i] do
    begin
      score:= sc;
      name:= dummyname[i];
      level:= Ten - i;
      sc:= sc*2;
    end;
  end
  else
  begin
    for i:= 1 to Ten do read(f, TopTen[i]);
    close(f);
  end;
  TopTenModified:= false;
end;

procedure StoreTopTen;
var f: file of TopRecord;
    i: integer;
begin
  assign(f, TopTenPathName);
  rewrite(f);
  for i:= 1 to Ten do write(f, TopTen[i]);
  close(f);
  TopTenModified:= false;
end;

procedure DisplayTopTen(y: integer);
var i: integer; s: string[29]; n: string[10];
begin
  textattr:= 7;
  gotoxy(40-16, y); write(' Name ');
  gotoxy(40-16+33-9, y); write(' Score L ');
  for i:= 1 to Ten do with TopTen[i] do
  begin
    str(score, n);
    fillchar(s[1], 29, '.');
    s:= name;
    s[length(name)+1]:= ' ';
    move(n[1], s[29+1-length(n)], length(n));
    s[0]:= #29;
    s[29-length(n)]:= ' ';
    if i = 1 then textattr:= 15;
    gotoxy(40-16, y+i+1); write(' ', s, level:2, ' ');
    textattr:= 7;
  end;
  gotoxy(2, 25);
  if TopTenModified then StoreTopTen;
  if readkey = #0 then readkey;
end;

procedure ToTopTen(sc: longint; lv: integer);
var i: integer; nm: string[21];
begin
  i:= Ten+1;
  while (i > 1) and (TopTen[i-1].score < sc) do dec(i);
  if i <= Ten then
  begin
    textattr:= 7; gotoxy(1, 25);
    write('Enter yer name:');
    window(22, 25, 22+21, 25); gotoxy(1, 1);
    textattr:= $70; writeln; readln(nm);
    window(1, 1, 80, 25);
    if i <> Ten then
      move(TopTen[i], TopTen[i+1], (Ten - i) * sizeof(TopRecord));
    with TopTen[i] do
    begin
      score:= sc;
      level:= lv;
      name:= nm;
    end;
    TopTenModified:= true;
  end;
end;

function EnterLevel : Boolean;
  var
    ch : Char;
  begin
    TextColor(LightGray);
    TextBackground(Black);
    ClrScr;
    GoToXY(25, 12);
    Write('Enter skill level (0-9/"Esc"): ');
    repeat
      ch := ReadKey
    until ((ch >= '0') and (ch <= '9')) or (ch = #27);
    if ch <> #27 then Level := Ord(ch) - Ord('0');
    EnterLevel := ch <> #27
  end;


procedure PlayGame;
  var
    i,j,k,t, fx,fy,
    CLines          : Integer;
    fly,fuck,drop   : Boolean;

  procedure PutFigure(p : Integer);
    var
      x,y : Integer;
    begin
      for x := 0 to ss do
        for y := 0 to ss do
          if Fig[x, y] = 1 then
          begin
            GoToXY(BX+(fx+x)*2-1, BY+fy+y-1);
            Write(_elem[p])
          end;
      GoToXY(1, 25)
    end;

  function TestFigure(fx, fy : Integer) : Boolean;
    var
      x,y,ffx,ffy : Integer;
      tf  : Boolean;
    begin
      tf := true;
      for x := 0 to ss do
        for y := 0 to ss do
          if (Fig[x, y] = 1) then
          begin
            ffx:=fx+x;
            ffy:=fy+y;
            if(ffx>=0)and(ffx<=SizeX+1)and(ffy>=0)and(ffy<=SizeY+1)then
                if Map[ffx, ffy] > 0 then begin tf := false; break; end;
          end;
      TestFigure := tf
    end;

  procedure StoneFigure;
    var
      x,y,z,l,u,q : Integer;
      f           : Boolean;

    procedure PutMap;
      var
        x,z : Integer;
      begin
        for z := 1 to y do
        begin
          GoToXY(BX+1, BY+z-1);
          for x := 1 to SizeX do
            Write(_elem[Map[x,z]])
        end;
        GoToXY(1, 25)
      end;

    begin
      for x := 0 to ss do
        for y := 0 to ss do
          if Fig[x, y] = 1 then Map[fx+x, fy+y] := 1;
      y := fy;
      l := 1; q := 0;
      u := -1;
      while y <= SizeY do
      begin
        f := true;
        for x := 1 to SizeX do
          f := f and (Map[x,y] = 1);
        if f then
        begin
          if u = -1 then u := y;
          Inc(l, l);
          Inc(q);
          Inc(Lines);
          Inc(CLines);
          for z := y-1 downto 1 do
            for x := 1 to SizeX do
              Map[x, z+1] := Map[x, z];
          PutMap;
          Delay(100)
        end
        else
          Inc(y)
      end;
      Inc(Score, q*l*((SizeY-u) div 3+Scorez[Level]));
      if (CLines >= 20) and (Level > 0) then
      begin
        CLines := 0;
        Dec(Level);
        for z := 5000 downto 20 do
          Sound(z);
        Delay(100);
        NoSound;
        GoToXY(8, 1);
        Write(Level)
      end
    end;

  procedure TurnFigure;
    var
      x,y : Integer;
      f   : tfig;
    begin
      for x := ss downto 0 do
        for y := 0 to ss do
          f[y, ss-x] := Fig[x, y];
      Fig := f
    end;

  begin
    Score := 0; Lines := 0; CLines := 0;
    TextAttr := 0;
    ClrScr;
    TextColor(LightGray);
    for i := 0 to 11 do
    begin
      GoToXY(22, i*2+1);
      for j := 1 to 13 do Write(BRICKWALL1);
      GoToXY(22, (i+1)*2);
      for j := 1 to 13 do Write(BRICKWALL2)
    end;
    GoToXY(1, 1);
    WriteLn('Level: ', Level);
    WriteLn('Lines: 0');
    Write('Score: 0');
    for i := 1 to SizeY do
    begin
      GoToXY(BX, BY+i-1);
      Write(' ');
      for j := 1 to SizeX do
      begin
        Write(_elem[0]);
        Map[j, i] := 0
      end;
      Write(' ')
    end;
    for j := 0 to SizeX+1 do Map[j, SizeY+1] := 1;
    for i := 0 to SizeY+1 do
    begin
      Map[0, i] := 127;
      Map[SizeX+1, i] := 129
    end;
    GoToXY(BX, BY+SizeY);
    for j := 1 to SizeX div 2+1 do Write(BRICKWALL0);

    fly := true;
    fuck := false;

    repeat
      if fly then
      begin
        k := Random(NFig+1);
        for i := 0 to ss do
          for j := 0 to ss do
            Fig[i, j] := Figurez[k, i, j];
        t := Random(2);
        if k > 0 then for i := 1 to t do TurnFigure;
        fx := SizeX div 2 - 2;
        fy := 0;
        fly := false;
        Sound(50);
        Delay(100);
        NoSound;
        fuck := not TestFigure(fx, fy);
        GoToXY(8, 2);
        Write(Lines);
        GoToXY(8, 3);
        Write(Score);
        drop := true;
      end;
      PutFigure(1);
      for i := 0 to Level*2 do
      begin
        if KeyPressed then
          case ReadKey of
            #27 : begin
                    fuck := true;
                    drop := false
                  end;
            'h' : if TestFigure(fx-1, fy) then
                  begin
                    PutFigure(0);
                    Dec(fx);
                    PutFigure(1)
                  end;
            'k' : if TestFigure(fx+1, fy) then
                  begin
                    PutFigure(0);
                    Inc(fx);
                    PutFigure(1)
                  end;
            'j' : if k > 0 then
                  begin
                    TurnFigure;
                    if not TestFigure(fx, fy) then
                    begin
                      TurnFigure;
                      TurnFigure;
                      TurnFigure
                    end
                    else
                    begin
                      TurnFigure;
                      TurnFigure;
                      TurnFigure;
                      PutFigure(0);
                      TurnFigure;
                      PutFigure(1)
                    end
                  end;
            ' ' : begin
                    PutFigure(0);
                    while TestFigure(fx, fy+1) do
                      Inc(fy);
                    PutFigure(1);
                    drop := false;
                  end;
            's' : snd := not snd
          end;
        if drop then Delay(DeDelay)
      end;
      if TestFigure(fx, fy+1) and not fuck then
      begin
        PutFigure(0);
        Inc(fy)
      end
      else
      begin
        StoneFigure;
        fly := true
      end
    until fuck;
    GoToXY(1, 24);
    Write('O VE R GA ME !');
    ReadKey
  end;

procedure Topprizz;
  var i: integer;

{$IFDEF CGA}
  procedure w(txt : String);
  begin
    asm
      push ds
      mov  ax, $B800    // ax:=CNAT ; CNAT: character name+attribute table
      mov  ds, ax       // ds:=CNAT
      mov  es, ax       // es:=CNAT
      mov  si, 80*24*2-2// si:= ScrWidth*(24 Lines)*(NAL: name+attribute length) - 1 *(NAL)
      mov  di, 80*25*2-2// di:= ScrWidth*(25 Lines)*(NAL: name+attribute length) - 1 *(NAL)
      mov  cx, 80*24    // cx:= ScrWidth*24
      std               // set direction:= 1
      rep movsw         // copy screen's video memory lower one characters line (scroll a screen one line lower)

      mov  ax, ss
      mov  ds, ax
      lea  si, txt      //si:=address(procedure_params::txt)
      mov  cl, [si]     //
      xor  ch, ch       //cx:= txt.length
      inc  si           //si:=address(txt[1])
      mov  ax, 40       //ax:=40
      sub  ax, cx       //ax:=ax-txt.length
      and  ax, $FFFE    //if(exists n which is a natural number | ax == 2*n+1 ) then ax:=2*n
      shl  ax, 1        //ax:=ax*2 //2==NAL
      mov  di, ax
      cld
    @loop:
      lodsb             //al:=txt[i]
      cmp  al, '.'
      je  @dot
      cmp al, ' '
      jne  @put
      mov  al, 248 {ø}
      jmp @put
    @dot:
      mov  al, 220
    @put:
      stosb
      inc di
      inc di
      inc di
      loop @loop
      pop  ds
    end;

    delay(200);
  end;
{$ENDIF}

  begin
{$IFDEF CGA}
    asm
      mov  ax, $B800
      mov  es, ax
      xor  di, di
      cld
      mov  cx, 40*25
    @loop:
      mov  ax, 248+$700  {ø}
      stosw
      mov  ax, 32
      stosw
      loop @loop
    end;

    GoToXY(2, 1);
    w('FUCK OFF trepackOFF!');
    w('                    ');
    w('Ü  .... ..  ....... ');
    w('Ü  ..   .. .   .   .');
    w('Ü  .... ....  . ....');
    w('Ü  ..       . . .   ');
    w('Ü........... ... .. ');
{$ELSE}
    ClrScr;
{$ENDIF}
    for i:= 1 to 25 do
    begin
{$IFDEF CGA}
    w('                                  ');
{$ENDIF}
      if i = 2 then
      begin
        if TopTen[1].Score = 0 then LoadTopTen;
        DisplayTopTen(12);
      end;
    end;
  end;

Begin
  TextAttr := Yellow;
  WriteLn;
  Write('W0NDER PETRIS   (c) 1998, ');
  TextBackground(Blue);
  Write(' Foxy John ');
  TextColor(Black+Blink);
  Write('&');
  TextColor(Yellow);
  Write(' ''AKCOH ');
  TextAttr := Yellow;
  WriteLn(' Siberia, Russia');
  TextColor(LightGray);
  WriteLn('http://hum.da.ru/');
  WriteLn('http://milkbroz.da.ru/');
  WriteLn;
  Write('Key table: <h> <j> <k> < > <ESC> & <s> - sound on/off ...');
  ReadKey;

  Randomize;
  lastkey[0] := #255;
  snd := true;
  TopTen[1].Score:= 0;
  TopTenPathName:= ParamStr(0);
  while (TopTenPathName[byte(TopTenPathName[0])] <> '\') and (TopTenPathName > '') do
    dec(TopTenPathName[0]);
  TopTenPathName:= TopTenPathName + TopTenFile;
  Topprizz;
  while EnterLevel do begin PlayGame; ToTopTen(Score, Level); Topprizz; end;
  ClrScr;
  WriteLn('Tnx 4 key rapin''')
End.
