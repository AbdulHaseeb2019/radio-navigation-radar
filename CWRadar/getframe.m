function radc=getframe(sensor)
%GETFRAME get next frame from the radar sensor
% performs CW radar measurements
%   radc        data vector with complex raw adc values
%   sensor      radar sensor device

persistent dataset

if isempty(dataset)
    dataset=1; % reset dataset counter
end

switch sensor.mode
    case 'kld2cw'
        % update figures
        drawnow; 

        % request next frame data
        writeline(sensor.port,'$C04');
        
        % read ADC I data
        iadc=read(sensor.port,256,'int16');
        
        % read ADC Q data
        qadc=read(sensor.port,256,'int16');
        
        % complex radc data
        radc=iadc+j*qadc;
        
        % discard FFT spectrum
        read(sensor.port,256,'uint16');
        
        % discard threshold level
        read(sensor.port,256,'uint16');

        % save data to HDF5 file
        info=h5info(sensor.file,'/data');
        h5write(sensor.file,'/data',cat(1,iadc(:),qadc(:)),[1 info.Dataspace.Size(2)+1],[256*2 1]);
        
    case {'st100cw','st200klccw','st200kmccw'}
        % perform measurement
        while sensor.device.NumScansAvailable<sensor.L
            % wait till enough data is available, blocking of read does not work reliably
            drawnow; % update figures
        end
        data=read(sensor.device,sensor.L,'OutputFormat','Matrix');
        radc=data(:,1)+j*data(:,2);
        
        % save data to HDF5 file
        info=h5info(sensor.file,'/data');
        h5write(sensor.file,'/data',data(:),[1 info.Dataspace.Size(2)+1],[sensor.L*2 1]);
        
    case 'cwfile'
        drawnow; % update figures
        info=h5info(sensor.file,'/data');
        if dataset<=info.Dataspace.Size(2)
            % load data from HDF5 file
            data=h5read(sensor.file,'/data',[1 dataset],[sensor.L*2 1]);
            radc=data(1:sensor.L)+j*data(sensor.L+1:end);
            dataset=dataset+1;
        else
            radc=[]; % reached end of file
        end
        
    otherwise
    	error('unsupported mode');
end

end
