
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OT Beta
% Matching task
% Jan13, 2020 - Jason Chow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matching_Ziggerins(subjno, experimenter, hand, dataDir)
try
    %% Experiment parameters
    Screen('Preference', 'SkipSyncTests', 1); %%%%%% TURN THIS OFF %%%%%%%
    
    sameKey = 'G';
    diffKey = 'H';
    ITI = 0.5; % Intertrial interval
    fixTime = 0.5; % Fixation time
    img1TimeLong = 0.3; % Image 1 long presentation time 
    img1TimeShort = 0.15; % Image 1 short presentation time
    maskTime = 0.5; % Mask time
    responseTime = 3; % Maximum response time
    
    %% Setup
    % Standalone startup if needed
    if ~exist('subjno', 'var') && ~exist('experimenter', 'var') && ...
            ~exist('hand', 'var')
        inputInfo = inputdlg({'Subject ID', 'Experimenter', 'L.Q.'});
        subjno = str2double(inputInfo{1});
        experimenter = inputInfo{2};
        hand = str2double(inputInfo{3});
    end
    
    % Check which data directory save to
    if ~exist('dataDir', 'var')
        dataDir = 'data';
    end
    
    % Restrict interaction
    ListenChar(2);
    HideCursor;
    commandwindow;
    RestrictKeysForKbCheck([]);
    
    % Get KbNames for keys
    resp1 = KbName(sameKey);
    resp2 = KbName(diffKey);
    
    % Data format
    dataFormat = '%f,%d,%s,%s,%s,%s,%s,%s,%d,%f,%f,%s,%s\n';
    
    %% Setup Screen
    % Always go to max screen index
    whichScreen = max(Screen('Screens'));
    
    % Make screen and set parameters
    [w, ~] = Screen('OpenWindow', whichScreen, 255);
    Screen(w, 'TextSize', 24);
    Screen(w, 'TextFont', 'Arial');
    Screen(w, 'TextStyle', 1);
    prior = Priority(MaxPriority(w));
    
    % Get info about monitor flip rate
    flipInt = Screen('GetFlipInterval', w);
    slack = flipInt / 2;


    %% Create files for saving data
    % Timestamp
    timestamp = char(datetime('now', 'Format', 'MMM-dd-y--HH-mm-ss'));
    
    % Create datafile
    fileName = [dataDir '/' num2str(subjno) '_matchZigg_' timestamp '.csv'];
    dataFile = fopen(fileName, 'w');
    fprintf(dataFile, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', ...
        'SbjID', 'Trial', 'CorrResponse', 'Viewpoint', 'Size', 'Img1', ...
        'Img2', 'Response', 'Corr', 'RT', 'Handedness', 'Experimenter', ...
        'DateTime');
    fclose(dataFile);

    %% Make mask
    mask = imread('mask_Ziggerin.jpg');
    mask = imresize(mask, [125 125]);
    masktexture = Screen('MakeTexture', w, mask);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Instructions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Restrict to just spacebar for instructions
    RestrictKeysForKbCheck(KbName('space'));
    
    % Load instruction image 1
    instruct1 = imread('instruct1.jpg');
    instruct1_texture = Screen('MakeTexture', w, instruct1);
    
    Screen('DrawTexture', w, instruct1_texture);
    Screen('Flip', w);
    KbWait([], 3); 
    
    % Blank screen briefly
    Screen('Flip',w);

    % Load instruction image 2
    instruct2 = imread('instruct2.jpg');
    instruct2_texture = Screen('MakeTexture', w, instruct2);
    
    Screen('DrawTexture', w, instruct2_texture);
    Screen('Flip', w);
    KbWait([], 3);
    
    % Blank screen briefly
    Screen('Flip',w);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Practice trials
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read in practice trials
    pracTrials = readtable('practice_Ziggerin.txt', ...
        'Format', '%u %u %s %s %s %s %s');
    varNames = {'Category', 'Trial', 'CorrResponse', 'Viewpoint', ...
        'Size', 'Img1', 'Img2'};
    pracTrials.Properties.VariableNames = varNames;
    
    % Display practice trial instructions
    Screen('Flip', w);
    center_text(w, 'Now you will complete a short practice block to familiarize you with the task.', 0, -100);
    center_text(w, ['Press ' sameKey ' for if the two objects are the SAME IDENTITY.'], 0, -50);
    center_text(w, ['Press ' diffKey ' if the two objects are a DIFFERENT IDENTITY.'], 0, 0);
    center_text(w, 'Try to respond as QUICKLY and ACCURATELY as possible.', 0, 50);
    center_text(w, 'Press the spacebar to start the practice block.', 0, 150);
    Screen('Flip', w);
    KbWait([], 3);
    
    % Blank screen for future flip
    Screen('FillRect', w, 255);

    % Restrict keys to response keys
    RestrictKeysForKbCheck([resp1 resp2]);
    
    % First blank screen placeholder
    t = Screen('Flip', w);
    for i = 1:height(pracTrials)
        % Prepare image 1
        S1 = imread(['stimuli/' pracTrials.Img1{i}]);
        S1 = imresize(S1, [125 125]);
        S1texture = Screen('MakeTexture', w, S1);
        
        % Prepare image 2, change size if needed
        S2 = imread(['stimuli/' pracTrials.Img2{i}]);
        if strcmp(pracTrials.Size{i}, 'same')
            S2 = imresize(S2, [125 125]);
        else
            S2 = imresize(S2, [95 95]);
        end
        S2texture = Screen('MakeTexture', w, S2);

        % Fixation cross
        center_text(w, '+', 0, 0);
        t = Screen('Flip', w, t + ITI - slack);
        
        % Image 1 presentation
        Screen('DrawTexture', w, S1texture);
        t = Screen('Flip', w, t + fixTime - slack);

        % Mask
        Screen('DrawTexture', w, masktexture);
        t = Screen('Flip', w, t + img1TimeLong - slack);

        % Image 2 presentation
        Screen('DrawTexture', w, S2texture);
        t = Screen('Flip', w, t + maskTime - slack);

        % Wait for response
        keepGoing = true;
        while keepGoing
            % Check if timeout
            if GetSecs - t > responseTime
                keepGoing = false;
            end
            
            % Check keys
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                responsecode = find(keyCode);
                if length(responsecode) == 1 && (responsecode == resp1 || responsecode == resp2)
                    keepGoing = false;
                end
            end
        end

        % Close image textures
        Screen('Close', S1texture);
        Screen('Close', S2texture);
        
        % Blank
        t = Screen('Flip', w); 
    end

    % Display instructions to move on
    RestrictKeysForKbCheck(KbName('space'));
    Screen('Flip', w);
    center_text(w, 'You have finished the practice block', 0, -100);
    center_text(w, 'If you have any questions, please go get the experimenter.', 0, -50);
    center_text(w, 'Otherwise, press the spacebar to start the experiment.', 0, 0);
    Screen('Flip', w);
    KbWait([], 3);
    
    % Blank screen for upcoming flip
    Screen('FillRect', w, 255);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Experimental Trials
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load trials
    trials = readtable('trials_Ziggerin.txt', ...
        'Format', '%u %u %s %s %s %s %s');
    trials.Properties.VariableNames = varNames;

    % Restrict keys to response keys
    RestrictKeysForKbCheck([resp1 resp2]);
    
    % First blank screen placeholder
    t = Screen('Flip', w);    
    for i = 1:height(trials)
        % Check breaks
        if i > 1 && mod(i - 1, 90) == 0
            % Restrict keys to space
            RestrictKeysForKbCheck(KbName('space'));
            if i == 91 % Quarter of the way through
                Screen('Flip',w);
                center_text(w,'You have completed a quarter of this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            elseif i == 181 % Halfway through
                Screen('Flip',w);
                center_text(w,'You are halfway through this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            elseif i == 271 % Three quaters of the way through
                Screen('Flip',w);
                center_text(w,'You have completed three-quarters of this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            end
            KbWait([], 3);
            
            % Restrict keys to response keys
            RestrictKeysForKbCheck([resp1 resp2]);
            
            % Post break flip placeholder
            t = Screen('Flip', w);
        end
        
        % Prepare image 1
        S1 = imread(['stimuli/' trials.Img1{i}]);
        S1 = imresize(S1, [125 125]);
        S1texture = Screen('MakeTexture', w, S1);
        
        % Prepare image 2, change size if needed
        S2 = imread(['stimuli/' trials.Img2{i}]);
        if strcmp(trials.Size{i}, 'same')
            S2 = imresize(S2, [125 125]);
        else
            S2 = imresize(S2, [95 95]);
        end
        S2texture = Screen('MakeTexture', w, S2);
        
        % Fixation cross
        center_text(w, '+', 0, 0);
        t = Screen('Flip', w, t + ITI - slack);

        % Image 1 presentation
        Screen('DrawTexture', w, S1texture);
        t = Screen('Flip', w, t + fixTime - slack);

        % Mask
        Screen('DrawTexture', w, masktexture);
        if i < 181
            t = Screen('Flip', w, t + img1TimeLong - slack);
        elseif t > 180
            t = Screen('Flip', w, t + img1TimeShort - slack);
        end

        % Image 2 presentation
        Screen('DrawTexture', w, S2texture);
        t = Screen('Flip', w, t + maskTime - slack);

        % Wait for response
        keepGoing = true;
        while keepGoing
            % Check if timeout
            if GetSecs - t > responseTime
                keepGoing = false;
            end
            
            % Check keys
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                responsecode = find(keyCode);
                if length(responsecode) == 1 && (responsecode == resp1 || responsecode == resp2)
                    keepGoing = false;
                end
            end
        end

        % Save reaction time
        rt = (secs - t) .* 1000;

        % Set response & accuracy for output file
        if responsecode == resp1
            resp = 's';
        elseif responsecode == resp2
            resp = 'd';
        else
            resp = 'timeout';
        end

        if strcmp(trials.CorrResponse{i}, 'same')
            if responsecode == resp1
                GradedRes = 1;
            else
                GradedRes = 0;
            end
        elseif strcmp(trials.CorrResponse{i}, 'diff')
            if responsecode == resp2
                GradedRes = 1;
            else
                GradedRes = 0;
            end
        end
        
        % Save data
        dataFile = fopen(fileName, 'a');
        % Data format: '%f,%d,%s,%s,%s,%s,%s,%s,%d,%f,%f,%s,%s\n';
        fprintf(dataFile, dataFormat, subjno, i, ...
            trials.CorrResponse{i}, trials.Viewpoint{i}, ...
            trials.Size{i}, trials.Img1{i}, trials.Img2{i}, resp, ...
            GradedRes, rt, hand, experimenter, char(datetime));
        fclose(dataFile);
        
        % Close images
        Screen('Close', S1texture);
        Screen('Close', S2texture);
        
        % Blank
        t = Screen('Flip', w); 
    end
    
    RestrictKeysForKbCheck(KbName('space'));
    Screen('Flip', w);
    center_text(w, 'You have finished this task!', 0);
    center_text(w, 'Press the spacebar', 0, 50);
    Screen('Flip', w);
    WaitSecs(.2);
    
    % Press any key to quit the program
    FlushEvents('keyDown');
    KbWait;
    
    % Experiment cleanup
    sca;
    ListenChar();
    ShowCursor();
    RestrictKeysForKbCheck([]);
    if exist('prior', 'var')
        Priority(prior);
    end
catch
    % Save error
    error = lasterror; %#ok<LERR>
    save(['err_', char(datetime('now', 'Format', 'MMM-dd-y--HH-mm-ss'))]); 
    
    % Experiment cleanup
    sca;
    ListenChar();
    ShowCursor();
    RestrictKeysForKbCheck([]);
    if exist('prior', 'var')
        Priority(prior);
    end
    
    % Panic!
    rethrow(error);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Aug 22. 2019 - Jason Chow
% Changed to only support Sheinbugs
% Function now returns nothing
% Remove unused variables
% Rewrote error catching
% Add priority increase
% Reorganize code
% Parameterized experiment
% Changed data saving directories
% Add timestamp to data file names
% Change space to continue to simpler KbWait([], 3)
% Change flip behavior to be more precise to screen refreshes
% Moved image loading to beginning of a trial to avoid slowing
% Remove quit key
% Remove dprime calculations
% Change saving procedures/format
% Change experiment cleanup
% Add data directory input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%