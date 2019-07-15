function [increments] = provideSteps(startingPosition, step, frames, mm2px)
	conv_giri = 2529.258 % to convert from motor step to mm in in x direction
	actualPoints = [startingPosition: -step/conv_giri: startingPosition - step*frames/conv_giri];
	model = @(x,a,b,c) a + sqrt(abs( c^2 - (c-x-b).^2 ))
	pop =  [48.14502678, -25.24894796, -27.37497418]; %  data already obtained fitting a
	increments = round(diff(mm2px * model(actualPoints,pop(1),pop(2),pop(3))))

    