
clear all; close all; clc

mm2px = 27.78488797889;
startingPosition = 34;	% change this according to your data
step = 1700;
frames = 10;

x = provideSteps(startingPosition, step, frames, mm2px);


FLAMEstruct = load_SPE_filetype;

Calib = load ('Calib');
Calib = Calib.FinalCalib;
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
CenterData=zeros(1024,1,8)
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
   
   
   CenterLine = sgolayfilt((sum(CenterArea,2))./10,3,11);
   %CenterLine =(sum(CenterArea,2))./10; 
   
   CenterLine=flipud(CenterLine);
   CenterData(:,:,(i/11))=CenterLine;
   
   %figure; plot(CenterLine)
   
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

height=(0:1:293);
height=height./27.78488797889;
figure; 
hold on
for y=1:7
    if y==1
    plot(height',CenterData(357:650,:,y),'k')
    elseif y==5    
        
    else
    plot(height',CenterData(357:650,:,y))
    xlim([0 11])
    end
end

 legend( 'Base Flame','5 KV    [no   discharge]','6 KV    [no   discharge]','7 KV    [no   discharge]','8 KV    [with discharge]','7.5 KV [with discharge]') 
 %legend( 'Base Flame ','5 KHz   [no   discharge]','10 KHz [no   discharge]','15 KHz [no   discharge]','20 KHz [with discharge]','25 KHz [with discharge]','30 KHz [with discharge]','Location','northoutside','orientation','horizontal') 
xlabel('Height above the burner [mm]','fontsize',25)
ylabel('O fluorescence intensity [arb]','fontsize',25)

comp = zeros(1024);
comp(:,1:509)=FlameData(:,1:509,4);
comp(:,510:1024)=FlameData(:,510:1024,6);
comp(:,509:510)=500;
% 
% %figure;imagesc(comp) 
%     colormap jet 
%     colorbar
%     caxis([0 15])

