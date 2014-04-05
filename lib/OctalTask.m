function wrkspc = OctalTask(is_once_on, Subinfo)
% octal task, pass in 1 for demo with only one trial, or just run it with no input;
% displays 8 PLW with emotional face stumuli


% time setting vatiables
conf.flpi               =  0.01;        % each frame is set to 20ms (the monitor's flip interval is 16.7ms)
conf.alphaFace          =  .7;         % alpha transparency for face stimuli
conf.scale1             =  6;           % PLW's visual scale, more the bigger
conf.trialdur           =  70;           % duration time for every trial
conf.repetitions        =  5;           % repetition time of a condition
conf.resttime           =  30;          % rest for 30s
conf.restpertrial       =  5;           % every x trial a rest
conf.tiltangle          =  0;           % tilt angle for simulating 3D stereo display
conf.doubleTactileDiff  = 10 ;          % flips between taps on one tactile stimuli (double tactile);0 to disable
conf.clockR             =  .5;         % clock, with the center of the screen as (0,0), in pr coordination system


% state control variables
mode.octal_on      = 1;
mode.debug_on      = 0;  % default is 0; 1 is not to use full screen, and skip the synch test
mode.dotRot_on     = 0;  % Use dot rot or not; depends on octal_on=1;
mode.colorbalance_on=1;  % balance the color of the target PLW, which is by default red
mode.mirror_on     = 1;  % use mirror rather that spectacles for binacular rivalry
mode.many_on       = 0;  % the task is the majority of dots the participant saw
mode.simpleInOut_on= 1;  % simple InOut exp, with the same tactile stimuli for both foot

if nargin > 1
    mode.once_on       = is_once_on;  % only one trial, used for demostration before experiment
else
    mode.once_on       = 0;  % only one trial, used for demostration before experiment
end

% Call the main function RL_PLW()
if exist('Subinfo', 'var')
    wrkspc = RL_PLW(conf, mode, Subinfo);
else
    wrkspc = RL_PLW(conf, mode);
end
end
