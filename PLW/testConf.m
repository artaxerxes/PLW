function testConf(is_once_on)
%This function is especially for configuring conf variables


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%These conf variables in the scope needs consideraton%%%
%%%Uncomment the needed variables and change their values%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Another noise with corresponding coloring
%mode.mirror_on          = 0;           % use mirror rather that spectacles for binacular rivalry
%conf.lagFlip            = 2;           % every x Flip change a noise, use only integer
%%Or no noise for binacular rivalry stimulated with mirror
mode.mirror_on          = 1;           % use mirror rather that spectacles for binacular rivalry
conf.xshift             = .4;          % shift of PLW along x within (-1,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%These does not need to be modified, unless needed to%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time setting vatiables
conf.flpi               =  0.02;        % each frame is set to 20ms (the monitor's flip interval is 16.7ms)
conf.trialdur           =  70;          % duration time for every trial
conf.repetitions        =  5;           % repetition time of a condition
conf.resttime           =  30;          % rest for 30s
conf.restpertrial       =  1;           % every x trial a rest

% state control variables
mode.many_on       = 0;  % the task is the majority of dots the participant saw
mode.debug_on      = 0;  % default is 0; 1 is not to use full screen, and skip the synch test
if nargin > 0
mode.once_on       = 1;  % only one trial, used for demostration before experiment
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the main function RL_PLW()
RL_PLW(conf, mode);