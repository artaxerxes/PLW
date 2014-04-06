function responseC =  oneItem(ques, i, w, wsize, kb, responseC)
scalemap = ['1: ' ques.scales{i, 1}];
for j=2:size(ques.scales, 2)
    scalemap = [scalemap, '  ', num2str(j) ': ', ques.scales{i, j}];
end

DrawFormattedText(w, ques.instr{i}, 0, 80, [255, 255, 255, 255]);
Screen('DrawText', w, ['���ü��������� 1 �� ', num2str(size(ques.scales, 2)), ' ������Ӧ��'], 0, 300, [255, 255, 255, 255]);
Screen('DrawText', w, scalemap, 0, 330, [255, 255, 255, 255]);

kbCode = Instruction(ques.items{i}, w, wsize, 0, 1, kb, 5 ,1, 0);
if sum(kbCode)==0
    [t, kbCode] = KbWait([],2);
end
kbName = KbName(kbCode);
responseC{i} = kbName(1);
end