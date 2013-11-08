function DeleteSfiles()   
    a='abcdefghijklmnopqrstuvwxyz';
    for i=1:length(a)
        s=sprintf('s%s*',a(i));
        delete(s)
    end
    for i=1:9
        s=sprintf('s%.f*',i);
        delete(s)
    end
end