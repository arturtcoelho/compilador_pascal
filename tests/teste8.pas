program exemplo75 (input, output);
var a: integer;
    function MyFunction(x: integer): integer;
    begin
        MyFunction := x * 2;
    end;
begin
    a := 1;
    a := MyFunction(MyFunction(a));
end.