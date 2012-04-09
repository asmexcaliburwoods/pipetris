MODULE Petris;

(* File encoding: cp866 *)
(* TurboPascal pragmas: {$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,R+,S+,V+,X+} {$M 16384,0,655360} *)

IMPORT
  c:= Crt, s:= Strings;
  
TYPE
  String = s.String;

CONST
  TopTenFile = 'top.ten';
  Ten        = 10;

  DeDelay = 150;

  bx      = 36;
  by      = 1;
  SizeX   = 12;
  SizeY   = 22;
  NFig    = 6;
  ss      = 4;
  _elem   : ARRAY 1 OF String = ('  ', 'ÎÎ');
  Scorez  : ARRAY 9 OF WORD =
              ( 480, 240, 80, 40, 20, 10, 8, 6, 4, 2 );
  Figurez : ARRAY NFig, ss, ss OF BYTE = (
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


TYPE
  tfig = ARRAY ss, ss OF BYTE;
  TopRecord = RECORD score: LONGINT; name: String; level: INTEGER; END;


VAR
  Level        : INTEGER;
  Score, Lines : LONGINT;
  Map          : ARRAY SizeX+1, SizeY+1 OF BYTE;
  Fig          : tfig;
  snd          : BOOLEAN;

  lastkey      : String;

  TopTen         : ARRAY Ten-1 OF TopRecord;
  TopTenModified : BOOLEAN;
  TopTenPathName : String;



(*PROCEDURE ReadKey : CHAR;
  BEGIN

  END ReadKey;


PROCEDURE KeyPressed : BOOLEAN;
  BEGIN

  END KeyPressed;
*)

PROCEDURE Sound(hz : WORD);
  BEGIN
    IF snd THEN Crt.Sound(hz) END
  END Sound;


PROCEDURE LoadTopTen;
VAR f: FileOfTopRecord;
    i: INTEGER; sc: LONGINT;
CONST
    dummyname: ARRAY Ten OF String =
      ('Mudryi Lox', 'Mudro Sdox', 'Potom Oglox', 'I Mudro Umer', 'Xrr', 'Mrr', 'Brr', 'Drr', 'Cook', 'Ilya Muromets');
BEGIN
  assign(f, TopTenPathName);
  (*{$i-}*) reset(f); (*{$i+}*)
  IF IOResult # 0 THEN
    sc:= 1;
    FOR i:= 1 TO Ten DO WITH TopTen[Ten - i] DO
      score:= sc;
      name:= dummyname[i-1];
      level:= Ten - i;
      sc:= sc*2;
    END; END;
  END
  else
  BEGIN
    FOR i:= 1 TO Ten DO read(f, TopTen[i-1]);
    close(f);
  END;
  TopTenModified:= FALSE;
END;

PROCEDURE StoreTopTen;
VAR f: file OF TopRecord;
    i: INTEGER;
BEGIN
  assign(f, TopTenPathName);
  rewrite(f);
  FOR i:= 1 TO Ten DO write(f, TopTen[i-1]);
  close(f);
  TopTenModified:= FALSE;
END;

PROCEDURE DisplayTopTen(y: INTEGER);
VAR i: INTEGER; s: String; n: String;
BEGIN
  textattr:= 7;
  gotoxy(40-16, y); write(' Name ');
  gotoxy(40-16+33-9, y); write(' Score L ');
  FOR i:= 1 TO Ten DO with TopTen[i-1] DO
  BEGIN
    str(score, n);
    fillchar(s[1], 29, '.');
    s:= name;
    s[length(name)+1]:= ' ';
    move(n[1], s[29+1-length(n)], length(n));
    s[0]:= #29;
    s[29-length(n)]:= ' ';
    IF i = 1 THEN textattr:= 15;
    gotoxy(40-16, y+i+1); write(' ', s, level:2, ' ');
    textattr:= 7;
  END;
  gotoxy(2, 25);
  IF TopTenModified THEN StoreTopTen;
  IF readkey = #0 THEN readkey;
END;

PROCEDURE ToTopTen(sc: LONGINT; lv: INTEGER);
VAR i: INTEGER; nm: String;
BEGIN
  i:= Ten+1;
  WHILE (i > 1) AND (TopTen[i-2].score < sc) DO dec(i);
  IF i <= Ten THEN
  BEGIN
    textattr:= 7; gotoxy(1, 25);
    write('Enter yer name:');
    window(22, 25, 22+21, 25); gotoxy(1, 1);
    textattr:= $70; writeln; readln(nm);
    window(1, 1, 80, 25);
    IF i <> Ten THEN
      move(TopTen[i-1], TopTen[i], (Ten - i-1) * sizeof(TopRecord));
    WITH TopTen[i-1] DO
    BEGIN
      score:= sc;
      level:= lv;
      name:= nm;
    END;
    TopTenModified:= TRUE;
  END;
END;

function EnterLevel : BOOLEAN;
  VAR
    ch : CHAR;
  BEGIN
    TextColor(LightGray);
    TextBackground(Black);
    ClrScr;
    GoToXY(25, 12);
    Write('Enter skill level (0-9/"Esc"): ');
    repeat
      ch := ReadKey
    UNTIL ((ch >= '0') AND (ch <= '9')) OR (ch = #27);
    IF ch <> #27 THEN Level := Ord(ch) - Ord('0');
    EnterLevel := ch <> #27
  END;


PROCEDURE PlayGame;
  VAR
    i,j,k,t, fx,fy,
    CLines          : INTEGER;
    fly,fuck,drop   : BOOLEAN;

  PROCEDURE PutFigure(p : INTEGER);
    VAR
      x,y : INTEGER;
    BEGIN
      FOR x := 0 TO ss DO
        FOR y := 0 TO ss DO
          IF Fig[x, y] = 1 THEN
          BEGIN
            GoToXY(bx+(fx+x)*2-1, by+fy+y-1);
            Write(_elem[p])
          END;
      GoToXY(1, 25)
    END;

  function TestFigure(fx, fy : INTEGER) : BOOLEAN;
    VAR
      x,y : INTEGER;
      tf  : BOOLEAN;
    BEGIN
      {$R-}
      tf := TRUE;
      FOR x := 0 TO ss DO
        FOR y := 0 TO ss DO
          IF (Fig[x, y] = 1) AND (Map[fx+x, fy+y] > 0) THEN tf := FALSE;
      TestFigure := tf
      {$R+}
    END;

  PROCEDURE StoneFigure;
    VAR
      x,y,z,l,u,q : INTEGER;
      f           : BOOLEAN;

    PROCEDURE PutMap;
      VAR
        x,z : INTEGER;
      BEGIN
        FOR z := 1 TO y DO
        BEGIN
          GoToXY(bx+1, by+z-1);
          FOR x := 1 TO SizeX DO
            Write(_elem[Map[x,z]])
        END;
        GoToXY(1, 25)
      END;

    BEGIN
      FOR x := 0 TO ss DO
        FOR y := 0 TO ss DO
          IF Fig[x, y] = 1 THEN Map[fx+x, fy+y] := 1;
      y := fy;
      l := 1; q := 0;
      u := -1;
      WHILE y <= SizeY DO
      BEGIN
        f := TRUE;
        FOR x := 1 TO SizeX DO
          f := f AND (Map[x,y] = 1);
        IF f THEN
        BEGIN
          IF u = -1 THEN u := y;
          Inc(l, l);
          Inc(q);
          Inc(Lines);
          Inc(CLines);
          FOR z := y-1 downto 1 DO
            FOR x := 1 TO SizeX DO
              Map[x, z+1] := Map[x, z];
          PutMap;
          Delay(100)
        END
        else
          Inc(y)
      END;
      Inc(Score, q*l*((SizeY-u) div 3+Scorez[Level]));
      IF (CLines >= 20) AND (Level > 0) THEN
      BEGIN
        CLines := 0;
        Dec(Level);
        FOR z := 5000 downto 20 DO
          Sound(z);
        Delay(100);
        NoSound;
        GoToXY(8, 1);
        Write(Level)
      END
    END;

  PROCEDURE TurnFigure;
    VAR
      x,y : INTEGER;
      f   : tfig;
    BEGIN
      FOR x := ss downto 0 DO
        FOR y := 0 TO ss DO
          f[y, ss-x] := Fig[x, y];
      Fig := f
    END;

  BEGIN
    Score := 0; Lines := 0; CLines := 0;
    TextAttr := 0;
    ClrScr;
    TextColor(LightGray);
    FOR i := 0 TO 11 DO
    BEGIN
      GoToXY(22, i*2+1);
      FOR j := 1 TO 13 DO Write('ÂÄÁÄ');
      GoToXY(22, (i+1)*2);
      FOR j := 1 TO 13 DO Write('ÁÄÂÄ')
    END;
    GoToXY(1, 1);
    WriteLn('Level: ', Level);
    WriteLn('Lines: 0');
    Write('Score: 0');
    FOR i := 1 TO SizeY DO
    BEGIN
      GoToXY(bx, by+i-1);
      Write(' ');
      FOR j := 1 TO SizeX DO
      BEGIN
        Write(_elem[0]);
        Map[j, i] := 0
      END;
      Write(' ')
    END;
    FOR j := 0 TO SizeX+1 DO Map[j, SizeY+1] := 1;
    FOR i := 0 TO SizeY+1 DO
    BEGIN
      Map[0, i] := 127;
      Map[SizeX+1, i] := 129
    END;
    GoToXY(bx, by+SizeY);
    FOR j := 1 TO SizeX div 2+1 DO Write('ÄÄÂÄ');

    fly := TRUE;
    fuck := FALSE;

    repeat
      IF fly THEN
      BEGIN
        k := Random(NFig+1);
        FOR i := 0 TO ss DO
          FOR j := 0 TO ss DO
            Fig[i, j] := Figurez[k, i, j];
        t := Random(2);
        IF k > 0 THEN FOR i := 1 TO t DO TurnFigure;
        fx := SizeX div 2 - 2;
        fy := 0;
        fly := FALSE;
        Sound(50);
        Delay(100);
        NoSound;
        fuck := not TestFigure(fx, fy);
        GoToXY(8, 2);
        Write(Lines);
        GoToXY(8, 3);
        Write(Score);
        drop := TRUE;
      END;
      PutFigure(1);
      FOR i := 0 TO Level*2 DO
      BEGIN
        IF KeyPressed THEN
          CASE ReadKey OF
            #27 : BEGIN
                    fuck := TRUE;
                    drop := FALSE
                  END;
            'h' : IF TestFigure(fx-1, fy) THEN
                  BEGIN
                    PutFigure(0);
                    Dec(fx);
                    PutFigure(1)
                  END;
            'k' : IF TestFigure(fx+1, fy) THEN
                  BEGIN
                    PutFigure(0);
                    Inc(fx);
                    PutFigure(1)
                  END;
            'j' : IF k > 0 THEN
                  BEGIN
                    TurnFigure;
                    IF not TestFigure(fx, fy) THEN
                    BEGIN
                      TurnFigure;
                      TurnFigure;
                      TurnFigure
                    END
                    else
                    BEGIN
                      TurnFigure;
                      TurnFigure;
                      TurnFigure;
                      PutFigure(0);
                      TurnFigure;
                      PutFigure(1)
                    END
                  END;
            ' ' : BEGIN
                    PutFigure(0);
                    WHILE TestFigure(fx, fy+1) DO
                      Inc(fy);
                    PutFigure(1);
                    drop := FALSE;
                  END;
            's' : snd := not snd
          END;
        IF drop THEN Delay(DeDelay)
      END;
      IF TestFigure(fx, fy+1) AND not fuck THEN
      BEGIN
        PutFigure(0);
        Inc(fy)
      END
      else
      BEGIN
        StoneFigure;
        fly := TRUE
      END
    UNTIL fuck;
    GoToXY(1, 24);
    Write('O VE R GA ME !');
    ReadKey
  END;

PROCEDURE Topprizz;
  VAR i: INTEGER;

  PROCEDURE w(txt : String);
  BEGIN
    ASM
      push ds
      mov  ax, $B800
      mov  ds, ax
      mov  es, ax
      mov  si, 80*24*2-2
      mov  di, 80*25*2-2
      mov  cx, 80*24
      std
      rep movsw

      mov  ax, ss
      mov  ds, ax
      lea  si, txt
      mov  cl, [si]
      xor  ch, ch
      inc  si
      mov  ax, 40
      sub  ax, cx
      AND  ax, $FFFE
      shl  ax, 1
      mov  di, ax
      cld
    @loop:
      lodsb
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
    END;

    delay(200);
  END;

  BEGIN
    ASM
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
    END;

    GoToXY(2, 1);
    w('FUCK OFF trepackOFF!');
    w('                    ');
    w('Ü  .... ..  ....... ');
    w('Ü  ..   .. .   .   .');
    w('Ü  .... ....  . ....');
    w('Ü  ..       . . .   ');
    w('Ü........... ... .. ');
    FOR i:= 1 TO 25 DO
    BEGIN
    w('                                  ');
      IF i = 2 THEN
      BEGIN
        IF TopTen[0].Score = 0 THEN LoadTopTen;
        DisplayTopTen(12);
      END;
    END;
  END;

BEGIN
  TextAttr := Yellow;
  WriteLn;
  Write('W0NDER PETRIS   (c) 1998, ');
  TextBackground(Blue);
  Write(' Foxy John ');
  TextColor(Black+Blink);
  Write('&');
  TextColor(Yellow);
  Write(' 'AKCOH ');
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
  snd := TRUE;
  TopTen[0].Score:= 0;
  TopTenPathName:= ParamStr(0);
  WHILE (TopTenPathName[byte(TopTenPathName[0])] <> '\') AND (TopTenPathName > '') DO
    dec(TopTenPathName[0]);
  TopTenPathName:= TopTenPathName + TopTenFile;
  Topprizz;
  WHILE EnterLevel DO BEGIN PlayGame; ToTopTen(Score, Level); Topprizz; END;
  ClrScr;
  WriteLn('Tnx 4 key rapin''')
END Petris.