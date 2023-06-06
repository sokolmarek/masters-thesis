clear all
clc

% Load data
load('sample_data.mat')

% Preallocate
numSamples = length(ecg);
CM = zeros(numSamples, 32, 32, 3);

% Create and fuse causal matrices using copula-granger method
for i = 1:numSamples
    disp(i)
    
    cm1 = copula_granger(reshape(ecg{i}, 32, [])');
    cm2 = copula_granger(reshape(rsp{i}, 32, [])');
    cm3 = copula_granger(reshape(eda{i}, 32, [])');
    
    % Fused causal matrices are saved in CM variable
    CM(i, :, :, :) = cat(3, cm1, cm2, cm3);
end

% Plot results for each channel c (ecg, rsp, eda)
tiledlayout(1, 4)
nexttile; imshow(reshape(CM(1, :, :, 1), [32, 32, 1])); title('ECG')
nexttile; imshow(reshape(CM(1, :, :, 2), [32, 32, 1])); title('RSP')
nexttile; imshow(reshape(CM(1, :, :, 3), [32, 32, 1])); title('EDA')
nexttile; imshow(reshape(CM(1, :, :, :), [32, 32, 3])); title('Fused')