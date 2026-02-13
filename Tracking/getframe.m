function df=getframe(sensor)
%GETFRAME get next frame from the radar sensor
% performs FMCW radar measurements
%   df          detected frequency shifts in
%               down-chirp and up-chirp
%   sensor      radar sensor device

persistent dataset

if isempty(dataset)
    dataset=1; % reset dataset counter
end

switch sensor.mode
    case 'dffile'
        drawnow; % update figures
        info=h5info(sensor.file,'/df');
        if dataset<=info.Dataspace.Size(2)
            % load data from HDF5 file
            df=h5read(sensor.file,'/df',[1 dataset],[2 1]);
            dataset=dataset+1;
        else
            df=[]; % reached end of file
        end
        
    otherwise
    	error('unsupported mode');
end

end
