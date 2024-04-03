program fibonacci;
var
	n1, n2, n3: integer;
begin
n1	:= 1;
n2	:= 1;
n3	:= (n1 + n2);
write(n1);
write(n2);
	while n3 < 100 do
	begin
		write (n3);
		n1:= (n3 + n2);
		write (n1);
		n2:= (n1 + n3);
		write (n2);
		n3:= (n2 + n1); 	
	end;
end.
