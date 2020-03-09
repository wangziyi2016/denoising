function c_out=diff_co(del_j,k)
%c_out=exp(-(del_j./k).^2);
c_out=1./(1+del_j./k).^0.5;

end