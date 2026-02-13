% range-velocity tracking
%
% This program runs in an endless loop and is terminated by 
% closing the figure window or pressing a key.

close all;
clear;

c0=299792458; % speed of light
f0=24.125e9; % center frequency

P=1001; % number of samples shown in the plots
fmax=2000; % maximum frequency shift of targets

% ENTER YOUR SETUP HERE
file='scenario18.h5'; % FILE NAME FOR RECORDING AND PLAYBACK OF MEASUREMENT DATA
mode='dffile'; % FOR AVAILABLE MODES SEE STARTSTREAMING.M

% create figure windows
keypressed=false;
figure('WindowKeyPressFcn',@terminate,'DeleteFcn',@terminate);

% start streaming of radar sensor data
sensor=startstreaming(mode,file);
fs=sensor.fs; % sampling rate
k=sensor.k; % sweep rate
t=sensor.L*2/fs; % duration of one triangle
fmax=min(fs/2,fmax); % frequency range

% read frequency shifts from sensor
first=true;
df=getframe(sensor);
while ~keypressed&~isempty(df)
    if first        
        % plot the measurements
        subplot(2,1,1);
        yyaxis right;
        r=zeros(P,1);
        r(end)=c0*(df(1)-df(2))/4/k; % range
        rtarget=plot(linspace(-(P-1)*t,0,P),r,'-');
        ylim([0 c0*fmax/2/k]);
        ylabel('range in m');
        yyaxis left;
        v=zeros(P,1);
        v(end)=-(df(1)+df(2))/4/f0*c0; % velocity
        vtarget=plot(linspace(-(P-1)*t,0,P),v,'-');
        ylim([-fmax/2/f0*c0 fmax/2/f0*c0]);
        ylabel('velocity in m/s');
        xlim([-(P-1)*t 0]);
        xticks([-(P-1)*t 0]);
        xlabel('time in s');
        title('without tracking');
        grid on;
       
        % range-velocity tracking
        subplot(2,1,2);
        x=zeros(2,P);
        x(:,end)=kalman(df(:),t,f0,k);     
        yyaxis right;
        rtrack=plot(linspace(-(P-1)*t,0,P),x(1,:),'-');
        ylim([0 c0*fmax/2/k]);
        ylabel('range in m');
        yyaxis left;
        vtrack=plot(linspace(-(P-1)*t,0,P),x(2,:),'-');
        ylim([-fmax/2/f0*c0 fmax/2/f0*c0]);
        ylabel('velocity in m/s');
        xlim([-(P-1)*t 0]);
        xticks([-(P-1)*t 0]);
        xlabel('time in s');
        title('with tracking');
        grid on;

        first=false; % only update graphs in the future
    else
        % update the measurements
        r=circshift(r,-1);
        r(end)=c0*(df(1)-df(2))/4/k; % range
        rtarget.YData=r;
        v=circshift(v,-1);
        v(end)=-(df(1)+df(2))/4/f0*c0; % velocity
        vtarget.YData=v;
        
        % update the range-velocity tracking
        x=circshift(x,-1,2);
        x(:,end)=kalman(df(:),t,f0,k);
        rtrack.YData=x(1,:);
        vtrack.YData=x(2,:);
    end
   
    df=getframe(sensor); % read frequency shifts from sensor
end

% stop streaming of radar sensor data
stopstreaming(sensor);

function terminate(src,event)
   assignin('base','keypressed',true);
end
