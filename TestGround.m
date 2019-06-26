
clear all; close all; clc

SPEstruct = load_SPE_filetype

A = SPEstruct.data{1,1} ;
B = SPEstruct.data{1,2};


% 
% for i=5:1:10
% P = SPEstruct.data{1,i} .*(SPEstruct.data{1,i}>630);
% figure;imagesc(P')
% end


I = (eye(41));
I = I'; I = I == 1;
M = zeros (1024);



for i = 1:1:119 ; 
C= SPEstruct.data{1,i} .*(SPEstruct.data{1,i}>600);
S= C(478+i*4:518+i*4 , 113:153);
F=zeros(1024);
X = S.*I;
F(478+i*4:518+i*4 , 113:153) = X;
M = M + F; 

end 



%G = SPEstruct.data{1,1}.*(SPEstruct.data{1,1}>630)
%figure;imagesc() 
%C = A.*(A>640);
%C = C';
%figure; imagesc(C,'CDataMapping','scaled')

%C = A.*(A>630);

% 
% S = C(478:518 , 113:153);
% 
% 
% X = S.*I
% 









%figure(2) = imagesc(C','CDataMapping','scaled')

colorbar