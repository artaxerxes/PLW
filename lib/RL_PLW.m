% Copyright (C) 2012 Multisensory Lab of Peking University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software  Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.

% RL_PLW()

% Author: Hormetjan Yiltiz  hyiltiz@gmail.com
% Created: 2012-10-17

function RL_PLW(conf, mode)
  %% this code to generate pointlight display using 3D coordinates file
  %   Originally written by Lihan Chen, Ph.D, Department of Psychology, Peking University
  %   Merged in onePLW, PLWtransform, PLWsound modification to optimaze code
  %   by Hormetjan, Department of Psychology, Peking University,March 2012
  %   Wrote all the functions in directory ./lib, Hormetjan, June 2012
  %   Added multi-platform support for Windows and GNU/Linux, June 2012
  %   Added compatibility compatibility between MATLAB and Octave, June 2012
  %   Help on tactile support by Lihan Chen, June 2012
  %   Added tactile support by Hormetjan, June 2012
  %   Documented by Hormetjan, July 2012
  %   Added accurate timing support by Hormetjan, Oct 2012
  %   Adjusted for experimental needs, Oct 2012
  %   Added some other features, please check svn repository for detail.
  %   For the latest source code, please contact hyiltiz@gmail.com
  %   For Documentation of the program, please read README.txt file that
  %   comdes with the program, to have a better understanding of the way the
  %   program was written.

  addpath('./data', './lib', './resources');
  format long;
  data.visualfilename = '07_01.data3d.txt'; % visaul data resource file
  data.instruct_filename = 'RL_Instruction_en.txt'; % instructions text file

  % input variables, use them via updateStruct() to update the defined variables below
  if nargin > 0
    render.conf=conf;
    render.mode=mode;
  end

  % conf and mode variables listed here for using calling from a WRAP FUNCTION
  % so do not directly change any value here!

  % time setting vatiables
  conf.flpi               =  .02;         % each frame is set to 20ms (the monitor's flip interval is 16.7ms)
  conf.trialdur           =  70;          % duration time for every trial
  conf.repetitions        =  5;           % repetition time of a condition
  conf.resttime           =  30;          % rest for 30s
  conf.restpertrial       =  1;           % every x trial a rest
  conf.doubleTactileDiff  =  0 ;          % flips between taps on one tactile stimuli (double tactile);0 to disable
  conf.tiltangle          =  0;           % tilt angle for simulating 3D stereo display
  conf.xshift             =  .4;          % shift PLW for using mirror, see mode.mirror_on
  conf.shadowshift        =  0;           % distance between PLWs and their twin shadows
  conf.ntdurflp           =  1;           % tactile duration time: n * conf.flpi
  conf.nvterrflp          =  15;          % visual-tactile error time: n * conf.flpi
  conf.waitBetweenTrials  =  .8+rand*0.2; % wait black screen between Trials, random
  conf.waitFixationScreen =  .8+rand*0.2; % '+' time randomized
  conf.scale1             =  20;          % PLW's visual scale, more the bigger
  conf.lagFlip            =  2;           % every x Flip change a noise
  conf.noisescale         =  .14;         % the width of the noise dots, and the default PLW dot width is 7
  conf.kill_dotr          =  .1;          % ratio at which to kill dotr percent of dots
  % conf.exptime          =  45;          % experiment is 45min long

  % state control variables
  mode.baseline_on        = 0;  % baseline trial, without visual stimuli
  mode.inout_on           = 0;  % use incoming and outgoing PLWs for demo
  mode.once_on            = 1;  % only one trial, used for demostration before experiment
  % DO NOT CHANGE UNLESS YOU KNOW EXCACTLY WHAT YOU ARE DOING
  mode.mirror_on          = 1;  % use mirror rather that spectacles for binacular rivalry
  mode.many_on            = 0;  % the task is the majority of dots the participant saw
  mode.greyNoise_on       = 1;  % do not use the original grey noise
  mode.english_on         = 1;  % use English for Instructions etc., 0 for Chinese(not supported for now!)
  mode.regenerate_on      = 1;  % mode.regenerate_on data for experiment, rather than using the saved one
  mode.audio_on           = 0;  % set audio stimuli on
  mode.RT_on              = 0;  % Reaction time mode, this is not to be changed!
  mode.debug_on           = 1;  % default is 0; 1 is not to use full screen, and skip the synch test

  % evaluate the input arguments of this function
  if nargin > 0
    conf = updateStruct(render.conf, conf);
    mode = updateStruct(render.mode, mode);
  end

  if mode.mirror_on
    %good
  else
    conf.xshift = 0;
  end

  if mode.debug_on
    conf.repetitions = 1;
    conf.resttime = 5;
    conf.exptime = 5;
    conf.trialdur = 13;
  end

  if mode.many_on % M is for many_dots task, while D is for direction task
    dataSuffix = 'M';
  else
    dataSuffix = 'D';
  end

  if mode.inout_on % M is for many_dots task, while D is for direction task
    dataSuffix = [dataSuffix '_InOut_'] ;
  end

  %% randomized sample exp. conditions and trial sequences variables
  % condition type:4; recording results in 5 culumns
  if mode.inout_on
    % we only want upright PLWs here
    [flow.Trialsequence, Trials] = genTrial(conf.repetitions, 9, [1, 4]);
    data.moveDirection = [round(rand([length(flow.Trialsequence), 1])), flow.Trialsequence(:,1)]; %walking direction is random
  else
    % rhythmtype= [1:2*4];  % condition type, upright vs. upside-down; congurent or not:4
    [flow.Trialsequence, Trials] = genTrial(conf.repetitions, 9, [2, 4]);
    data.moveDirection = [round(rand([length(flow.Trialsequence), 1])), flow.Trialsequence(:,1) - 1]; %walkers walking direction is random
  end
  flow.Trialsequence(:,1) = [];
  if mode.once_on
    flow.Trialsequence(1:mode.once_on)=1:mode.once_on;
  end

  % unified key definitions
  render.kb = keyDefinition();

  try
    % psychoaudio hardware setting.
    if mode.audio_on
      freq = 48000;
      pahandle = loadAutio(freq);
    end

    % tactile hardware setting
    try
      [render.dioIn, render.dioOut] = loadDigitalIO();
      mode.tactile_on = 1;
    catch
      mode.tactile_on = 0;  % 0 is no tactile device
    end

    % make sure the software version is new enouch for running the program
    checkVersion();

    % Get Subject information
    Subinfo = getSubInfo();

    %% initialization
    HideCursor;
    ListenChar(2);
    if mode.debug_on
      Screen('Preference','SkipSyncTests', 0);
    else
      Screen('Preference','SkipSyncTests', 0);
    end
    Screen('Preference', 'ConserveVRAM', 8);
    InitializeMatlabOpenGL;

    if mode.regenerate_on
      % reading in bvh text files for raw data
      data.readData = PLWread(data.visualfilename);
      data.loopPeriod = 130;
      conf.imagex=250;  % image size

      % virtual PLW:PLW0 Use for solving the touchground data
      % We need unrotated one (right-left direction) for solving
      % touchground
      data.readData.thet = 0;
      data.readData.xyzseq = [1 3 2];  %axis rotation, [1 3 2] by default
      % use exactly the same initial position as the first PLW via data.init
      [data.dotx0,  data.doty0, data.init0, data.maxdot] = PLWtransform(data.readData, conf.scale1, conf.imagex, -1);

      % Generate the data for plotting Point Light Walkers
      % PLW-target
      data.readData.thet = 0;  %to rotate along the first axis
      if mode.inout_on;data.readData.thet = 90 + conf.tiltangle;end
      data.readData.xyzseq = [1 3 2];  %axis rotation, [1 3 2] by default
      data.init = data.init0; % the same with virtual PLW, though rotated
      [data.dotx,  data.doty, data.init, data.maxdot] = PLWtransform(data.readData, conf.scale1, conf.imagex, data.init);

      % PLW-nontarget
      data.readData.thet = 180;  %to rotate along the first axis
      if mode.inout_on;data.readData.thet = -90 + conf.tiltangle;end
      data.readData.xyzseq = [1 3 2];  %to rotate across xyz
      [data.dotx1, data.doty1, data.init1, data.maxdot1] = PLWtransform(data.readData, conf.scale1, conf.imagex, -1);


      if mode.inout_on
        % another two PLWs for stereo 3D display
        % PLW-target-shadow
        data.readData.thet = 0;  %to rotate along the first axis
        if mode.inout_on;data.readData.thet = 90 - conf.tiltangle;end
        data.readData.xyzseq = [1 3 2];  %axis rotation, [1 3 2] by default
        data.init = data.init0; % the same with virtual PLW, though rotated
        [data.dotxs,  data.dotys, data.inits, data.maxdots] = PLWtransform(data.readData, conf.scale1, conf.imagex, data.init);

        % PLW-nontarget-shadow
        data.readData.thet = 180;  %to rotate along the first axis
        if mode.inout_on;data.readData.thet = -90 - conf.tiltangle;end
        data.readData.xyzseq = [1 3 2];  %to rotate across xyz
        [data.dotx1s, data.doty1s, data.init1s, data.maxdot1s] = PLWtransform(data.readData, conf.scale1, conf.imagex, -1);
      end


    end

    render.screens=Screen('screens');
    render.screenNumber=max(render.screens);

    if mode.debug_on
      [w,render.wsize]=Screen('OpenWindow',render.screenNumber,0,[1,1,801,601],[]);
    else
      [w,render.wsize]=Screen('OpenWindow',render.screenNumber,0,[],32);
    end

    render.ifi=Screen('GetFlipInterval', w);
    if render.ifi > conf.flpi + 0.0005 % allow 0.5ms error
      error('Monitor Flip Interval is too large. Please use another computer.')
    end

    render.cx = render.wsize(3)/2; %center x
    render.cy = render.wsize(4)/2; %center y

    % Variables used across trials
    %     data.Track = 1:round(conf.exptime*60/(conf.flpi * data.loopPeriod * 8 * conf.repetitions) * length(data.dotx));        % 2 for less longer stimuli
    data.Track = 1: round(conf.trialdur / (conf.flpi * length(data.dotx)) * length(data.dotx));
    %     data.Track = 1:5/.01;

    flow.prestate = 0;  % the last reponse until now
    flow.response = 0;  % the current current response, just after the last response
    flow.nresp    = 1;  % the total number of response recorded
    flow.restcount= 0;  % the number of trials from last rest
    Priority(MaxPriority(w));

    if mode.mirror_on
      % do not create noise, we do not need them if using mirrors
    else
      %% create the noise, using buffer
      % impossible to iterate on a smaller loop, since the loop has direction :(
      % render.noiseloopT = 50;
      render.noiseloopT = length(data.Track);
      render.noiseloop = modloop(1:length(data.Track), render.noiseloopT);
      [tex, render.dstRect] = addNoise(w, render.wsize, data.Track,conf.noisescale, render.noiseloopT, mode.greyNoise_on, conf.lagFlip, conf.kill_dotr);
    end

    %% Instructions
    %     RL_Instruction(w, mode.debug_on, mode.english_on, render.kb);
    if ~mode.english_on
      if ~mode.many_on
        data.instruct_filename = 'RL_Instruction_zh.txt';
      else
        data.instruct_filename = 'RL_Instruction_many_zh.txt';
      end
    else
      if ~mode.many_on
        data.instruct_filename = 'RL_Instruction_en.txt';
      else
        data.instruct_filename = 'RL_Instruction_many_en.txt';
      end
    end


    Instruction(data.instruct_filename, w, render.wsize, mode.debug_on, mode.english_on, render.kb, inf, 0, mode.tactile_on);

    %% Here begins our trial
    for k = 1:length(flow.Trialsequence)
      tic;
      flow.Trial = k;
      % rest every couple trial once
      if flow.Trial > 1
        WaitSecs(3);
        showLeftTrial(flow.Trialsequence, flow.Trial, w, render.wsize, mode.debug_on, mode.english_on, render.kb, 1, mode.tactile_on);
      end
      flow.restcount = restBetweenTrial(flow.restcount, conf.resttime, conf.restpertrial, w, render.wsize, mode.debug_on, mode.english_on, render.kb, 0, mode.tactile_on);
      WaitSecs(conf.waitBetweenTrials);  % wait black screen between Trials, random

      if mode.regenerate_on
        data.initPosition = Randi(round(data.loopPeriod/4),[2 1]);
          %         data.paceRate = repmat(Randi(2), [2 1]);
          % Remember not to use those quick ones
          data.paceRate = [1; 1];
        %   data.Track = 1:round(length(data.dotx));% 2 for accuracy, and data.loopPeriod for period
        [data.lefttouch, data.righttouch] = touchground(data.dotx0, data.initPosition(1), data.paceRate(1), data.Track);     %for the index when PLW touches ground
      else
        % do not generate, use the previously saved data(not enabled by default)
        load RL_PLW_data;
        %where we have two PLWs, and quicker pace than 3 maybe too quick
        % data.paceRate = Randi(2,[2 1]);
        data.paceRate = repmat(Randi(2), [2 1]);
        data.initPosition = Randi(round(data.loopPeriod/4),[2 1]);
      end

      conf.xshift = (round(rand)*2-1) * conf.xshift;
      data.xshift(flow.Trial) = conf.xshift;

      % Generate the multisensory data.Track to synch on time
      [data.vTrack, data.tTrack] = genTrack(flow.Trialsequence(flow.Trial), data.Track, data.lefttouch, data.righttouch, conf.flpi, conf.ntdurflp, conf.nvterrflp, conf.doubleTactileDiff);

      % display:  +
      %fixation(w, render.cx, render.cy);
      testMirror(w, render.cx , render.cy, 255, [-conf.xshift 0], data.maxdot);
      %testMirror(w, render.cx , render.cy, 255, [conf.xshift 0], data.maxdot1);
      % use the same maxdot for both PLW; the frame has to be the same
      testMirror(w, render.cx , render.cy, 255, [conf.xshift 0], data.maxdot);
      Screen('Flip',w);

      % wait until the participant's mirror is ready
      pedalWait(mode.tactile_on, 10000, render.kb);
      WaitSecs(conf.waitFixationScreen);  % '+' time randomized


      Screen('FillRect',w,0);
      render.vlb = Screen('Flip', w);  % record render.vlb, used for TIMING control

      %Here comes the sound
      if mode.audio_on
        playSound(pahandle, freq, data.paceRate, data.moveDirection(flow.Trial, 1));
      end

      %% PLW that you can see on the screen
      flow.isquit = 0;     % to capture ESCAPE for quitting
      flow.isresponse = 0;
      render.iniTimer=GetSecs;

      data.iniTactile = data.tTrack(find(data.tTrack>0,1));%initial type of tactile stimuli
      if isempty(data.iniTactile);
        data.iniTactile = 0;  %baseline is 0
      end

      for i=data.Track  %loop leghth
        flow.Flip = i;
        if mode.mirror_on
          % we do not need noise for mask here!
        else
          % here comes the noise background
          %addNoise(w, 256, render.wsize);%Do not use this, since buffer tex is used
          Screen('DrawTexture', w, tex(render.noiseloop(flow.Flip)), [], render.dstRect, [], 0);
        end


        if mode.baseline_on
          % do not show the PLWs
        else
          % and here comes the walkers
          RLonePLW(w,data.initPosition(1) + data.paceRate(1)*data.vTrack(flow.Flip), render.cx , render.cy, data.dotx , data.doty , data.moveDirection(flow.Trial, :), [255 0 0], [-conf.xshift-conf.shadowshift 0], data.maxdot);
          RLonePLW(w,data.initPosition(2) + data.paceRate(2)*data.vTrack(flow.Flip), render.cx , render.cy, data.dotx1, data.doty1, data.moveDirection(flow.Trial, :), [0 255 0], [conf.xshift-conf.shadowshift 0], data.maxdot);
          if mode.inout_on
          RLonePLW(w,data.initPosition(1) + data.paceRate(1)*data.vTrack(flow.Flip), render.cx , render.cy, data.dotxs, data.dotys, data.moveDirection(flow.Trial, :), [255 0 0], [-conf.xshift+conf.shadowshift 0], data.maxdot);
          RLonePLW(w,data.initPosition(2) + data.paceRate(2)*data.vTrack(flow.Flip), render.cx , render.cy, data.dotx1s, data.doty1s, data.moveDirection(flow.Trial, :), [0 255 0], [conf.xshift+conf.shadowshift 0], data.maxdot);
          end

        end
        Screen('DrawingFinished', w); % no further drawing commands will follow before Screen('Flip')

        % here comes their footsteps
        if mode.tactile_on
          % save data/postbuggy;
          % disp('postbuggy');
          tactileStimuli(data.tTrack(flow.Flip), render.dioOut);
        end
        %% catch the response
        if ~mode.tactile_on; render.dioIn = false; end

        % get the response
        render.islastResponse = 0;
        [Trials, flow.prestate, flow.response, render.iniTimer, flow.isquit,...
          flow.isresponse, flow.nresp ] = getResponseU(mode.tactile_on, ...
          render.iniTimer, render.dioIn, flow.prestate, ...
          flow.response, flow.Trialsequence,...
          flow.Trial, data.moveDirection, render.kb, flow.isresponse,...
          flow.isquit, Trials, flow.nresp, data.paceRate' , data.iniTactile, mode.RT_on, conf.xshift, render.islastResponse);
        if mode.RT_on; if flow.isresponse; break; end; end

        % Flip the visual stimuli on the screen, along with timing
        % old = render.vlb;
        render.vlb = Screen('Flip', w, render.vlb + (1-0.5)*conf.flpi);%use the center of the interval
        % recordImage(flow.Flip,10,'Mirror',w,render.wsize)
        % Display(old, render.vlb, render.vlb - old, length(data.Track),length(data.tTrack));
        % Screen('Flip', w);
        toc;
        tic;
      end
      % quit if the participant pressed ESC
      if flow.isquit, break, end

      % end of per trial
      Screen('FillRect',w ,0);
      Screen('Flip', w);

      % Get the remaining last response
      render.islastResponse = 1;
      [Trials, flow.prestate, flow.response, render.iniTimer, flow.isquit,...
        flow.isresponse, flow.nresp ] = getResponseU(mode.tactile_on, ...
        render.iniTimer, render.dioIn, flow.prestate, ...
        flow.response, flow.Trialsequence,...
        flow.Trial, data.moveDirection, render.kb, flow.isresponse,...
        flow.isquit, Trials, flow.nresp, data.paceRate' , data.iniTactile, mode.RT_on, conf.xshift, render.islastResponse);

      % do exactly once_on times
      mode.once_on = mode.once_on-1;
      if ~mode.once_on; error('Preparation Finished! (No worries. This is no bug, buddy.)'); end
    end;

    % End of experiment

    %save(['data/',Subinfo{1},'/', Subinfo{1}, dataSuffix, date, '.mat'],'Trials','conf', 'Subinfo','flow','mode','data');
    render.matFileName = ['data/', Subinfo{1}, 'Mirror', dataSuffix, date, '.mat'];
    save(render.matFileName,'Trials','conf', 'Subinfo','flow','mode','data');
    Display(render.matFileName);
    % Display 'Thanks' Screen
    RL_Regards(w, mode.english_on);

  catch
    % save the buggy data for debugging
    save data/buggy.mat;
    Display(char('','','data/buggy.dat saved successfully, use for debugging!',''));
    save(['data/', Subinfo{1}, dataSuffix, date, 'buggy.mat']);
    %     disp(['';'';'data/buggy saved successfully, use for debugging!']);
    Screen('CloseAll');
    if mode.audio_on; PsychPortAudio('Close'); end
    Priority(0);
    ShowCursor;
    ListenChar(0);
    psychrethrow(psychlasterror);
    format short;

  end

  Screen('CloseAll');
  if mode.audio_on; PsychPortAudio('Close'); end
  Priority(0);
  ShowCursor;
  ListenChar(0);

  % save data for testing for the last experiment
  save data/test.mat
  format short;
  Display('Experiment was successful!');
end