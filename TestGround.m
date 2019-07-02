
clear all; close all; clc

SPEstruct = load_SPE_filetype

A = SPEstruct.data{1,1} ;
A = A - mean(mean(A(1:300,:)));
A = A';
B = SPEstruct.data{1,2};

%initilize variables
Z = zeros (177,29);
Zl = zeros (177,29);
Zm =zeros (177,29);
Zr = zeros (177,29);

M = zeros (1024);
Ml = zeros (1024);
Mm = zeros (1024);
Mr = zeros (1024);

N = zeros(1024);
Nl = zeros(1024); 
Nm = zeros(1024);
Nr = zeros(1024); 



 %create a mask with thickness of 5 data points
 for i=1:1:177
     
    for j=1:1:177
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:4
                    
                    Z(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
 
 %create a mask with thickness of 18 data points
 for i=1:1:177
     
    for j=1:1:177
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:17
                    
                    Zl(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
  %create a mask with thickness of 18 data points
 for i=1:1:177
     
    for j=1:1:177
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:25
                    
                    Zm(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
  %create a mask with thickness of 10 data points
 for i=1:1:177
     
    for j=1:1:177
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:9
                    
                    Zr(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
% flip the mask to correct orientation
Z = flipud(Z);
Zl= flipud(Zl);
Zm= flipud(Zm);
Zr= flipud(Zr);

%apply mask to each frame and stack them to one matrix
for i = 1:1:119 ; 

% Extract data from each frame   
C= SPEstruct.data{1,i} - mean(mean(SPEstruct.data{1,i}(:,1:300))); %Extract data of each frame
C = C'; %invert it to correct orientation


SG = sgolayfilt(sum(C),3,51); % smooth the summation of data files to find place of concentration
[pks,locs]=findpeaks(SG, 'MINPEAKHEIGHT', (max(SG)/1.2)); % find place of peaks

disp(locs(1))

% ---- Cut matrix from each frame -----
SD= C(460:638 , (locs(1)-16):(locs(1)+16)); % [ 5 points from the bulk of each frame]
SDl = C(460:638 , (locs(1)-53):(locs(1)-8)); % [ 18 points from the left part of each frame ]
SDm = C(460:638 , (locs(1)- 34):(locs(1)+19)); % [ 26 Point from the middle part of each frame ]
SDr = C(460:638 , (locs(1)- 9):(locs(1)+28)); % [ 10 Point from the right part of each frame ]


% ---- Initialize empty matrix to apply mask on
F=zeros(1024); 
Fl=zeros(1024);
Fm=zeros(1024);
Fr=zeros(1024);


% ---- Apply mask on data ----
X = SD.*Z; 
Xl = SDl.*Zl;
Xm = SDm .* Zm;
Xr = SDr .* Zr;

% ----- Insert masked data in the empty matrix -----
F(460:638 , (locs(1)-16):(locs(1)+16)) = X; 
Fl(460:638 , (locs(1)-53):(locs(1)-8)) = Xl;
Fm(460:638 , (locs(1)- 34):(locs(1)+19)) = Xm;
Fr(460:638 , (locs(1)- 9):(locs(1)+28)) = Xr;




%figure;imagesc(F)

% ----  Add masked data together -----
M = M + F;  
Ml = Ml + Fl;
Mm = Mm + Fm;
Mr = Mr + Fr;


% ---- Count number of data added on each index in the matrix ----

P = F~=0;
Pl = Fl~=0;
Pm = Fm~=0;
Pr = Fr~=0;

N = N + P;
Nl = Nl + Pl;
Nm = Nm + Pm;
Nr = Nr + Pr;
end 

% ------ Average out frames ------
M(N~=0) = M(N~=0) ./ N(N~=0);
Ml(Nl~=0) = Ml(Nl~=0) ./ Nl(Nl~=0);
Mm(Nm~=0) = Mm(Nm~=0) ./ Nm(Nm~=0);
Mr(Nr~=0) = Mr(Nr~=0) ./ Nr(Nr~=0);


% figure; plot(sum(A'))
% SG = sgolayfilt(sum(A'),3,31);

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

% ----------- Display Images -------------
subplot(3,1,1);imagesc(Ml)
colormap jet
colorbar
caxis([0 300])


subplot(3,1,2);imagesc(Mm)
colormap jet 
colorbar
caxis([0 300])


subplot(3,1,3);imagesc(Mr)
colormap jet 
colorbar
caxis([0 300])

figure;imagesc(M) 
colormap jet 
colorbar

figure;imagesc(A)
colormap jet 
colorbar

