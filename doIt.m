clear all
close all

%% Dependencies
toolDir = fullfile(pwd, 'externalTools');
tool = 'fieldtrip'; toolURL = 'https://github.com/fieldtrip/fieldtrip';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'fieldtrip/external/freesurfer')))


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

