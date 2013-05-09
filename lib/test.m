function  test()
% load yeshaoqiangMirrorD26-Jan-2013;
r=1:5;
figure;

v=sort([data.righttouch;data.lefttouch]);
v1=sort([data.righttouch;]);
t1=find(data.tTrack==1);%this is left
t2=find(data.tTrack==2);

% plot(v(r),1,'ro');
hold on;
x=data.lefttouch(r);plot(x,1*ones(size(x)),'r*');
x=data.righttouch(r);plot(x,1*ones(size(x)),'b*');
x=t1(r);plot(x,2*ones(size(x)),'ro');
x=t2(r);plot(x,2*ones(size(x)),'bo');



h=gca;
set(h,'YTick',[1 2]);
set(h,'YTickLabel',{'Visual' 'Tactile'});
set(h,'XGrid','on')
axis([0 800 1 3]);

title('Tactile-Visual Stimuli (Tactile leading 150ms)');
xlabel('Flip/10ms');
ylabel('Stimuli Type');

legend('visual-right','visual-left','tactile-right','tactile-left');
legend('Location','NorthEast','Orientation','horizontal');
legend('boxoff');

% 1�磺25X38 
% 2�磺35X52 
% 3�磺89X63.5 
% 5�磺89X127 ��5X3.5) 
% 6�磺102X152 (4X6) 
% 7�磺127X178 (5X7) 
% 8�磺152X203 (6X8) 
% 10�磺203X254 (8X10) 
% 12�磺203X305 (8X12) 
% 14�磺203X356 (8X14) 
% 
% 
% 12�����µı�׼�ߴ� 
% 12�磺250X300 
% 14�磺300X350 
% 16�磺300X400 (12x16) 
% 18�磺350X450 (14x18) 
% 20�磺400X500 (16x20) 
% 24�磺500X600 (20x24) 
% 30�磺600X800 (24x30) 
% 36�磺700X900 (24x36) (30x36) 
% ��λ����mmΪ��λ��. 
% 
% 2���зִ�2����С2�� 
% ��2��:3.5cmX5.2cm 
% С2��:3.5cmX4.5cm(�������õ�����)

end
