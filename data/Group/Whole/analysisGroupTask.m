function [DS, dur, durnorm, durr, alldata] = analysisGroupTask
%% analyse Group task
% input: all mat-files under data/Group/Whole/; see matfiles variable below
% output:
% DS: a data set array that has condition(4)*responsetype(3) rows for each
% subject, with corresponding data for each condition*responsetype
% combination; all data were collected from the mat-file, specifically from
% ques.*.encode.scales, wrkspc.Octal.Subinfo, wrkspc.*.Trials; see helper
% function singleds below, that generates single dataset array ids for each
% subject; see below:

% id    dur      condition  resptype    otherinfo
% 1    1.5190    1.0000         0
% 1   16.4243    1.0000    3.0000
% 1   29.8217    1.0000    4.0000
% 1    3.4529    2.0000         0
% 1   28.5258    2.0000    3.0000
% 1   35.7774    2.0000    4.0000
% 1    3.7762    3.0000         0
% 1    4.7768    3.0000    3.0000
% 1   23.4488    3.0000    4.0000
% 1    1.3791    4.0000         0
% 1    6.6571    4.0000    3.0000
% 1   30.4061    4.0000    4.0000
%
%
% there are 4 type of duration time in the dateset DS
% 1.
% absolute dur value:            tplw, tdot;
% also returned as struct DUR
%
% 2.
% absolute dur value(normalized): tnormplw, tnormdot;
% also returned as struct DURNORM
% used Trials(:,3)/mean(Trials(:,3) for normalization
%
% 3.
% relative dur value(as mentioned in the email by Prof. Chen): rplw, rdot;
% also returned as struct DURR
% ����ʱ�������ֵ�-�������Ͳ�������
% ���ʱ����ÿ�����������г���ͳ����ƽ������
% Ȼ�󱾱𽫳���ͳ����ʱ��������ƽ����
%
% 4.
% dur ratio(for each condition per sub, ratio of the differect dur means to
% inward dur means); taking the above table as example:
% it is the ratio of column1./column2
%     tdur     tdur(restype==3)
%     1.5190   16.4243
%    16.4243   16.4243
%    29.8217   16.4243
%     3.4529   28.5258
%    28.5258   28.5258
%    35.7774   28.5258
%     3.7762    4.7768
%     4.7768    4.7768
%    23.4488    4.7768
%     1.3791    6.6571
%     6.6571    6.6571
%    30.4061    6.6571



%% description of the mat file
% filename:     <name>_Whole<date>.mat
% -- data stored in this file ---------------------------------------------
%   Name        Description
%   isForced    logical, TRUE iff failed LSAS & continued by experimenter
%   isPLWFirst  logical, TRUE iff DotRotTask is folowed by OctalTask
%   ques        struct, contails data from StaticChoice questionaires
%   wrkspc      struct, contains data from RL_PLW tasks
%
% -- the structure of variables ques, wrkspc -----------------------------
%{

ques
     IRI
           items: {1x28 cell}
           title: {[1]  [1x68 char]}
          target: {28x1 cell}
           instr: {28x1 cell}
          scales: {28x5 cell}
          encode: [1x1 struct]
          		scale: {4x3 cell}
						'fear'         [1x24 double]    [56]
						'avoidance'    [1x24 double]    [52]
      			inv: [3 4 7 12 13 14 15 18 19]
           thrsh: {[1]  [-Inf Inf]  [0]}
    isShowResult: 0
        response: {28x1 cell}
         restime: [28x1 double]
            isOK: 0

     LSAS
           items: {48x1 cell}
           title: {[1]  [1x119 char]}
          target: {48x1 cell}
           instr: {48x1 cell}
          scales: {48x4 cell}
          encode: [1x1 struct]
             	scale: {2x3 cell}
         			    'PT'    [1x7 double]    [24]
					    'FS'    [1x7 double]    [22]
					    'EC'    [1x7 double]    [18]
					    'PD'    [1x7 double]    [20]
      			inv: []
           thrsh: {[1 2]  [39 59]  [0]}
    isShowResult: 0
        response: {48x1 cell}
         restime: [48x1 double]
            isOK: 0

wrkspc
     Octal
	       conf: [1x1 struct]
	       mode: [1x1 struct]
	    Subinfo: {8x1 cell}
	       data: [1x1 struct]
	       flow: [1x1 struct]
	     Trials: [66x10 double]
    DotRot
	       conf: [1x1 struct]
	       mode: [1x1 struct]
	    Subinfo: {8x1 cell}
	       data: [1x1 struct]
	       flow: [1x1 struct]
	     Trials: [315x10 double]
    ImEval
	       conf: [1x1 struct]
	       mode: [1x1 struct]
	    Subinfo: {8x1 cell}
	       data: [1x1 struct]
	       flow: [1x1 struct]
	     Trials: [20x10 double]



data most most likely used for analysis are as follows:
ques.<task>.encode.scale{:,1}	name of each sub-inventory
ques.<task>.encode.scale{:,2}	items in each sub-inventory (use ques.<task>.items for lookup)
ques.<task>.encode.scale{:,3}	total score for each sub-inventory
ques.<task>.response 			raw response as char, use ./lib/quesEncode.m to calculate the above total score
ques.<task>.restime				response time for each items, in seconds. least interval 0.01s
<task> is either IRI, or LSAS

wrkspc.<task>.Trials			contains all data necessary for analysis
wrkspc.<octal>.data.imnames     images used for each Trials

Trials:
1 			2 				3 				4 			5 			6 			7
condition	response_type	response_time	is_outward	is_upright	trialNo		iniTactile(INVALID,no tactile)

condition: controls the face stimuli, 1:4
    case 1
        % anger
        weight = [6 0 2];
    case 2
        % neutral
        weight = [0 8 0];
    case 3
        % happy
        weight = [2 0 6];
    case 4
        % no image here; return blank image path
        weight = 0;


	number of images we have for each type
	           anger     neu     happy
	1:male     37        113     123
	2:female   37        109     125

response_type: 3, 4, 7*N
	3 <-> UPkey   <-> inward
	4 <-> DOWNkey <-> outward
	7*N: for ImEvalTask, encoded as product of 7. e.g. if response is 4 indicating neutral, then response_type = 7*4 = 28
%}

mode.interactive = 0;
mode.verbose = 0;
mode.picture = 0;
mode.keepnoresponse = 0;

if mode.interactive
    mode.verbose = 1;
    mode.picture = 1;
end

try
    matfiles = cellstr(ls('data/Group/Whole/*.mat'));
    % matfiles = {'liuyang_Whole1_19-Apr-2014.mat'};
    alldata = cell(numel(matfiles),1);
    DS = dataset();
    for i=1:numel(matfiles)
        % check if all data is with the same structure as described above
        % already done, and YES
        s=load(matfiles{i});
        s.wrkspc = orderfields(s.wrkspc, {'Octal','DotRot','ImEval'});
        s.ques = orderfields(s.ques, {'LSAS','IRI'});
        tasks = fieldnames(s.wrkspc);

        Disp(matfiles{i},mode.verbose);
        Disp(size(fieldnames(s.wrkspc)),mode.verbose);
        Disp(size(fieldnames(s.ques)),mode.verbose);

        if mode.picture
            figure;
            set(gcf,'Units','normalized','Position',[0 0 1 1])
            pn = 2;
            pidx = reshape(1:numel(tasks)*pn,[],pn);
        end

        for ii = 1:numel(tasks)
            Disp(tasks{ii},mode.verbose)
            Trials = s.wrkspc.(tasks{ii}).Trials;
            switch tasks{ii}
                case 'ImEval'
                    validres = [1:7];
                    Trials(:,2) = Trials(:,2)/7;
                    fltr = ismember(Trials(:,2),validres);
                    Trials=Trials(fltr,:);
                    dur{i}.(tasks{ii}) = digest2(Trials(:,2),{Trials(:,1)}, {1:4},'mean');
                    durnorm{i}.(tasks{ii}) = digest2(Trials(:,3),{Trials(:,1)}, {1:4}, 'mean'); % RT stored here

                case {'Octal','DotRot'}
                    if mode.keepnoresponse
                        validres = [0 3 4];
                    else
                        validres = [3 4];
                    end
                    fltr = ismember(Trials(:,2),validres);
                    Trials=Trials(fltr,:);
                    Trials(:,end+1) = Trials(:,3) / mean(Trials(:,3));
                    dur{i}.(tasks{ii}) = digest2(Trials(:,3),{Trials(:,1), Trials(:,2)}, {[1:4] validres},'mean');
                    durnorm{i}.(tasks{ii}) = digest2(Trials(:,end),{Trials(:,1), Trials(:,2)}, {[1:4] validres},'mean');
                    durr{i}.(tasks{ii}) = digest2(Trials(:,3),{Trials(:,2)}, {validres}, 'mean');
                    nshift{i}.(tasks{ii}) = digest2(Trials(:,5),{Trials(:,1), Trials(:,2)}, {[1:4] validres},'sum');
                otherwise
                    error('what task is this?');
            end

            if mode.picture
                subplot(pn,numel(tasks),pidx(ii,1));
                histfit(Trials(:,3));
                subplot(pn,numel(tasks),pidx(ii,2));
                boxplot(Trials(:,3),[Trials(:,2) Trials(:,1)]);
                % boxplot(Trials(:,3),[Trials(:,2)]);
                xlabel(tasks{ii});
            end
            if mode.verbose
                tabulate(Trials(:,2));
            else
                tmp=tabulate(Trials(:,2));
            end

%             Disp(s.ques.LSAS.encode.scale(:,1)',mode.verbose);
%             Disp([cell2mat(s.ques.LSAS.encode.scale(:,3))-24]',mode.verbose);
            Disp(correct(s.ques.LSAS.encode.scale),mode.verbose);
            Disp(s.ques.IRI.encode.scale,mode.verbose);

        end

        if mode.picture
            title(['LSAShigh=' num2str(s.isForced==0) ':' matfiles{i}]);
        end

        if mode.interactive
            iswanted = input('Include this sub for processing? 1 for yes, 0 for no:\n');
        else
            iswanted = 1;
        end

        if iswanted
            ids = singleds(s, dur, durnorm, durr, nshift, i);
            DS = [DS; ids];
            Disp([matfiles{i} ' added!'],mode.verbose);
        else
            Disp([matfiles{i} ' skipped!'],mode.verbose);
        end
        Disp('-------------------',mode.verbose);

        alldata{i} = s;

    end

    export(DS,'file','data/Group/Whole/PLWGroup.csv','Delimiter',',');
    disp('dataframe data/Group/Whole/PLWGroup.csv saved.');

catch
    save buggy;
    rethrow(lasterror);
end
%% Method
%     �������ã����ǵĻ��������ǿ����Ƿ�߽����齫bistable��PLW֪��Ϊ�������ߣ����뿪�Լ���facing away)
%     ��Ŀǰ��Ҫ���ļ����������£�
%
%     1 �����ڲ�ͬƽ����������֪�������£������볯���˶�֪���ľ���ʱ���Լ���ȷ����ʱ�䣬�����볯���Լ���ȷ��֪��
%     ���������ʱ�䣨��ֵ������������ʱ���ʱ���ֵ���Ա���Ϊƽ������֪�������ԡ����Ժ͸��ԣ����Ƚ�ɢ����PLW�Ĳ���
%������ʱ�������ֵ�-�������Ͳ����������ʱ����ÿ�����������г���ͳ����ƽ������Ȼ�󱾱𽫳���ͳ����ʱ��������ƽ������
%     2 ������ͬ���ķ����������Է�Ϊ���Ǹߵ͵÷��飬�Ƚϲ�ͬ����PLW�ɼ���
%
%     3 Ϊ�������߷�����Ҫ��ñ��ԵĽ��ǵ÷��Լ���ͼƬ��ƽ�����������ۡ�
%
%     ���������һ���ۺϵı�񣬸��������������Ա����䡢����֣�ʵ�������Լ���Ϊ�����
%     ���ǿ�����һ����ط��������ܹ���һ�·�������
%
%     ����Ҫ�ģ��ǿ�һ��ɢ����PLW�Ĳ��죻�Լ��Ƿ����ظ����˵Ľ�����߽����齫bistable��PLW֪��Ϊ�������ߡ�
%     ������������ƣ���δ�ﵽͳ�����������վ����ҹ�����Ҫ�����ԡ�
%
%     ���ĵ�ǰ�Ժ�ʵ�鲿���������뿪ʼд�������Լ�ץ��ʱ�䡣
%
%
%����󣺻���������ˡ� ��GLM��univariate������PLW�����£��߽������и����facing viewer bias (���⣩��resp��LSASgroup�Ľ�����������tnormalPLW, tnormalDotΪ�Ա�������Dot�������²��������ƫ�˵�����ǵ��ڵ��Ǹ߼���֪�ӹ����¼�(PLW����ɢ���˶��������ǣ�δ��ƽ��������һ������Ӱ�졣�����ϣ������֪��(��facing bias)ռ���������֮ǰ�ĺܶ��о�һ�£��μ�֮ǰ���������2013-van de Cruys-An anxiety-induced bias in the perception of a bistable point-light walker�������ǽ�����Ľ����������׵ķ����෴����Ҫ����һ����ʲôԭ�򣬻���δ�۲쵽������Ӱ�졣

%% Helper functions

    function [dur, g] = digest2(orig, origG, rulesC, func)
        % origG is { , }
        % rulesC is { , }
        % func: 'mean', 'sum'
        [dur, g] = grpstats(orig, origG, {func,'gname'}); %  cond: 4; resp: 0:no; 3-inward; 4-outward
        dur = [dur str2double(g)];

        for j=1:numel(rulesC)
            cond(j)=numel(rulesC{j});
        end
        dur = fillhole(dur, cond, rulesC);
    end

    function ids = singleds(s, dur, durnorm, durr, nshift, i)
        % create dataset array

        N = numel(dur{i}.Octal(:,2));

        ds.id   = repmat(i,N,1);
        ds.name = repmat(cellstr(s.wrkspc.Octal.Subinfo{1}),N,1);
        ds.phone= repmat(cellstr(s.wrkspc.Octal.Subinfo{8}),N,1);
        ds.age  = repmat(str2double(s.wrkspc.Octal.Subinfo{2}),N,1);
        ds.gender=repmat(s.wrkspc.Octal.Subinfo{3},N,1);
        ds.isForced = repmat(s.isForced,N,1);
        ds.fear = repmat(s.ques.LSAS.encode.scale{1,3},N,1)-24;
        ds.avoid = repmat(s.ques.LSAS.encode.scale{2,3},N,1)-24;
        ds.LSAS = sum([ds.fear ds.avoid],2);
        ds.LSAShigh = (ds.fear+ds.avoid)>29.1+17.3;
        ds.PT = repmat(s.ques.IRI.encode.scale{1,3},N,1);
        ds.FS = repmat(s.ques.IRI.encode.scale{2,3},N,1);
        ds.EC = repmat(s.ques.IRI.encode.scale{3,3},N,1);
        ds.PD = repmat(s.ques.IRI.encode.scale{4,3},N,1);
        ds.IRI = sum([ds.PT, ds.FS, ds.EC, ds.PD],2);
        ds.condition = dur{i}.Octal(:,2);
        ds.restype = dur{i}.Octal(:,3);
        ds.tplw = dur{i}.Octal(:,1);
        ds.tdot = dur{i}.DotRot(:,1);
        ds.tnormplw = durnorm{i}.Octal(:,1);
        ds.tnormdot = durnorm{i}.DotRot(:,1);
        ds.ratioplw = dur{i}.Octal(:,1)./reshape(repmat(dur{i}.Octal(dur{i}.Octal(:,3)==3,1),1,numel(unique(ds.restype)))',[],1);
        ds.ratiodot = dur{i}.DotRot(:,1)./reshape(repmat(dur{i}.DotRot(dur{i}.DotRot(:,3)==3,1),1,numel(unique(ds.restype)))',[],1);
        ds.rationormplw = durnorm{i}.Octal(:,1)./reshape(repmat(durnorm{i}.Octal(durnorm{i}.Octal(:,3)==3,1),1,numel(unique(ds.restype)))',[],1);
        ds.rationormdot = durnorm{i}.DotRot(:,1)./reshape(repmat(durnorm{i}.DotRot(durnorm{i}.DotRot(:,3)==3,1),1,numel(unique(ds.restype)))',[],1);
        ds.rplw = dur{i}.Octal(:,1)./repmat(durr{i}.Octal(:,1),numel(unique(ds.condition)),1);
        ds.rdot = dur{i}.DotRot(:,1)./repmat(durr{i}.DotRot(:,1),numel(unique(ds.condition)),1);
        ds.nshiftplw = nshift{i}.Octal(:,1);
        ds.nshiftdot = nshift{i}.DotRot(:,1);
        ds.eval = reshape(repmat(dur{i}.ImEval(:,1),1,numel(unique(ds.restype)))',[],1);
        ds.evalt= reshape(repmat(durnorm{i}.ImEval(:,1),1,numel(unique(ds.restype)))',[],1);

        ids = struct2dataset(ds);
    end

    function Disp(x, verbose)
        if verbose
            disp(x);
        else
            % do nothing
        end
    end

    function scale=correct(scale)
        % LSAS -24 correction
        for ij=1:size(scale,1)
            scale{ij,3}=scale{ij,3}-24;
        end
    end
end
