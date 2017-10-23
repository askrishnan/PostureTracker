%cleans workspace
clear;
clf; 

%% Calibrating the sensor for you
% Intializes mobile sensors
m = mobiledev;
m.AccelerationSensorEnabled = 1;        % turns on acceleration sensor
m.Logging = 1;                          % begins data logging

% Various calibration positions
disp('Sit up straight')
pause(20);
beep;
disp('Slouch a little')
pause(10);
beep;
disp('Slouch a lot')
pause(10);
beep;
disp('Lean left')
pause(10);
beep;
disp('Lean right')
pause(10);
beep;
disp('Sit up straight again')
pause(20);
beep;
beep;

m.Logging = 0;                      % turns off data logging
[aCal, t] = accellog(m);            % logs accelerometer data and time

accelData = [t aCal];               % puts time and accelerometer data into one matrix that's compatible with makeAccelerometerPlots
makeAccelerometerPlots(accelData);  % makes the plots!

% seperates x, y, and z data
x = aCal(:,1);
y = aCal(:,2);
z = aCal(:,3);

Fs = 10.34;         % readings/s
N = length(aCal);   % length of the signal

% taking ffts of the data, dividing by the length of the signal
fft_x = fft(x)/N;
fft_y = fft(y)/N;
fft_z = fft(z)/N;

% shifts the ffts so that they are all centered around zero
% also takes absolute values
m_x = fftshift(abs(fft_x));
m_y = fftshift(abs(fft_y));
m_z = fftshift(abs(fft_z));

f = linspace(-Fs/2, Fs/2-Fs/N, N);

% plots transforms
figure
hold on;
plot(f, m_x, 'r-');
plot(f, m_y, 'b-');
plot(f, m_z, 'g-');

% finds maximum value for each axis, which will be used as the center
% threshold value
max_x = max(m_x);
max_y = max(m_y);
max_z = max(m_z);

% creating optimal posture thresholds for each axis 
padVal = 1;                             % padding around center threshold value
xThres = [max_x-padVal max_x+padVal];
yThres = [max_y-padVal max_y+padVal];
zThres = [max_z-padVal max_z+padVal];

disp('LeanLeft is calibrated!')

%% Logging Data Live
m.Logging = 1;                          % begins data logging

%initialize data for rolling plot
xData = zeros(600,1);
yData = zeros(600,1);
zData = zeros(600,1);

%initialize plot and subplots
figure(1);

% plots x data live
subplot(3,1,1) 
pX = plot(xData);
r_x1 = refline(0, xThres(1));
r_x2 = refline(0, xThres(2));
r_x1.Color = 'r';
r_x2.Color = 'r';
axis([1 600 xThres(1)-1 xThres(2)+1]);

% plots y data live
subplot(3,1,2) 
pY = plot(yData);
r_y1 = refline(0, yThres(1));
r_y2 = refline(0, yThres(2));
r_y1.Color = 'r';
r_y2.Color = 'r';
axis([1 600 yThres(1)-1 yThres(2)+1]);

% plots z data live
subplot(3,1,3) 
pZ = plot(zData);
r_z1 = refline(0, zThres(1));
r_z2 = refline(0, zThres(2));
r_z1.Color = 'r';
r_z2.Color = 'r';
axis([1 600 zThres(1)-1 zThres(2)+1]);
pause(1)
tic
while (toc < 60)                   %run for 60 secs
      %get new accelerometer values every second
      [a, t1] = accellog(m);
      
      if length(a) > 600
        xData = a(end-599:end,1);
        yData = a(end-599:end,2);
        zData = a(end-599:end,3);
      else
        xData(1:length(a)) = a(:,1);
        yData(1:length(a)) = a(:,2);
        zData(1:length(a)) = a(:,3);
      end
      if (xData(end) < xThres(1) || xData(end) > xThres(2))
          disp('Your x axis is off.')
      end
      if (yData(end) < yThres(1) || yData(end) > yThres(2))
          disp('Your y axis is off.')
      end
      if (zData(end) < zThres(1) || zData(end) > zThres(2))
          disp('Your z axis is off.')
      end
      if (xData(end) > xThres(1) && xData(end) < xThres(2))
          disp('Good job on your x axis')
      end
      if (yData(end) > yThres(1) && yData(end) < yThres(2))
          disp('Good job on your y axis')
      end
      if (zData(end) > zThres(1) && zData(end) < zThres(2))
          disp('Good job on your y axis')
      end
      
      % redraw plot
      pX.YData = xData;
      pY.YData = yData;
      pZ.YData = zData;
      drawnow
end

