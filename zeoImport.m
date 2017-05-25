function [eeg]=zeoImport(filename)
%filename = 'something.txt'; % a string
%exmaple: 
% 'V:\Epilepsy Human Data\STUDY DATA\TJ038\INTERICTAL\INTERICTAL1\MICRO\2012-03-01_13-13-38_11_60set1.txt'
samplerate=128;
[ddtpath, epoch,ccc] = fileparts(filename);
unit_struct=[];
try
m=csvread(filename);% read the comma delimited .txt file
catch
    disp('cannot read file!');disp(filename);return
end %try/catch

timestamps=m(:,1);
timestamps=timestamps-timestamps(1); %set timestamps to start at 0 seconds
eeg=zeros(samplerate*max(timestamps),1);

for i=1:length(timestamps) 
    eegDex=(timestamps(i)*128)+1;
    eeg(eegDex:eegDex+127)=m(i,2:end); %+1 for zero index
end
eeg_raw=eeg;
mean_amp=rms(eeg_raw);
eeg_clean=eeg_raw(eeg_raw>mean_amp*.06 | eeg_raw<mean_amp*.06*(-1));
new_mean_amp=rms(eeg_clean);
eeg_dat=eeg_clean(eeg_clean<new_mean_amp*3 & eeg_clean>new_mean_amp*(-3));
%eeg(eeg==0)=median(eeg(eeg~=0));

clear('m');
save([filename '.mat'])
end %end of function