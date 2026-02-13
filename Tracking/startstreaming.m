function sensor=startstreaming(mode,file)
%STARTSTREAMING start data streaming from the radar sensor
%   sensor      radar sensor device
%   mode        supported modes
%               'rvfile'        playback of recorded measurements
%   file        file name
%
% Use daqlist to explore the DeviceIDs available on your PC.

clear getframe; % reset dataset counter
clear kalman; % initialize Kalman filter

switch mode

    case 'dffile'
        sensor.mode='dffile';
        sensor.file=file;
        
        % load parameters from HDF5 file
        sensor.fs=h5read(file,'/fs');
        sensor.L=h5read(file,'/L');
        sensor.k=h5read(file,'/k');

        disp('read data from file');
        
    otherwise
    	error('unsupported mode');
end

end
