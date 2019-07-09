clear all; close all; clc

FLAMEstruct = load_SPE_filetype;

SPEstruct(1) = load_SPE_filetype;
SPEstruct(2) = load_SPE_filetype;
% ------ Parameters ------

tn = 5; % Number of masks used

thc = 20; % Number of data collected per row in Mask
h = 250 ; % Height of mask

Span = 120; % Span of masks across each side
sShift = 140; % Distance between left and right masks

% ---- initilize empty variables ------
Zm =zeros (250,65);

FINAL = zeros(1024,1024,2);


img = zeros(300, 400, tn); 
imgr = zeros(300, 400, tn); 

% ------ create a mask with thickness of 10 data points-----
 for i=1:1:h
     
    for j=1:1:60
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:thc
                    
                    Zm(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
Zm= flipud(Zm); % flip the mask to correct orientation
Zr= fliplr(Zm); % flip the mask to correct orientation

w = size(Zm,2); % extract width parameter 

inc = floor((120-w)/tn); % calculate increment of masks

% ----- Data collection Algorithim -----
for d = 1 : 1 : 2
    
 Nc = zeros(1024);
 Ncr = zeros(1024);
   
    
for sn = 1 : 1 : tn  
    
Mm = zeros (1024);
Nm = zeros(1024);

Mr = zeros (1024);
Nr = zeros(1024);
   

%apply mask to each frame and stack them to one matrix
for i = 1:1:119 ; 

% Extract data from each frame   
C= SPEstruct(d).data{1,i} - mean(mean(SPEstruct(d).data{1,i}(:,1:100))); %Extract data of each frame
C = C'; %invert it to correct orientation

SG = sgolayfilt(sum(C),3,65); % smooth the summation of data files to find place of concentration
[pks,locs]=findpeaks(SG, 'MINPEAKHEIGHT', (max(SG)/1.7)); % find place of peaks

% disp(locs(1))


% ------------------- Apply Algorithim on left side -----------------------
%__________________________________________________________________________

if (locs(1)- (w-52) - (sn-1) *inc ) > 0 
    
% ---- Cut matrix from each frame -----
    
SDm = C(268:518 , (locs(1)- (w-52) - (sn-1) *inc ):(locs(1) + 51 - (sn-1) * inc)); % [ 25 Point from the middle part of each frame ]

% ---- Initialize empty matrix to apply mask on

Fm=zeros(1024);
ZZ=zeros(1024);

%Showcase area of interest
if(i==1)
    ZZ(268:518 , (locs(1)- (w-52) - (sn-1) *inc):(locs(1)+ 51 - (sn-1) * inc)) = (Zm.*700) ;      
    ZZ = C + ZZ;          
    img(:,:,sn) = ZZ(250:549 , 1 : 400);            
end

% ---- Apply mask on data ----

Xm = SDm .* Zm;

% ----- Insert masked data in the empty matrix -----

Fm(268:518 , (locs(1)- (w-52) - (sn-1) *inc):(locs(1)+ 51 - (sn-1) * inc)) = Xm;

% ----  Add masked data together -----

Mm = Mm + Fm;

% ---- Count number of data added on each index in the matrix ----

Pm = Fm~=0;
Nm = Nm + Pm;

end

% ------------------ Apply Algorithim on right side -----------------------
%__________________________________________________________________________

if ((locs(1) + 41 - (sn-1) * inc) + sShift) <= 1024 

% ---- Cut matrix from each frame -----   
SDr = C(268:518 ,(locs(1)- (w-42) - (sn-1) *inc )+ sShift:(locs(1) + 41 - (sn-1) * inc) + sShift) ;

% ---- Initialize empty matrix to apply mask on
Fr=zeros(1024);
ZZr=zeros(1024);

%Showcase area of interest
if(i==1)
    ZZr(268:518 , (locs(1)- (w-42) - (sn-1) *inc )+ sShift:(locs(1) + 41 - (sn-1) * inc) + sShift) = (Zr.*700) ;
    ZZr = C + ZZr;
    imgr(:,:,sn) = ZZr(250:549 , 1 : 400);
end
% ---- Apply mask on data ----
Xr = SDr .* Zr;

% ----- Insert masked data in the empty matrix -----
Fr(268:518 , (locs(1)- (w-42) - (sn-1) *inc )+ sShift:(locs(1) + 41 - (sn-1) * inc) + sShift) = Xr;

% ----  Add masked data together -----
Mr = Mr + Fr;

% ---- Count number of data added on each index in the matrix ----
Pr = Fr~=0;
Nr = Nr + Pr;

end

end

% ------ Average out frames ------
Mm(Nm~=0) = Mm(Nm~=0) ./ Nm(Nm~=0);
Mr(Nr~=0) = Mr(Nr~=0) ./ Nr(Nr~=0);

Mc(:,:,sn) = Mm;
Mcr(:,:,sn) = Mr;


Pc = Mm~=0;
Pcr = Mr~=0;

Nc = Nc + Pc;
Ncr = Ncr + Pcr;


end

% Summing graphs of different mask position and averaging them
Mt = sum(Mc,3);
Mtr = sum(Mcr,3);

Mt(Nc~=0) = Mt(Nc~=0) ./ Nc(Nc~=0);
Mtr(Ncr~=0) = Mtr(Ncr~=0) ./ Ncr(Ncr~=0);


PCTL = Mt ~=0;
PCTR = Mtr ~=0;

FINAL(:,:,d) = ((Mt + Mtr).* PCTL .* PCTR)./2;


end

Calib = sum(FINAL,3) / 2; 


for i = 40:41
   P = FLAMEstruct.data{1,i};
   P=P' - 620;
   
   P(Calib~=0)= P(Calib~=0)./Calib(Calib~=0)
   P = P .* (Calib~=0);
   figure;imagesc(P)
   colormap jet
   colorbar
   caxis([0 200])
end


% ----------- Display Images -------------
% for n=1:1:tn
% 
% subplot(tn,2,(n*2)-1);imagesc(Mc(:,:,n))
% colormap jet
% colorbar
% caxis([0 300])
% 
% subplot(tn,2,(n*2));imagesc(img(:,:,n))
% colormap jet
% caxis([0 900])
% end
% 
% figure;imagesc(Mt)
% colormap jet
% colorbar
% caxis([0 300])
% 
% figure;
% for n=1:1:tn
% 
% subplot(tn,2,(n*2)-1);imagesc(Mcr(:,:,n))
% colormap jet
% colorbar
% caxis([0 300])
% 
% subplot(tn,2,(n*2));imagesc(imgr(:,:,n))
% colormap jet
% caxis([0 900])
% end
% 
% figure;imagesc(Mtr)
% colormap jet
% colorbar
% caxis([0 300])

figure;imagesc(FINAL(:,:,1))
colormap jet
colorbar
caxis([0 300])


 figure;imagesc(FINAL(:,:,2))
 colormap jet
 colorbar
 caxis([0 300])
