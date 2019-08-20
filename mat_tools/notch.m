function dat_filt = notch(dat,Fs,plotOn)
% 3rd order butterworth notch filter at
% 60, 120, 180 Hz
% any sampling rate
% data assumed to be one dimensional
% Variables
% dat       data
% Fs        sampling rate
% plotOn    1 - displays FFT plot

if ~exist('plotOn','var')
    plotOn = 0;
end

% butterworth filter
[B,A] = butter(3,[60*2/Fs-5/Fs 60*2/Fs+5/Fs],'stop'); % 60 hz
[B1,A1] = butter(3,[120*2/Fs-5/Fs 120*2/Fs+5/Fs],'stop'); % 120 hz
[B2,A2] = butter(3,[180*2/Fs-5/Fs 180*2/Fs+5/Fs],'stop'); % 180 hz

dat_filt = filtfilt(B,A,dat);
dat_filt = filtfilt(B1,A1,dat_filt);
dat_filt = filtfilt(B2,A2,dat_filt);

if plotOn == 1
    figure;
    fdat = fft(dat,Fs);
    plot(abs(fdat))
    xlim([0 200])
    hold on
    plot(abs(fft(dat_filt,Fs)))
    legend('Unfiltered','Filtered')
    title('FFT before and after 60Hz notch filtering')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
end

end