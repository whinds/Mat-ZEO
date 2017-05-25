function [pow,amp,phase]=bPrint(eeg)
%samplerate
fs=128;
%f=(1:1:50);
freqs=(2^(1/8)).^(8:45); %[2 - 50]
%WAVLET
[phase,pow]=multiphasevec2(freqs,eeg',fs,6);
%Normalize power
baseline=mean(pow,2);
varyants=std(pow');
norm_pow=bsxfun(@rdivide,bsxfun(@minus,pow,baseline),varyants');
figure;m=5;n=1;
interval=60; %x tick marks in seconds, i.e.interval = 600 = 10 minutes = 600 seconds
subplot(m,n,1);
imagesc(norm_pow);axis xy
%clims=get(gca,'cdata');
set(gca,'clim',[-.5 .5],'yscale','linear','yticklabel',freqs,'ytick',[1:numel(freqs)],'xticklabel',[0:numel(eeg)/(fs*interval)],'xtick',[1:fs*interval:numel(eeg)])
xlabel(['Time (in ' num2str(interval) ' second intervals, aka ' num2str(interval/60) ' minute bins)']);
ylabel('Frequency');title('Norm. Pow');
colorbar;
%smoothed power
smoothed=smooth(norm_pow);
[spow]=reshape(smoothed,[size(pow,1),size(pow,2)]);
subplot(m,n,2);
imagesc(spow);axis xy
set(gca,'clim',[-.5 .5],'yscale','linear','yticklabel',freqs,'ytick',[1:numel(freqs)],'xticklabel',[0:numel(eeg)/(fs*interval)],'xtick',[1:fs*interval:numel(eeg)])
xlabel(['Time (in ' num2str(interval) ' second intervals, aka ' num2str(interval/60) ' minute bins)']);ylabel('Frequency');
colorbar;
%HILBERT
hfreqs=[
        2 4; %delta
        4 8; %theta
        8 16; %alpha
        16 32; %beta
        32 50; %gamma
        ];
[~,amp] = gethilbert(eeg',10,hfreqs,60,fs);
amp=squeeze(amp);
%normalize
Namp=bsxfun(@rdivide,bsxfun(@minus,amp,mean(amp,2)),std(amp')');
subplot(m,n,3);
imagesc(Namp);axis xy
%clims=get(gca,'cdata');
set(gca,'clim',[-2.5 2.5],'yscale','linear','yticklabel',num2str([hfreqs(:,1) hfreqs(:,2)]),'ytick',[1:size(hfreqs,1)])
xlabel('Time');ylabel('Frequency');
colorbar;
%smoothed power
smoothed_amp=smooth(Namp');
[Samp]=reshape(smoothed_amp,[size(Namp,2),size(Namp,1)]);
subplot(m,n,4);
%imagesc(Namp-Samp');
imagesc(Samp');
axis xy
set(gca,'clim',[-2.5 2.5],'yscale','linear','yticklabel',num2str([hfreqs(:,1) hfreqs(:,2)]),'ytick',[1:size(hfreqs,1)])
xlabel('Time');ylabel('Frequency');
colorbar;
%power log decrease
subplot(m,n,5);
plot(freqs,mean(norm_pow,2));
hold on;plot(freqs,baseline,'g');
end %function end
