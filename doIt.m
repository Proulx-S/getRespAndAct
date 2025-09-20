clear all
close all

%% Dependencies
toolDir = fullfile(pwd, 'externalTools');
tool = 'fieldtrip'; toolURL = 'https://github.com/fieldtrip/fieldtrip';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'fieldtrip/external/freesurfer')))

% AFNI
% (you might need to change src.afni to whatever shell command your system need to source afni)
% (here neurodesk is assumed)
global src
src.afni = 'ml afni/24.3.00';
system([src.afni '; 3dinfo > /dev/null'],'-echo');



%% Data
tmp = MRIread('reversed_run_averaged_velocity.nii.gz',1);
nFrame = tmp.nframes;
tr = tmp.tr/1000; % in seconds

%% Design
dsgn = runDsgn;
dsgn.task = 'visStim';
nEvent = 5;
for iE = 1:nEvent
    dsgn.onsetList(iE) = (iE-1)*60 + 18;  % in seconds
    dsgn.ondurList(iE) = 24;              % in seconds
    dsgn.cond(iE) = 1;                    % condition index (0 is special for null event/trial, other conditions should be increments of 1)
end



force = 1;
verbose = 2;
fVolTs = fullfile(pwd,'reversed_run_averaged_velocity.nii.gz');
param.trDecon   = 2; % in seconds. If empty or undefined, it will be set to the tr of the fVolTs
param.fracDecon = 0.75; % fraction of the maximum possible deconvolution window (minimum ISI) as a real number between 0 and 1. If 0 or empty, the full window is used (equivalent to 1). Default is 1.
[fRespCat,fRespRun,fActCat,fActRun] = getRespAndAct(fVolTs,dsgn,[],param,force,verbose)

%% Info

% IRF results for indivudual runs
fRespRun.fResp            % Stimulus response (IRF)
fRespRun.fRespStd         % Std of stimulus response (IRF)
fRespRun.cmd              % afni command used
fRespRun.fMatFig          % design matrix figure
fRespRun.fStat            % afni format statistic file
fRespRun.stats.fPoly0Base % fitted baseline
fRespRun.stats.fTsAvBase  % time-series average baseline
fRespRun.stats.fFullF     % full model F-statistic
fRespRun.stats.fCondF     % condition-wise F-statistic

% IRF results for concatenated runs
fRespCat % similar as above

% Activation detection results for indivudual runs
fActRun.stats.fCondCoef            % condition-wise coefficients: when fActRun.model='SPMG2', first and second regressors are built from the convolution of the SPM double gamma HRF and its derivative, respectively
fActRun.stats.fCondPolar           % condition-wise coefficients converted in polar coordinates. First and second regressors (in fActRun.stats.fCondCoef) are considered as orthognal dimensions and converted to response magnitude and response delay in fActRun.stats.fCondPolar. Sign of the response is lost in magnitude but can be figured out from delay.
fActRun.stats.fCondCoef_mainVector % when the actual response delay does not match the HRF in most voxels, the first coefficient of fActRun.stats.fCondCoef will not be a very good estimator of response amplitude. This figure shows how we find the overall delay across voxels for rotation of fActRun.stats.fCondCoef coefficients.
fActRun.stats.fCondCoef_adj        % coefficients from fActRun.stats.fCondCoef rotated according to the delay estimated in fActRun.stats.fCondCoef_mainVector. This should be the best estimator of response amplitude, but can be wrong if delay estimation failed (see fActRun.stats.fCondCoef_mainVector). THIS IS MOST USEFULL FOR FIGURING OUT THE SIGN OF SUBTLE RESPONSES.
fActRun.cmd                        % afni command used
fActRun.fMatFig                    % design matrix figure
fActRun.fStat                      % afni format statistic file
fActRun.stats.fPoly0Base           % fitted baseline
fActRun.stats.fTsAvBase            % time-series average baseline
fActRun.stats.fFullF               % full model F-statistic
fActRun.stats.fCondF               % condition-wise F-statistic

% Activation detection results for concatenated runs
fActCat % similar as above


