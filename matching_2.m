
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDEAL
% Matching task
% same trial order for all Ss (diff for each cat)
% modified by Mackenzie July 2017 for OPlus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dprime timeout] = matching_2(subjno,subjini,age,sex,hand)
try
        %% Open Screen
        whichScreen = 0; %changed to 1 to test on laptop
        
        [w, rect] = Screen('OpenWindow', whichScreen, 255);
        xc = rect(3)/2;
        yc = rect(4)/2;
        hand = hand;
        age = age;
        sex = sex;
        category = 2; % sets category
        
        Screen(w, 'TextSize', 24);
        Screen(w, 'TextFont', 'Arial');
        Screen(w, 'TextStyle', 1);
        
        commandwindow; %get back to command window
        
        %% create files for saving data
        cd('data_M')
        fileName1 = ['M_' num2str(subjno) '_' subjini '_' num2str(category) '.txt'];
        dataFile1 = fopen(fileName1, 'w');
        cd('..')
        
        ListenChar(2);
        HideCursor;
        commandwindow;
        
        %% make mask
        if category == 1
            mask = imread('mask_1.jpg');
        elseif category == 2
            mask = imread('mask_2.jpg');
        elseif category == 0
            mask = imread('mask_0.jpg');
        end
        
        mask = imresize(mask, [125 125]);
        masktexture = Screen('MakeTexture', w, mask);
        
        %% load instruction Screens
        instruct1 = imread('instruct1.jpg');
        instruct1_texture = Screen('MakeTexture', w, instruct1);
        
        instruct2 = imread('instruct2.jpg');
        instruct2_texture = Screen('MakeTexture', w, instruct2);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%instructions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Screen('DrawTexture', w, instruct1_texture);
        Screen('Flip', w);
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                responsecode=find(keyCode);
                if responsecode==KbName('space')
                    break
                end
            end
        end
        Screen('Flip',w);
        while KbCheck; end
        
        Screen('DrawTexture', w, instruct2_texture);
        Screen('Flip', w);
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                responsecode=find(keyCode);
                if responsecode==KbName('space')
                    break
                end
            end
        end
        Screen('Flip',w);
        while KbCheck; end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Practice trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [cat trial samediff viewpoint size S1_name S2_name] = textread(['practice_' num2str(category) '.txt'], '%u %u %s %s %s %s %s');
        
        Screen('Flip', w);
        center_text(w, 'Now you will complete a short practice block to familiarize you with the task.', 0, -100);
        center_text(w, 'Press J for if the two objects are the SAME IDENTITY.', 0, -50);
        center_text(w, 'Press K if the two objects are a DIFFERENT IDENTITY.', 0, 0);
        center_text(w, 'Try to respond as QUICKLY and ACCURATELY as possible.', 0, 50);
        center_text(w, 'Press the spacebar to start the practice block.', 0, 150);
        Screen('Flip', w);
        FlushEvents('keyDown');
        responsecode = [];
        temp = 0;
        responsecode = 0;
        while 1
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                responsecode = find(keyCode);
                if responsecode == KbName('space')
                    break
                end
            end
        end
        while KbCheck; end
        Screen('FillRect', w, 255);
        
        ntrials = 6;
        for i = 1:ntrials
            
            %blank 500ms
            %Screen('DrawTexture', w, blanktexture);
            t = Screen('Flip', w);
            
            %fixation 500ms
            %Screen('DrawTexture', w, fixtexture);
            center_text(w, '+', 0, 0);
            t = Screen('Flip', w, t+.5);
            
            %S1 300ms or 150ms
            S1 = imread(['stimuli/' char(S1_name(i))]);
            S1 = imresize(S1, [125 125]);
            S1texture = Screen('MakeTexture', w, S1);
            Screen('DrawTexture', w, S1texture);
            t = Screen('Flip', w, t+.5);
            
            %mask 500ms
            Screen('DrawTexture', w, masktexture);
            if i < 181
                t = Screen('Flip', w, t+.3);
            elseif t > 180
                t = Screen('Flip', w, t+.15);
            end
            
            %S2 until response (max 3 s)
            S2 = imread(['stimuli/' char(S2_name(i))]);
            if strcmp(size{i}, 'same')
                S2 = imresize(S2, [125 125]);
            else
                S2 = imresize(S2, [95 95]);
            end
            S2texture = Screen('MakeTexture', w, S2);
            Screen('DrawTexture', w, S2texture);
            t = Screen('Flip', w, t+.5);
            
            FlushEvents('keyDown');
            temp = 0;
            rt = GetSecs;
            responsecode = 0;
            
            %record response time
            resp1 = KbName('j'); %same
            resp2 = KbName('k'); %diff
            GoOn = 0;
            keyIsDown = 0;
            while GoOn == 0;
                temp = GetSecs-rt;
                if temp > 3
                    GoOn = 1;
                end
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown
                    responsecode = find(keyCode);
                    if responsecode == resp1 | responsecode == resp2
                        keyIsDown = 0;
                        GoOn = 1;
                    end
                    if responsecode == KbName('q')
                        Screen('CloseAll');
                    end
                end
            end
            
            rt = secs-rt;
            rt = rt*1000;
            
            Screen('Close', S1texture);
            Screen('Close', S2texture);
        end
        
        Screen('Flip', w);
        center_text(w, 'You have finished the practice block', 0, -100);
        center_text(w, 'If you have any questions, please go get the experimenter.', 0, -50);
        center_text(w, 'Otherwise, press the spacebar to start the experiment.', 0, 0);
        Screen('Flip', w);
        FlushEvents('keyDown');
        responsecode = [];
        temp = 0;
        responsecode = 0;
        while 1
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                responsecode = find(keyCode);
                if responsecode == KbName('space')
                    break
                end
            end
        end
        while KbCheck; end
        Screen('FillRect', w, 255);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%Experimental Trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [cat trial samediff viewpoint size S1_name S2_name] = textread(['trials_' num2str(category) '.txt'], '%u %u %s %s %s %s %s');
        
        ntrials = length(trial); %should get the number of trials
        
        %for calculating d prime
    %ntrialsS = sum(count(samediff,'same')); %get the number of same trials, only works in 2016b
    %ntrialsD = sum(count(samediff,'diff')); %get the number of diff trials, only works in 2016b
    %for 2016a
    idx_same = strfind(samediff, 'same')
    idx_same = find(not(cellfun('isempty',idx_same)));
     idx_diff = strfind(samediff, 'diff')
    idx_diff = find(not(cellfun('isempty',idx_diff)));
     ntrialsS = length(idx_same);
    ntrialsD = length(idx_diff);
        hit = 0;
        fa = 0;
        timeout = 0;
        
        for i = 1:ntrials
            %sets breaks
            if i>1 && mod(i-1,90)==0
            if i == 91 %quater of the way through
                Screen('Flip',w);
                center_text(w,'You have completed a quarter of this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            elseif i == 181 %halfway through
                Screen('Flip',w);
                center_text(w,'You are halfway through this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            elseif i == 271 %three quaters of the way through
                Screen('Flip',w);
                center_text(w,'You have completed three-quarters of this task', 0, 0);
                center_text(w,'Take a break', 0, 50);
                center_text(w, 'Press the spacebar when you are ready to continue',0,100);
                Screen('Flip',w);
            end
            while 1
                [keyIsDown,secs,keyCode]=KbCheck;
                if keyIsDown
                    responsecode=find(keyCode);
                    if responsecode==KbName('space')
                        break
                    end
                end
            end
        end
        while KbCheck; end;
        
            
            %blank 500ms
            %Screen('DrawTexture', w, blanktexture);
            t = Screen('Flip', w);
            
            %fixation 500ms
            %Screen('DrawTexture', w, fixtexture);
            center_text(w, '+', 0, 0);
            t = Screen('Flip', w, t+.5);
            
            %S1 300ms or 150ms
            S1 = imread(['stimuli/' char(S1_name(i))]);
            S1 = imresize(S1, [125 125]);
            S1texture = Screen('MakeTexture', w, S1);
            Screen('DrawTexture', w, S1texture);
            t = Screen('Flip', w, t+.5);
            
            %mask 500ms
            Screen('DrawTexture', w, masktexture);
            if i < 181
                t = Screen('Flip', w, t+.3);
            elseif t > 180
                t = Screen('Flip', w, t+.15);
            end
            
            %S2 until response (max 3 s)
            S2 = imread(['stimuli/' char(S2_name(i))]);
            if strcmp(size{i}, 'same')
                S2 = imresize(S2, [125 125]);
            else
                S2 = imresize(S2, [95 95]);
            end
            S2texture = Screen('MakeTexture', w, S2);
            Screen('DrawTexture', w, S2texture);
            t = Screen('Flip', w, t+.5);
            
            FlushEvents('keyDown');
            temp = 0;
            rt = GetSecs;
            responsecode = 0;
            
            %record response time
            resp1 = KbName('j'); %same
            resp2 = KbName('k'); %diff
            GoOn = 0;
            keyIsDown = 0;
            while GoOn == 0;
                temp = GetSecs-rt;
                if temp > 3
                    GoOn = 1;
                end
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown
                    responsecode = find(keyCode);
                    if responsecode == resp1 | responsecode == resp2
                        keyIsDown = 0;
                        GoOn = 1;
                    end
                    if responsecode == KbName('q')
                        Screen('CloseAll');
                    end
                end
            end
            
            rt = secs-rt;
            rt = rt*1000;
            
            %set response & accuracy for output file
            if responsecode == resp1
                resp = 's';
            elseif responsecode == resp2
                resp = 'd';
            else
                resp = 'timeout';
            end
            
            if strcmp(samediff{i}, 'same')
                if responsecode == resp1
                    GradedRes = 1;
                else
                    GradedRes = 0;
                end
            elseif strcmp(samediff{i}, 'diff')
                if responsecode == resp2
                    GradedRes = 1;
                else
                    GradedRes = 0;
                end
            end
            
            %count timed out trials
            if strcmp(resp, 'timeout')
                timeout = timeout + 1;
                if strcmp(samediff{i}, 'same')
                    ntrialsS = ntrialsS - 1;
                elseif strcmp(samediff{i}, 'diff')
                    ntrialsD = ntrialsD - 1;
                end
            end
            
            %get counts for d prime calculation
            
            if strcmp(samediff{i}, 'same')
                if GradedRes == 1
                    hit = hit + 1;
                end
            elseif strcmp(samediff{i}, 'diff')
                if GradedRes == 0
                    fa = fa + 1;
                end
        end
            
            %print data
            fprintf(dataFile1, '%d\t%i\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%i\t%f\n', str2double(subjno), i, num2str(category), char(samediff(i)), char(viewpoint(i)), char(size(i)), char(S1_name(i)), char(S2_name(i)), char(resp), GradedRes, rt);
            Screen('Close', S1texture);
            Screen('Close', S2texture);
        end
        
         %calculate d'
    dprime = (norminv(hit/ntrialsS))-(norminv(fa/ntrialsD));
    
    Screen('Flip', w);
    center_text(w, 'You have finished this task!', 0);
    center_text(w, 'Press the spacebar', 0, 50);
    Screen('Flip', w);
    WaitSecs(.2);
    responsecode = [];
    temp = 0;
    responsecode = 0;
    
    % Press any key to quit the program
    FlushEvents('keyDown');
    pressKey = KbWait;
    
    ShowCursor;
    Screen('CloseAll');
        ListenChar;
    
catch
    ListenChar(0);
    ShowCursor;
    %Screen('CloseAll');
    rethrow(lasterror);
end
end
