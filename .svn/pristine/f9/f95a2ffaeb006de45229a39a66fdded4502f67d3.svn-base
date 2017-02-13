function struct_new = struct_up(struct_name,struct_add,dim)

a = evalin('caller',['exist(''' struct_name ''',''var'');']);

if a
    original = evalin('caller',['' struct_name '']);
    struct_new = struct_cat(original,struct_add,dim);
else
    struct_new = struct_add;
end
   