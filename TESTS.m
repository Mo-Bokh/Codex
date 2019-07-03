


clear all; close all; clc

SPEstruct = load_SPE_filetype;

A = SPEstruct.data{1,1} ;
A = A - mean(mean(A(1:300,:)));
A = A';
B = SPEstruct.data{1,2};

%initilize variables
Z = zeros (177,29);
Zl = zeros (250,65);
Zm =zeros (250,65);
Zr = zeros (250,65);

M = zeros (1024);
Ml = zeros (1024);
Mm = zeros (1024);
Mr = zeros (1024);

N = zeros(1024);
Nl = zeros(1024); 
Nm = zeros(1024);
Nr = zeros(1024); 

thc = 20;
h = 250 ;
w = 65;
tn = 5;
inc = 20;
 
img = zeros(300, 400, tn); 
 

%create a mask with thickness of 10 data points
 for i=1:1:h
     
    for j=1:1:w
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:thc
                    
                    Zm(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
% flip the mask to correct orientation

Zm= flipud(Zm);

for sn = 1 : 1 : tn  
    
Mm = zeros (1024);
 
Nm = zeros(1024);
   
%apply mask to each frame and stack them to one matrix
for i = 1:1:119 ; 

% Extract data from each frame   
C= SPEstruct.data{1,i} - mean(mean(SPEstruct.data{1,i}(:,1:300))); %Extract data of each frame
C = C'; %invert it to correct orientation

SG = sgolayfilt(sum(C),3,51); % smooth the summation of data files to find place of concentration
[pks,locs]=findpeaks(SG, 'MINPEAKHEIGHT', (max(SG)/1.2)); % find place of peaks

% disp(locs(1))

% ---- Cut matrix from each frame -----

SDm = C(418:668 , (locs(1)- 23 - (sn-1) *inc ):(locs(1) + 41 - (sn-1) * inc)); % [ 25 Point from the middle part of each frame ]

% ---- Initialize empty matrix to apply mask on

Fm=zeros(1024);
ZZ=zeros(1024);

%Showcase
if(i==1)

    ZZ(418:668 , (locs(1)- 23 - (sn-1) *inc):(locs(1)+ 41 - (sn-1) * inc)) + (Zm*700) ;
    ZZ = C + ZZ
    
    img(1,1,1) = ZZ(400:700 , 0 : 400);
        
end

% ---- Apply mask on data ----

Xm = SDm .* Zm;

% ----- Insert masked data in the empty matrix -----

Fm(418:668 , (locs(1)- 23 - (sn-1) *inc):(locs(1)+ 41 - (sn-1) * inc)) = Xm;

% ----  Add masked data together -----

Mm = Mm + Fm;

% ---- Count number of data added on each index in the matrix ----

Pm = Fm~=0;

Nm = Nm + Pm;

end

% ------ Average out frames ------
Mm(Nm~=0) = Mm(Nm~=0) ./ Nm(Nm~=0);

Mc(:,:,sn) = Mm;

end

% ----------- Display Images -------------
for n=1:1:tn

subplot(tn,1,n);imagesc(Mc(:,:,n))
colormap jet
colorbar
caxis([0 300])

end

for n=1:1:tn

subplot(tn,1,n);imagesc(img(:,:,n))
colormap jet
colorbar
caxis([0 300])

end
