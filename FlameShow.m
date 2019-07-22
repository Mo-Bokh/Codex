
clear all; close all; clc

mm2px = 27.78488797889;
startingPosition = 34;	% change this according to your data
step = 1700;
frames = 10;

x = provideSteps(startingPosition, step, frames, mm2px);


FLAMEstruct = load_SPE_filetype;

load ('Calib')
msk = (Calib~=0);
msk(1:320 , :) = 0;

n = 6;

c=1;

FLAME = zeros(1024);
Mask = zeros(1024);
Mask(:,505:514) = 1;
f = 0;
Pr = zeros(1024);
j=1;

FlameData=zeros(1024,1024,8);
%CenterLine=zeros(1,1024);
for i=1:88
    
   if (rem(i,11) == 0)
  
   FLAME = FLAME ./ Pr;
  
   FLAME(isnan(FLAME))=0;
   
figure;imagesc(FLAME) 

    colormap jet 
    colorbar
    caxis([0 17])
  
   Pr = zeros(1024);
   f = 0;
   j = 1; 
   
   FlameData(:,:,c) = FLAME;
   
   CenterArea = FLAME.*Mask;
   CenterArea(isnan(CenterArea))=0;
   
   
   CenterLine = (sum(CenterArea,2))./10;
   
   figure;
   plot(CenterLine)
   
   c=c+1;
   
   else
   A = zeros(1024);
   P = FLAMEstruct.data{1,i};
   P = P' - 620;
   P(msk)= P(msk)./Calib(msk);  
   P = P .* msk;
   
   A(621 + x(j) + f :813 + x(j) + f, 122:899) = P(321:513, 122:899);

   FLAME = FLAME + A;
   
   Pr = Pr + (A~=0); 
   
   f = x(j) + f ;
   
   j=j+1;
   
   
    
   end
   

  
end



% FLAME = FLAME ./ Pr;
% 
% figure;imagesc(FLAME) 
%     colormap jet 
%     colorbar
%     caxis([0 15])