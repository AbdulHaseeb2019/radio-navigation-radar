function sensor=startstreaming(mode,file)
%STARTSTREAMING start data streaming from the radar sensor
%   sensor      radar sensor device
%   mode        supported modes
%               'kld2cw'        RFbeam K-LD2 sensor, 
%                               there may be lost frames
%               'st100cw'       RFbeam ST100 starterkit
%               'st200klccw'    RFbeam ST200 starterkit with K-LC2 sensor
%               'st200kmccw'    RFbeam ST200 starterkit with K-MC1 sensor
%               'cwfile'        playback of recorded measurements
%   file        file name
%
% For proper configuration of the ST100 starterkit under
% Einstellungen->System->Sound->Sound-Systemsteuerung
% see the user manual.
%
% Connect K-LC5 sensor to X1 at ST100, select low gain (off off on).
% Connect K-LC2 sensor to X2 at ST100, select high gain (off on off).
% Connect K-MC1 sensor to X3 at ST100, select low gain (on off on).
%
% Use daqlist to explore the DeviceIDs available on your PC.

clear getframe; % reset dataset counter

switch mode
    case 'kld2cw'
        sensor.mode='kld2cw';
        sensor.file=file;
        sensor.L=256; % samples per frame
                
        % open serial connection
        sensor.port=serialport('COM5',38400,'ByteOrder','big-endian'); % ENTER CORRECT COM PORT HERE
        configureTerminator(sensor.port,'CR/LF','CR');
        
        % switch off FFT averaging
        writeline(sensor.port,'$S0A00');
        if ~isequal(readline(sensor.port),'@S0A00')
            error('protocol error');
        end
        
        % set sampling rate, there is no anti-aliasing filter
        writeline(sensor.port,'$S0401'); % 1280Hz
%         writeline(sensor.port,'$S0402'); % 2560Hz
%         writeline(sensor.port,'$S0403'); % 3840Hz
%         writeline(sensor.port,'$S0404'); % 5120Hz
%         writeline(sensor.port,'$S0405'); % 6400Hz
%         writeline(sensor.port,'$S0406'); % 7680Hz
%         writeline(sensor.port,'$S0407'); % 8960Hz
%         writeline(sensor.port,'$S0408'); % 10240Hz
%         writeline(sensor.port,'$S0409'); % 11520Hz
%         writeline(sensor.port,'$S040A'); % 12800Hz
        
        % get sampling rate
        if ~isequal(read(sensor.port,4,'uint8'),uint8('@S04'))
            error('protocol error');
        end
        sensor.fs=hex2dec(readline(sensor.port))*1280;
        
        % change of sampling rate becomes effective after reset
        writeline(sensor.port,'$W00');
        if ~isequal(readline(sensor.port),'@W0000')
            error('protocol error');
        end
        
        % wait till sensor is running again
        pause(0.1);
        writeline(sensor.port,'$R04');
        while ~isequal(readline(sensor.port),'@R0402')
            writeline(sensor.port,'$R04');
        end
        
        % check sensor type
        writeline(sensor.port,'$F01');
        if ~isequal(readline(sensor.port),'@F010001')
            error('protocol error');
        end
        
        % show firmaware version
        writeline(sensor.port,'$F00');
        if ~isequal(read(sensor.port,4,'uint8'),uint8('@F00'))
            error('protocol error');
        end
        version=hex2dec(readline(sensor.port));
        fprintf('Version: %d.%d\n',floor(version/100),rem(version,100));

        % set higher baud rate
        writeline(sensor.port,'$W0201');
        if ~isequal(readline(sensor.port),'@W0201')
            error('protocol error');
        end
        pause(0.075); % delay 75ms
        sensor.port.BaudRate=460800;
        
        % save parameters to HDF5 file
        h5create(sensor.file,'/fs',1);
        h5write(sensor.file,'/fs',sensor.fs);
        h5create(sensor.file,'/L',1);
        h5write(sensor.file,'/L',sensor.L);
        
        % data will go here
        h5create(file,'/data',[256*2 Inf],'ChunkSize',[256*2 1]);
        
    case 'st100cw'
        sensor.mode='st100cw';
        sensor.file=file;
        sensor.fs=44100; % sampling rate
        sensor.L=2^12; % samples per frame (RFbeam SignalViewer uses 2^13 samples per frame)
        
        % create data acquisition device
        sensor.device=daq('directsound');
        sensor.device.Rate=sensor.fs;
        addinput(sensor.device,'Audio1',[1 2],'Audio'); % DEPENDING ON YOUR PC YOU MAY HAVE TO SELECT A DEVICEID DIFFERENT FROM 'Audio1'
        disp('connected to ST100');
        
        % save parameters to HDF5 file
        h5create(sensor.file,'/fs',1);
        h5write(sensor.file,'/fs',sensor.fs);
        h5create(sensor.file,'/L',1);
        h5write(sensor.file,'/L',sensor.L);

        % data will go here
        h5create(file,'/data',[sensor.L*2 Inf],'ChunkSize',[sensor.L*2 1]);
        
        % start data acquisition
        start(sensor.device,'Continuous');
        
    case 'st200klccw'
        sensor.mode='st200klccw';
        sensor.file=file;
        sensor.fs=125000; % sampling rate
        sensor.L=2^13; % samples per frame (RFbeam Signal Explorer uses 2^13 samples per frame)

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

        % data will go here
        h5create(file,'/data',[sensor.L*2 Inf],'ChunkSize',[sensor.L*2 1]);

        % start data acquisition
        preload(sensor.device,1*ones(sensor.L*2^7,1)); % constant 1V VCO input
        start(sensor.device,'RepeatOutput');
        
    case 'st200kmccw'        
        sensor.mode='st200kmccw';
        sensor.file=file;
        sensor.fs=125000; % sampling rate
        sensor.L=2^13; % samples per frame (RFbeam Signal Explorer uses 2^13 samples per frame)

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

        % data will go here
        h5create(file,'/data',[sensor.L*2 Inf],'ChunkSize',[sensor.L*2 1]);

        % start data acquisition
        preload(sensor.device,1*ones(sensor.L*2^7,1)); % constant 1V VCO input
        start(sensor.device,'RepeatOutput');

    case 'cwfile'
        sensor.mode='cwfile';
        sensor.file=file;
        
        % load parameters from HDF5 file
        sensor.fs=h5read(file,'/fs');
        sensor.L=h5read(file,'/L');

        disp('read data from file');
        
    otherwise
    	error('unsupported mode');
end

end
