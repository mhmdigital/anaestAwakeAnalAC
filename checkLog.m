function pAC = checkLog(pAC,mFileName)
% Checks to see if a log file for the pAC is present and creates one if
% necessary. SYNTAX: Put the CR at the end of the line! (\r\n)
% 2019.10.10
% DUPLICATE: search path for mfile (ONLY other place is in logEntry...) FIX!!!
mFilePath = 'R:\Mike\Scrips\AC\activeFunctions\';

% Check for presence of log FILE
logFile = [pAC.fileStem 'LOG.txt']; % Expected filename
doLog = 0; % Flag for whether making the log is necessary
newFile = 0; % Flag for creating new file
if exist([pAC.fullPath logFile],'file')
    % Is there NOT an entry in the pAC? (I it's there, you're all good. Nothing left to do!
    if ~isfield(pAC,'logName')
        % Then something went wrong. Ask to import the previous log file. 
        Answer = questdlg({'No log file entry, but log file found. Apply?'; ...
            ''; 'WARNING: Applying will append the existing file'; ...
            'Replacing will overwrite the existing file (not reversible!)'}, ...
            'File system ambiguity', 'Append', 'Replace', 'Append');
        if strcmp(Answer,'Append')
            % If appending, read the old text and log that it's being taken
            % over! 
            oldText = fileread([pAC.fullPath logFile]);
            Remark = sprintf('"WARNING: Log file overtaken. Check for corrupted files!"\r\n');
            doLog = 1;
        else
            doLog = 1;
            newFile = 1; 
        end
    end
else % No file? create one!
    newFile = 1;
    doLog = 1;
end

pAC.logName = logFile; % Set the field in the pAC
Event = '"Log event"'; % Set the log event
% Is a new file necessary? (Either replacing existing one, or doesn't exist at all)
if newFile == 1
    oldText = sprintf(''); % Empty old text (probably not necessary)
    Remark = sprintf('"Log file created"');
end

% Action on the log necessary? 
if doLog == 1
    % Make new entry (you can't append to the beginning of a file, so the old
    % one has to be loaded, manually appended and then resaved)
    % Set the default header
    defHeader = setDefaultLogHeader(mFileName);
    % NEW TEXT: Event, Remarks, Reference
    newText = [defHeader Event sprintf('\t') Remark sprintf('\t') logFile sprintf('\r\n') oldText]; % Don't forget to close the line!

    % Overwrite the log file
    fid = fopen([pAC.fullPath pAC.logName],'w');
    fprintf(fid,newText);
    fclose(fid);

    % save the pAC (no Reference!)
    pAC = savePAC(pAC, mfilename, Event, '"Log file link in pAC established"');

    % Print the result (note that no \n here since it's already in the remark!)
    fprintf('Log for %s updated: \n  %s',pAC.repName, [defHeader Remark])
end
