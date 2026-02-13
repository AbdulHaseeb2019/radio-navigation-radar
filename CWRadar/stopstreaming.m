function stopstreaming(sensor)
%STOPSTREAMING stop data streaming from the radar sensor
%   sensor      radar sensor device

switch sensor.mode
    case 'kld2cw'        
        % set lower baud rate
        writeline(sensor.port,'$W0200');
        if ~isequal(readline(sensor.port),'@W0200')
            error('protocol error');
        end
        pause(0.075); % delay 75ms
        sensor.port.BaudRate=38400;

        % close serial connection
        delete(sensor.port);
        
        disp('stopped data streaming');
        
    case {'st100cw','st200klccw','st200kmccw'}
        % stop data acquisition
        stop(sensor.device);
        
        % remove data acquisition device
        delete(sensor.device);
        
        disp('stopped data streaming');
        
    case 'cwfile'
        disp('stopped reading data');

    otherwise
    	error('unsupported mode');
end

end
