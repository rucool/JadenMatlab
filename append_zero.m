function N=append_zero(n)
% returns 0n if n<10; retuns n if n>=10

if n>9
    N=num2str(n);
else
    N=['0' num2str(n)];
end
