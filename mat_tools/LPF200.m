function dat_filt = LPF200(dat,Fs,plotOn,order)
% performs 200Hz LPF on input data
% automatically 5th order Butterworth unless input order
% data assumed to be one dimensional
% Variables-
% dat       data
% Fs        sampling rate
% plotOn    1 - displays FFT plot
% order     Butterworth order

if ~exist('plotOn','var')
    plotOn = 0;
end

if ~exist('order','var')
    order = 5;
end

% butterworth filter
[B,A] = butter(order,200*2/Fs,'low');
dat_filt = filtfilt(B,A,dat);

if plotOn == 1
    figure;
    fdat = fft(dat,Fs);
    plot(abs(fdat))
    xlim([0 500])
    hold on
    plot(abs(fft(dat_filt,Fs)))
    legend('Unfiltered','Filtered')
    title('FFT before and after 200Hz LPF')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
end

end