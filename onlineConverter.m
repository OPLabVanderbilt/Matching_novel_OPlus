%{
Converts this task to the online format encoding the experiment information
into the image titles. Also adds same-different buttons as necessary. This
script needs the computer vision toolbox for the text functions.

Originally built for OT_Beta.
Jan13, 2020 - Jason Chow
%}
clear all;

%% Generation parameters
% Experiment parameter
intertrialInterval = 500; % Intertrtial interval
fixTime = 500; % Fixation time
img1TimeLong = 300; % Image 1 long presentation time
img1TimeShort = 150; % Image 1 short presentation time
maskTime = 500; % Mask time
responseTime = 3000; % Maximum response time
smallImgSize = [95, 95]; % For trials with smaller images
normalImgSize = [125, 125]; % For all other images

% Image parameters
imgSouce = 'stimuli';
maskFile = 'mask_Ziggerin.jpg';
fixFile = 'onlineAssets/fixation.png';
targetSize = [800, 800]; % Will do the best it can to be close to this

% Button parameters
rectangles = [50, 550, 300, 100; 450, 550, 300, 100];
colors = {'green', 'red'};
text = {'same', 'different'};
textPosition = [200, 600; 600, 600];

%% Check folder and move convert instructions
if ~exist('onlineExperiment', 'dir')
    mkdir('onlineExperiment');
end

% Convert instructions
inst = dir('onlineAssets/trial*');
inst = {inst.name};

for i = 1:numel(inst)
    fileName = inst{i};
    img = imread(['onlineAssets/' fileName]);
    fileName = strrep(fileName, '.png', '.jpg');
    imwrite(img, ['onlineExperiment/' fileName]);
end 

%% Generate mask and fixation image
% Load image
maskImg = imread(maskFile);
maskImg = imresize(maskImg, normalImgSize);
imgSize = size(maskImg);

% Calculate padding
padding = round((targetSize - imgSize(1:2))/2);

% Assumes the top left of the mask is a white pixel
white = maskImg(1, 1, :);

% Extend first dimension
maskImg = [repmat(white, [padding(1), imgSize(2), 1]); maskImg; ...
    repmat(white, [padding(1), imgSize(2), 1])];

% Extend second dimension
maskImg = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
    maskImg, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];

% Load fixation
fixImg = imread(fixFile);
imgSize = size(fixImg);

% Calculate padding
padding = round((targetSize - imgSize(1:2))/2);

% Extend first dimension
fixImg = [repmat(white, [padding(1), imgSize(2), 1]); fixImg; ...
    repmat(white, [padding(1), imgSize(2), 1])];

% Extend second dimension
fixImg = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
    fixImg, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];

%% Assemble practice trials
% Determine trial start
files = dir('onlineExperiment/trial*');
files = sort({files.name});
trialNum = strsplit(files{numel(files)}, '_');
trialNum = str2double(trialNum{2});

% Load practice trials
pracTrials = readtable('practice_Ziggerin.txt', ...
    'Format', '%u %u %s %s %s %s %s');
varNames = {'Category', 'Trial', 'CorrResponse', 'Viewpoint', ...
    'Size', 'Img1', 'Img2'};
pracTrials.Properties.VariableNames = varNames;

for i = 1:height(pracTrials)
    % Create fixation image
    trialNum = trialNum + 1;
    imgName = ['trial_' num2str(trialNum) '_block-0_limit-' ...
        num2str(fixTime) '.jpg'];
    imwrite(fixImg, ['onlineExperiment/' imgName]);
    
    % Load and resize first image
    trialNum = trialNum + 1;
    img = imread(['stimuli/' pracTrials.Img1{i}]);
    img = imresize(img, normalImgSize);
    imgSize = size(img);
    
    % Calculate padding
    padding = round((targetSize - imgSize(1:2))/2);
    
    % Add padding
    img = [repmat(white, [padding(1), imgSize(2), 1]); img; ...
        repmat(white, [padding(1), imgSize(2), 1])]; %#ok<*AGROW>
    img = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
        img, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];
    
    % Save image 1
    imgName = ['trial_' num2str(trialNum) '_block-0_limit-' ...
        num2str(img1TimeLong) '.jpg'];
    imwrite(img, ['onlineExperiment/' imgName]);
    
    % Create mask image
    trialNum = trialNum + 1;
    imgName = ['trial_' num2str(trialNum) '_block-0_limit-' ...
        num2str(maskTime) '.jpg'];
    imwrite(maskImg, ['onlineExperiment/' imgName]);
    
    % Incremement counter and load image 2
    trialNum = trialNum + 1;
    img = imread(['stimuli/' pracTrials.Img2{i}]);
    
    % Resize as needed
    if strcmp(pracTrials.Size{i}, 'same')
        img = imresize(img, normalImgSize);
    else
        img = imresize(img, smallImgSize);
    end
    imgSize = size(img);
    
    % Calculate padding
    padding = round((targetSize - imgSize(1:2))/2);
    
    % Add padding
    img = [repmat(white, [padding(1), imgSize(2), 1]); img; ...
        repmat(white, [padding(1), imgSize(2), 1])];
    img = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
        img, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];
    
    % Add buttons
    img = insertShape(img, 'FilledRectangle', rectangles, 'Color', ...
        colors);
    img = insertText(img, textPosition, text, 'FontSize', 50, ...
        'BoxOpacity', 0, 'AnchorPoint', 'Center'); 

    % Save image 2
    imgName = ['trial_' num2str(trialNum), ...
        '_block-0_sections-2_clickable-true_limit-' ...
        num2str(responseTime) '_isi-' num2str(intertrialInterval) '.jpg'];
    imwrite(img, ['onlineExperiment/' imgName]);
