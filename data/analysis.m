%1-response value 1-leftwards response (switch output 3); value
%2-rightwards response (footswitch output 1);
% 2-dur
% 3-Trial no.
% 4-1 from initial inwards; 2-initial outwards
% 5-second, 1-tactile short-long-short, 2-tactile equal; 3-tactile
% long-short-long.
%subs={'anshuai','cuizhenpeng','lilingyu','liuweifang','liuye','liuzi','mawenjing','shaojiayuan','shaorenjie','sihongwei','songqingjun','tantian','wanghao','wenghanxin','zhaoyuan','zhengguomao'};

subs = {'epar_Simple_.mat','mesede_Simple_.mat'}; % pre exp

M=[];
durtemp=[];
for isub=1:length(subs)
load(subs{isub},'totaltrials');
idx=find(totaltrials(:,1)==0);
totaltrials(idx,:)=[];
totaltrials(:,2)=totaltrials(:,2)/(mean(totaltrials(:,2)));
[m1,g1] = grpstats(totaltrials(:,2),{totaltrials(:,5),totaltrials(:,1)},{'mean','gname'});
        for j=1:length(g1)
            m1(j,2)=str2num(g1{j,1});
            m1(j,3)=str2num(g1{j,2});
        end
for k=1:3 % cond
        idxtemp=find(m1(:,2)==k);
        durtemp=m1(idxtemp,:);
        for resp=1:2 % for four conditions-"congruent","incongruent","bistable","baseline";
            if isempty(find(durtemp(:,3)==resp))
                durtemp(size(durtemp,1)+1,:) = [0.001 k resp];
            end
        end
         M=[M; durtemp];
end
% M1=reshape(M(:,1),[6,16])'; % resort
end
M1=reshape(M(:,1),[6,numel(subs)])';
M1=mean(M1);
figure;
hold on;

    plot(1:3, M1(1,[1,3,5]),'rs-');
    plot(1:3, M1(1,[2,4,6])','s-.');
    ylabel('duration');

hold off;
legend('Inwards','Outwards');
xlabel('tactile conditions');
set(gca,'Xtick',1:3);
set(gca,'XtickLabel',{'short-long-short','Synchronous','long-short-long'});



