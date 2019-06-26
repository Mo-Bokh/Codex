
SPEstruct = load_SPE_filetype

A = SPEstruct.data{1,1} ;
B = SPEstruct.data{1,2};
%F = zeros(1024);
F=zeros(1024);

for i=2:1:119
    X = SPEstruct.data{1,i} ;
    A = (A + X)/2;
end

for i=1:1:119
    D = SPEstruct.data{1,i} ;
    F = F + D;
end

%C = F.*(F>620);

figure(1) = imagesc(F','CDataMapping','scaled')

%C = A.*(A>630);

%figure(2) = imagesc(C','CDataMapping','scaled')

colorbar