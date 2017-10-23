clear;
clf;
load('allData.mat');        % loads a matirx of the class's accelerometer data
 
i = 1;
xVal = -2;
yVal = -1;
zVal = 0;
x = [];
y = [];
z = [];

% looping through matrix to seperate x, y, and z values
while i < 21
    xVal = xVal + 3;         
    yVal = yVal + 3;
    zVal = zVal + 3;
    x = [x accelData(:,xVal)];      % matrix of just x values
    y = [y accelData(:,yVal)];      % matrix of just y values
    z = [z accelData(:,zVal)];      % matrix of just z values
    i = i + 1;
end

Fs = 50; % readings/s
N = length(accelData);  % length of the signal

% taking ffts of the data, dividing by the length of the signal
fft_x = fft(x)/N;
fft_y = fft(y)/N;
fft_z = fft(z)/N;

% shifts the ffts so that they are all centered around zero
m_x = fftshift(abs(fft_x));
m_y = fftshift(abs(fft_y));
m_z = fftshift(abs(fft_z));

f = linspace(-Fs/2, Fs/2-Fs/length(accelData), length(accelData));

hold on;

% plots transforms
plot(f, m_x, 'r-');
plot(f, m_y, 'b-');
plot(f, m_z, 'g-');

% finds maximum threshold value for each person
max_x = max(m_x);
max_y = max(m_y);
max_z = max(m_z);
