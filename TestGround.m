
clear all; close all; clc

SPEstruct = load_SPE_filetype

A = SPEstruct.data{1,119} ;
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


% I = (eye(41));
% I = I'; I = I == 1;
% I = fliplr(I);
 M = zeros (1024);



for i = 1:1:119 ; 

    
C= SPEstruct.data{1,i} .*(SPEstruct.data{1,i}>615); %Extract data of each frame
C = C'; 


SG = sgolayfilt(sum(C),3,51); % smooth the summation of data files to find place of concentration
figure; plot(SG)
[pks,locs]=findpeaks(SG, 'MINPEAKHEIGHT', (max(SG)/1.2)); % find place of peaks

S= C(460:638 , (locs(1)-16):(locs(1)+16)); %cut matrix from data

F=zeros(1024); %initialize empty matrix to apply mask on

X = S.*Z; % apply mask on data



F(460:638 , 117+i*5:149+i*5) = X; % insert masked data in the empty matrix

%figure;imagesc(F)


M = M + F;  % add masked data together


end 

%figure; imagesc(M)
% figure; imagesc(A')
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

colorbar