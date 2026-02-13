function radc=getframe(sensor)
%GETFRAME get next frame from the radar sensor
% performs FMCW radar measurements
%   radc        data vector with complex raw adc values,
%               first column down-chirp,
%               second column up-chirp
%   sensor      radar sensor device

persistent dataset

if isempty(dataset)
    dataset=1; % reset dataset counter
end

switch sensor.mode
    case {'st200klcfmcw','st200kmcfmcw'}
        % perform measurement
        while sensor.device.NumScansAvailable<sensor.L*2
            % wait till enough data is available, blocking of read does not work reliably
            drawnow; % update figures
        end
        data=read(sensor.device,sensor.L*2,'OutputFormat','Matrix');
        radc(:,1)=data(1:sensor.L,1)+j*data(1:sensor.L,2);
        radc(:,2)=data(sensor.L+1:end,1)+j*data(sensor.L+1:end,2);

        % save data to HDF5 file
        info=h5info(sensor.file,'/data');
        h5write(sensor.file,'/data',data(:),[1 info.Dataspace.Size(2)+1],[sensor.L*4 1]);
        
    case {'fmcwfile','convert'}
        drawnow; % update figures
        info=h5info(sensor.file,'/data');
        if dataset<=info.Dataspace.Size(2)
            % load data from HDF5 file
            data=h5read(sensor.file,'/data',[1 dataset],[sensor.L*4 1]);
            radc(:,1)=data(1:sensor.L)+j*data(sensor.L*2+1:sensor.L*3);
            radc(:,2)=data(sensor.L+1:sensor.L*2)+j*data(sensor.L*3+1:sensor.L*4);
            dataset=dataset+1;
        else
            radc=[]; % reached end of file
        end
        
    otherwise
    	error('unsupported mode');
end

end
