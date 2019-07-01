
clear all; close all; clc

SPEstruct = load_SPE_filetype

A = SPEstruct.data{1,1} ;
A = A.*(A>630);
B = SPEstruct.data{1,2};


% 
% for i=5:1:10
% P = SPEstruct.data{1,i} .*(SPEstruct.data{1,i}>630);
% figure;imagesc(P')
% end

Z = zeros (177,29);
 
 
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

Z = flipud(Z);

M = zeros (1024);
M2 = zeros (1024);


for i = 1:1:119 ; 

    
C= SPEstruct.data{1,i} .*(SPEstruct.data{1,i}>630); %Extract data of each frame
C = C'; 



SG = sgolayfilt(sum(C),3,51); % smooth the summation of data files to find place of concentration
% figure; plot(SG)
[pks,locs]=findpeaks(SG, 'MINPEAKHEIGHT', (max(SG)/1.2)); % find place of peaks

disp(locs(1))

SD= C(460:638 , (locs(1)-16):(locs(1)+16)); %cut matrix from data
SD2 = C(460:638 , (locs(1)-3):(locs(1)+29));



F=zeros(1024); %initialize empty matrix to apply mask on
F2=zeros(1024);


X = SD.*Z; % apply mask on data
X2 = SD2.*Z


F(460:638 , (locs(1)-16):(locs(1)+16)) = X; % insert masked data in the empty matrix
F2(460:638 , (locs(1)-3):(locs(1)+29)) = X2;
%figure;imagesc(F)


M = M + F;  % add masked data together
M2 = M2 + F2;

end 


 figure; imagesc(A')
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
figure;imagesc(M)
figure;imagesc(M2)
colorbar
