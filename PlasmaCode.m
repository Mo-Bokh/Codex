clear all; close all; clc

SPEstruct(1) = load_SPE_filetype; % load SPE 44
SPEstruct(2) = load_SPE_filetype; % load SPE 45

% ------ Parameters ------

NumMsk = 60; % Number of masks used

ThickDataMsk = 20; % Number of data collected per row in Mask
HeightMsk = 250 ; % Height of mask

SpanMsk = 120; % Span of masks across each side
SideShift = 140; % Distance between left and right masks

% ---- initilize empty variables ------
LMsk =zeros (250,65);

FinalResult = zeros(1024,1024,2);


imgL = zeros(300, 400, NumMsk); 
imgR = zeros(300, 400, NumMsk); 

% ------ create a mask with thickness specified-----
 for i=1:1:HeightMsk
     
    for j=1:1:60
       
        if (i==6*j) 
        
            for k=0:1:5
        
                for l=0:1:ThickDataMsk
                    
                    LMsk(i + k,j + l) = 1;
                
                end
        
            end
        
        end
        
    end
     
 end
 
LMsk= flipud(LMsk); % flip the mask to correct orientation
RMsk= fliplr(LMsk); % flip the mask to correct orientation

WidthMsk = size(LMsk,2); % extract width parameter 

MskInc = floor((SpanMsk-WidthMsk)/NumMsk); % calculate increment of masks

% ----- Data collection Algorithim -----
for d = 1 : 1 : 2
    
 NcL = zeros(1024);
 NcR = zeros(1024);
   
    
for sn = 1 : 1 : NumMsk  
    
ML = zeros (1024);
NL = zeros(1024);

MR = zeros (1024);
NR = zeros(1024);
   

%apply mask to each frame and stack them to one matrix
for i = 1:1:119 ; 

% Extract data from each frame   
RawData= SPEstruct(d).data{1,i} - mean(mean(SPEstruct(d).data{1,i}(:,1:100))); %Extract data of each frame
RawData = RawData'; %invert it to correct orientation

ConcenData = sgolayfilt(sum(RawData),3,65); % smooth the summation of data files to find place of concentration
[pks,locs]=findpeaks(ConcenData, 'MINPEAKHEIGHT', (max(ConcenData)/1.7)); % find place of peaks

% disp(locs(1))


% ------------------- Apply Algorithim on left side -----------------------
%__________________________________________________________________________

if (locs(1)- (WidthMsk-52) - (sn-1) *MskInc ) > 0 
    
% ---- Cut matrix from each frame -----
    
CutDataL = RawData(268:518 , (locs(1)- (WidthMsk-52) - (sn-1) *MskInc ):(locs(1) + 51 - (sn-1) * MskInc)); % Cut data using masks

% ---- Initialize empty matrix to apply mask on

MskCarrierL=zeros(1024);
ShowMskL=zeros(1024);

%Showcase area of interest
if(i==1)
    ShowMskL(268:518 , (locs(1)- (WidthMsk-52) - (sn-1) *MskInc):(locs(1)+ 51 - (sn-1) * MskInc)) = (LMsk.*700) ;      
    ShowMskL = RawData + ShowMskL;          
    imgL(:,:,sn) = ShowMskL(250:549 , 1 : 400);            
end

% ---- Apply mask on data ----

XL = CutDataL .* LMsk;

% ----- Insert masked data in the empty matrix -----

MskCarrierL(268:518 , (locs(1)- (WidthMsk-52) - (sn-1) *MskInc):(locs(1)+ 51 - (sn-1) * MskInc)) = XL;

% ----  Add masked data together -----

ML = ML + MskCarrierL;

% ---- Count number of data added on each index in the matrix ----

NumDataL = MskCarrierL~=0;
NL = NL + NumDataL;

end

% ------------------ Apply Algorithim on right side -----------------------
%__________________________________________________________________________

if ((locs(1) + 41 - (sn-1) * MskInc) + SideShift) <= 1024 