end

% Create post practice screen
trialNum = trialNum + 1;
img = imread('onlineAssets/pracEnd.png');
imwrite(img, ['onlineExperiment/trial_' num2str(trialNum), ...
    '_block-0_sections-1_clickable-true_isi-250.jpg']);

% Load test trials
trials = readtable('trials_Ziggerin.txt', ...
    'Format', '%u %u %s %s %s %s %s');
trials.Properties.VariableNames = varNames;

block = 0;
for i = 1:height(trials)
    if i > 1 && mod(i - 1, 90) == 0
        if i == 91 % Quarter way through
            trialNum = trialNum + 1;
            img = imread('onlineAssets/doneQuarter.png');
            imwrite(img, ['onlineExperiment/trial_' num2str(trialNum), ...
                '_block-' num2str(block) ...
                '_sections-1_clickable-true_isi-250.jpg']);
        elseif i == 181 % Halfway through
            trialNum = trialNum + 1;
            img = imread('onlineAssets/doneHalf.png');
            imwrite(img, ['onlineExperiment/trial_' num2str(trialNum), ...
                '_block-' num2str(block) ...
                '_sections-1_clickable-true_isi-250.jpg']);
        elseif i == 271 % Three quarters way through
            trialNum = trialNum + 1;
            img = imread('onlineAssets/doneThreeQuarter.png');
            imwrite(img, ['onlineExperiment/trial_' num2str(trialNum), ...
                '_block-' num2str(block) ...
                '_sections-1_clickable-true_isi-250.jpg']);
        end
    end
    % Increment block
    block = block + 1;
    
    % Create fixation image
    trialNum = trialNum + 1;
    imgName = ['trial_' num2str(trialNum) '_block-' num2str(block) ...
        '_limit-' num2str(fixTime) '.jpg'];
    imwrite(fixImg, ['onlineExperiment/' imgName]);
    
    % Load and resize first image
    trialNum = trialNum + 1;
    img = imread(['stimuli/' trials.Img1{i}]);
    img = imresize(img, normalImgSize);
    imgSize = size(img);
    
    % Calculate padding
    padding = round((targetSize - imgSize(1:2))/2);
    
    % Add padding
    img = [repmat(white, [padding(1), imgSize(2), 1]); img; ...
        repmat(white, [padding(1), imgSize(2), 1])]; 
    img = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
        img, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];
    
    % Determine presentation time and create image 1
    if i < 181
        img1Time = img1TimeLong;
    else
        img1Time = img1TimeShort;
    end
        
    imgName = ['trial_' num2str(trialNum) '_block-' num2str(block) ...
        '_limit-' num2str(img1Time) '.jpg'];
    imwrite(img, ['onlineExperiment/' imgName]);
    
    % Create mask
    trialNum = trialNum + 1;
    imgName = ['trial_' num2str(trialNum) '_block-' num2str(block) ...
        '_limit-' num2str(maskTime) '.jpg'];
    imwrite(maskImg, ['onlineExperiment/' imgName]);
    
    % Incremement counter and load image 2
    trialNum = trialNum + 1;
    img = imread(['stimuli/' trials.Img2{i}]);
    
    % Resize as needed
    if strcmp(trials.Size{i}, 'same')
        img = imresize(img, normalImgSize);
    else
        img = imresize(img, smallImgSize);
    end
    imgSize = size(img);
    
    % Calculate padding
    padding = round((targetSize - imgSize(1:2))/2);
    
    % Add padding
    img = [repmat(white, [padding(1), imgSize(2), 1]); img; ...
        repmat(white, [padding(1), imgSize(2), 1])];
    img = [repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1]), ...
        img, repmat(white, [imgSize(1)+(padding(1)*2), padding(2), 1])];
    
    % Add buttons
    img = insertShape(img, 'FilledRectangle', rectangles, 'Color', ...
        colors);
    img = insertText(img, textPosition, text, 'FontSize', 50, ...
        'BoxOpacity', 0, 'AnchorPoint', 'Center'); 

    % Save image 2
    imgName = ['trial_' num2str(trialNum), ...
        '_block-' num2str(block) '_sections-2_clickable-true_limit-' ...
        num2str(responseTime) '_isi-' num2str(intertrialInterval) '.jpg'];
    imwrite(img, ['onlineExperiment/' imgName]);
end

%% Package images into zips for upload with workaround
allTrials = dir('onlineExperiment/trial*');
allTrials = {allTrials.name};
packs = ceil(numel(allTrials)/250);

% Zip together sets of images for upload
for i = 1:packs
    if i == packs % Last pack
        zip(['onlineZiggMatching' num2str(i) '.zip'], ...
            allTrials((((i-1)*250)+1):numel(allTrials)),...
            'onlineExperiment')
    else
        zip(['onlineZiggMatching' num2str(i) '.zip'], ...
            allTrials((((i-1)*250)+1):i*250), 'onlineExperiment')
    end
end
