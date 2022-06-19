%% Argument Definitions
rec_num = 5;                       % number of receivers
trans_num = 3;                     % number of transmitters
num_timesteps = 32;                            % number of time steps
sigma_w_sq = 0.5;                     % noise variance
rng(208749481 + 037580792);        % random number generator seed - sum of Idan's ID and Moshe's ID
Pn = 2;                            % Transmit power
SNRs = [0,5,10,15,25];
num_of_snrs = max(size(SNRs));
num_channels_per_snr = 1000;
sigma_sq = randn(num_channels_per_snr,num_of_snrs,trans_num, rec_num); % channels variances
channels_shape = [num_channels_per_snr,num_of_snrs,trans_num, rec_num, num_timesteps];
power_given = false;
%% Channel creation
trans_power_to_noise_ratio = 10 .^ (SNRs ./ 10. );

if power_given
  % noise variance from given transmit power
  sigma_w_sq = Pn ./ trans_power_to_noise_ratio;
else
  Pn = sigma_w_sq .* trans_power_to_noise_ratio;
end

% replicate to create num_channels_per_snr
Pn = repmat(Pn, [num_channels_per_snr, 1]); 
% (clean) symbols generation  - S,n = Pn/sqrt(2) (+- 1 +- 1i)
symbols =  ((randi([0,1],num_channels_per_snr,num_of_snrs,trans_num,num_timesteps) ...
           + randi([0,1],num_channels_per_snr,num_of_snrs,trans_num,num_timesteps) .* 1i) ...
           .* 2 - 1) .* (Pn./sqrt(2));

H = randn(num_channels_per_snr,num_of_snrs,trans_num, rec_num, num_timesteps) .* sigma_sq;
w_a =  randn(1,rec_num) * sigma_w_sq;
%w_a = repmat(w_a,[num_channels_per_snr,num_of_snrs,trans_num, 1]);
w_a = reshape(repmat(w_a, [num_channels_per_snr, num_of_snrs  ,trans_num,1, num_timesteps]),channels_shape);

symbols =  reshape(repmat(symbols, [1,1, 1 ,rec_num,1]),channels_shape);

x = H.*symbols + w_a  ;