% ---- Cut matrix from each frame -----   
CutDataR = RawData(268:518 ,(locs(1)- (WidthMsk-42) - (sn-1) *MskInc )+ SideShift:(locs(1) + 41 - (sn-1) * MskInc) + SideShift) ;

% ---- Initialize empty matrix to apply mask on
MskCarrierR=zeros(1024);
ShowMskR=zeros(1024);

%Showcase area of interest
if(i==1)
    ShowMskR(268:518 , (locs(1)- (WidthMsk-42) - (sn-1) *MskInc )+ SideShift:(locs(1) + 41 - (sn-1) * MskInc) + SideShift) = (RMsk.*700) ;
    ShowMskR = RawData + ShowMskR;
    imgR(:,:,sn) = ShowMskR(250:549 , 1 : 400);
end
% ---- Apply mask on data ----
XR = CutDataR .* RMsk;

% ----- Insert masked data in the empty matrix -----
MskCarrierR(268:518 , (locs(1)- (WidthMsk-42) - (sn-1) *MskInc )+ SideShift:(locs(1) + 41 - (sn-1) * MskInc) + SideShift) = XR;

% ----  Add masked data together -----
MR = MR + MskCarrierR;

% ---- Count number of data added on each index in the matrix ----
NumData = MskCarrierR~=0;
NR = NR + NumData;

end

end

% ------ Average out frames ------
ML(NL~=0) = ML(NL~=0) ./ NL(NL~=0);
MR(NR~=0) = MR(NR~=0) ./ NR(NR~=0);

ResultCollectionL(:,:,sn) = ML;
ResultCollectionR(:,:,sn) = MR;


nonZeroL = ML~=0;
nonZeroR = MR~=0;

NcL = NcL + nonZeroL;
NcR = NcR + nonZeroR;


end

% Summing graphs of different mask position and averaging them
totalResultL = sum(ResultCollectionL,3);
totalResultR = sum(ResultCollectionR,3);

totalResultL(NcL~=0) = totalResultL(NcL~=0) ./ NcL(NcL~=0);
totalResultR(NcR~=0) = totalResultR(NcR~=0) ./ NcR(NcR~=0);


nonZeroTotalL = totalResultL ~=0;
nonZeroTotalR = totalResultR ~=0;

FinalResult(:,:,d) = ((totalResultL + totalResultR).* nonZeroTotalL .* nonZeroTotalR)./2;


end

nonZeroFinal = (FinalResult(:,:,1)~=0) + (FinalResult(:,:,2)~=0);
nonZeroMskFinal = (FinalResult(:,:,1)~=0) .* (FinalResult(:,:,2)~=0);
Calib = ((sum(FinalResult,3)).* nonZeroMskFinal) ./ 2; % Final calibration matrix to use on flame data. 

figure; imagesc(Calib)
colormap jet
colorbar
caxis([0 200])

%----------- Display Images -------------
% for n=1:1:NumMsk
% 
% subplot(NumMsk,2,(n*2)-1);imagesc(ResultCollectionL(:,:,n))
% colormap jet
% colorbar
% caxis([0 300])
% 
% subplot(NumMsk,2,(n*2));imagesc(imgL(:,:,n))
% colormap jet
% caxis([0 900])
% end
% 
% figure;imagesc(totalResultL)
% colormap jet
% colorbar
% caxis([0 300])
% 
% figure;
% for n=1:1:NumMsk
% 
% subplot(NumMsk,2,(n*2)-1);imagesc(ResultCollectionR(:,:,n))
% colormap jet
% colorbar
% caxis([0 300])
% 
% subplot(NumMsk,2,(n*2));imagesc(imgR(:,:,n))
% colormap jet
% caxis([0 900])
% end
% 
% figure;imagesc(totalResultR)
% colormap jet
% colorbar
% caxis([0 300])
% 
% 
% 
% 
% 
% figure;imagesc(FinalResult(:,:,1))
% colormap jet
% colorbar
% caxis([0 300])
% 
% 
%  figure;imagesc(FinalResult(:,:,2))
%  colormap jet
%  colorbar
%  caxis([0 300])
