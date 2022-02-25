
procedure CloseWindow;
begin
  KeyInput.Apply([ssAlt]);
  KeyInput.Press(VK_F4);
  KeyInput.UnApply([ssAlt]);
  KeyInput.Press(VK_N);
end;
procedure _Send;
begin

end;

procedure TestSendAlphabet;
var
i: integer;
begin
  for i:=$41 to $5A do
    Send(i);      //a

  Send(VK_RETURN);

  for i:=$41 to $5A do
    TESTHID(i);   //aA

  Send(VK_RETURN);

  for i:=$61 to $63 do
    TESTHID(i);   //112233 because $61 = 97 = VK_NUMPAD1

  //for i:=$41 to $5A do TESTHID(TranslateKey(Chr(i)));  //only translates control keys

   Send(VK_RETURN);
end;

procedure TestTranslate;
begin

  Send('a'); //1
  Send('A'); //a
  Send(TranslateKey('a')); //a
  Send(TranslateKey('A')); //a

  //TEST('1'); //1! winunit
  Send(VK_RETURN);

  //TESTHID(Ord('`'));          //00  VK_NUMPAD0   = 96; // $60
  //TESTHID(Ord('.'));          //    VK_DELETE = 46 unprintable
  TESTHID(TranslateKey('.'));   //.>
  TESTHID(TranslateKey('a'));   //aA
  TESTHID(TranslateKey(Char(VK_A)));   //aA

  {
  if controlkey then apply
  TranslateKey(Char)
  or
  TranslateKey(Byte)
  if controlkey then Unapply
  }

  //TESTHID(TEST(VK_ALT));
  //TESTHID(TEST('F'));
end;
