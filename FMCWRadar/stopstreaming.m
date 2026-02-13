function stopstreaming(sensor)
%STOPSTREAMING stop data streaming from the radar sensor
%   sensor      radar sensor device

switch sensor.mode
    case {'st200klcfmcw','st200kmcfmcw'}
        % stop data acquisition
        stop(sensor.device);
        
        % remove data acquisition device
        delete(sensor.device);
        
        disp('stopped data streaming');
        
    case {'fmcwfile','convert'}
        disp('stopped reading data');

    otherwise
    	error('unsupported mode');
end

end
