program type2 (input, output);
type banana  = integer;
   laranja = integer;
var b : banana;
   l  :  laranja;
   x  : integer;
procedure myprod(var i: laranja);
begin
   i := 1;
end;
begin
   x := 10;
   l := x;
   b:=1;
   while b<=10 do
   begin
      x:=x+1;
      write (x);
      b:=b+1
   end;
   myprod(x)
end.
