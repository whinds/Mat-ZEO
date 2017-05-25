function [phase,amp] = gethilbert(eeg,BufferMS,bandpassFreq,notchFilterFreq,resampleFreq)
%GETHILBERT - uses a hilbert transformation to get the instantaneous phase
%in a *several* bandpassed frequency band.  This is just like
%gethilbertphase but does multiple bands at the same time
%
% FUNCTION: 
% [phase,amp,eeg] = gethilbert(eeg,BufferMS,bandpassFreq,notchFilterFreq,resampleFreq)
%
% INPUT ARGs:
%   eeg = a vector containing the data
%   BufferMS = 1000 %in milliseconds
%   bandpassFreq = [
%                           2 4; %delta
%                           4 8; %theta
%                           8 16; %alpha
%                           16 32; %beta
%                           32 50; %gamma
%                           ];
%   notchFilterFreq = 60
%   resampleFreq = 500
%
% OUTPUT ARGS:
%   phase- (Bands,Time)
%   amp- (Bands,Time)


if ~exist('notchFilterFreq','var') || isempty(notchFilterFreq)
    notchFreqRange = [];
else
    notchFreqRange = notchFilterFreq + [-1 1];
end

% convert the durations to samples
buffer = fix((BufferMS/1000)*resampleFreq); %accounts for ms



nBand = size(bandpassFreq,1);
sz = [size(eeg,1), nBand, size(eeg,2)-2*buffer];
phase = zeros(sz);
amp = zeros(sz);

for bandNum = 1:nBand
    eegFilt = buttfilt(eeg,bandpassFreq(bandNum,:),resampleFreq,'bandpass',2);
    h = hilbert(eegFilt')'; %hilbert only goes across columns, unfortunately...
    h = h(:,buffer+1:end-buffer); %remove the buffering
    
    phase(:,bandNum,:) = angle(h);
    amp(:,bandNum,:) = abs(h);
end

eeg = eeg(:,buffer+1:end-buffer);
