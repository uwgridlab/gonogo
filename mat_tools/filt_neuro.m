function filtered_data = filt_neuro(data, fs)
% basic filtering pipeline for neuro data
% notch @ 60, 120, 180 Hz
% LPF @ 200 Hz
% HPF @ 0.1 Hz

dat_filt = notch(data,fs);
dat_filt = LPF200(dat_filt,fs);
dat_filt = HPF1(dat_filt,fs);

filtered_data = dat_filt;
        
end