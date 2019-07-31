
clear all; close all; clc

Calib1 = load('10Calib');
Calib2 = load('44Calib');

Calib1 = Calib1.Calib;
Calib2 = Calib2.Calib;



P = ((Calib1~=0) +(Calib2~=0));


FinalCalib = ((Calib1+Calib2)./P);

figure; imagesc(Calib1)
colormap jet
colorbar
caxis([0 200])

figure; imagesc(Calib2)
colormap jet
colorbar
caxis([0 200])

figure; imagesc(FinalCalib)
colormap jet
colorbar
caxis([0 200])
