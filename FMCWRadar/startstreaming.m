function sensor=startstreaming(mode,file)
%STARTSTREAMING start data streaming from the radar sensor
%   sensor      radar sensor device
%   mode        supported modes
%               'st200klcfmcw'  RFbeam ST200 starterkit with K-LC2 sensor
%               'st200kmcfmcw'  RFbeam ST200 starterkit with K-MC1 sensor
%               'fmcwfile'      playback of recorded measurements
%               'convert'       similar to fmcwfile but add detected
%                               frequency shifts to the file
%   file        file name
%
% Use daqlist to explore the DeviceIDs available on your PC.

clear getframe; % reset dataset counter
clear mti; % initialize moving target indication
clear kalman; % initialize Kalman filter

switch mode
    case 'st200klcfmcw'
        sensor.mode='st200klcfmcw';
        sensor.file=file;
        sensor.fs=125000; % sampling rate
        sensor.L=2^12; % samples per ramp (RFbeam Signal Explorer uses 2048 or 4096 samples per ramp)
        sensor.k=(24197000000-24045000000)/sensor.L*sensor.fs; % sweep rate

        % create data acquisition device
        % DEPENDING ON YOUR PC YOU MAY HAVE TO SELECT A DEVICEID DIFFERENT FROM 'Dev1'
        sensor.device=daq('ni');        
        addoutput(sensor.device,'Dev1','Port1/Line3','Digital');
        write(sensor.device,1); % deactivate preamplifier
%         write(sensor.device,0); % activate preamplifier
        removechannel(sensor.device,1);
        addoutput(sensor.device,'Dev1',0,'Voltage');
%         ch=addinput(sensor.device,'Dev1',[4 5],'Voltage'); % low gain, dc coupled
        ch=addinput(sensor.device,'Dev1',[6 7],'Voltage'); % high gain, ac coupled, lowpass
        ch(1).Range=[-5,5];
        ch(2).Range=[-5,5];
        ch(1).TerminalConfig='SingleEnded';
        ch(2).TerminalConfig='SingleEnded';
        sensor.device.Rate=sensor.fs;
        disp('connected to ST200 with K-LC sensor');

        % save parameters to HDF5 file
        h5create(sensor.file,'/fs',1);
        h5write(sensor.file,'/fs',sensor.fs);
        h5create(sensor.file,'/L',1);
        h5write(sensor.file,'/L',sensor.L);
        h5create(sensor.file,'/k',1);
        h5write(sensor.file,'/k',sensor.k);

        % data will go here
        h5create(file,'/data',[sensor.L*4 Inf],'ChunkSize',[sensor.L*4 1]);

        % start data acquisition
        preload(sensor.device,repmat(modulator(sensor),2^7,1)); % triangles
        start(sensor.device,'RepeatOutput');
        
    case 'st200kmcfmcw'        
        sensor.mode='st200kmcfmcw';
        sensor.file=file;
        sensor.fs=125000; % sampling rate
        sensor.L=2^12; % samples per ramp (RFbeam Signal Explorer uses 2048 or 4096 samples per ramp)
        sensor.k=(24183000000-24021000000)/sensor.L*sensor.fs; % sweep rate

        % create data acquisition device
        % DEPENDING ON YOUR PC YOU MAY HAVE TO SELECT A DEVICEID DIFFERENT FROM 'Dev1'
        sensor.device=daq('ni');        
        addoutput(sensor.device,'Dev1','Port1/Line0','Digital');
        write(sensor.device,0); % enable radar sensor
        removechannel(sensor.device,1);
        addoutput(sensor.device,'Dev1',0,'Voltage');
%         ch=addinput(sensor.device,'Dev1',[0 1],'Voltage'); % low gain, dc coupled
        ch=addinput(sensor.device,'Dev1',[2 3],'Voltage'); % high gain, ac coupled
        ch(1).Range=[-5,5];
        ch(2).Range=[-5,5];
        ch(1).TerminalConfig='SingleEnded';
        ch(2).TerminalConfig='SingleEnded';
        sensor.device.Rate=sensor.fs;
        disp('connected to ST200 with K-MC1 sensor');

        % save parameters to HDF5 file
        h5create(sensor.file,'/fs',1);
        h5write(sensor.file,'/fs',sensor.fs);
        h5create(sensor.file,'/L',1);
        h5write(sensor.file,'/L',sensor.L);
        h5create(sensor.file,'/k',1);
        h5write(sensor.file,'/k',sensor.k);

        % data will go here
        h5create(file,'/data',[sensor.L*4 Inf],'ChunkSize',[sensor.L*4 1]);

        % start data acquisition
        preload(sensor.device,repmat(modulator(sensor),2^7,1)); % triangles
        start(sensor.device,'RepeatOutput');

    case 'fmcwfile'
        sensor.mode='fmcwfile';
        sensor.file=file;
        
        % load parameters from HDF5 file
        sensor.fs=h5read(file,'/fs');
        sensor.L=h5read(file,'/L');
        sensor.k=h5read(file,'/k');

        disp('read data from file');

    case 'convert'
        sensor.mode='convert';
        sensor.file=file;
        
        % load parameters from HDF5 file
        sensor.fs=h5read(file,'/fs');
        sensor.L=h5read(file,'/L');
        sensor.k=h5read(file,'/k');
        
        % detection results will go here
        h5create(file,'/df',[2 Inf],'ChunkSize',[2 1]);

        disp('add detected frequency shifts to file');

    otherwise
    	error('unsupported mode');
end

end
