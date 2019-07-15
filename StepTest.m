
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
FLAME = zeros(1024);
f = 0;
Pr = zeros(1024);



for i=:10
   A = zeros(1024);
   P = FLAMEstruct.data{1,i};
   P = P' - 620;
   P(msk)= P(msk)./Calib(msk);  
   P = P .* msk;
   
   A(621 + x(i) + f :813 + x(i) + f, 122:899) = P(321:513, 122:899);

   FLAME = FLAME + A;
   
   Pr = Pr + (A~=0); 
   
   f = x(i) + f ; 

   % FLAME(321 - x(i) :513 - x(i), 122:899) = FLAME(321 - x(i) :513 - x(i), 122:899) + P(321:513, 122:899);
   
   
  
end

FLAME = FLAME ./ Pr;

figure;imagesc(FLAME) 
    colormap jet 
    colorbar
    caxis([0 15])