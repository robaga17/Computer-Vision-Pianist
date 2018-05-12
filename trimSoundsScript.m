% trim all the sounds in 'raw sounds' folder, 
% and place them in 'sounds' folder

aiffs = dir('raw sounds/*.aiff');
for aiff = aiffs'
    [data, Fs] = audioread(['raw sounds/', aiff.name]);
    writePath = ['sounds/', aiff.name(7:end-4), 'ogg'];
    audiowrite(writePath, trimAudio(data), Fs);
    disp(writePath);
end

function trimmedAudio = trimAudio(audio)
% Removes the silence from the beginning and end of audio
beginningTheshold = .01;
endingTheshold = .001;

[nRows, ~] = size(audio);
for row = 1 : nRows
    if sum(abs(audio(row, :))) > beginningTheshold
        trimmedAudio = audio(row:end, :);
        break;
    end
    if row == nRows
        trimmedAudio = [0, 0];
    end
end

[nRows, ~] = size(trimmedAudio);
for row = nRows : -1 : 1
    if sum(abs(trimmedAudio(row, :))) > endingTheshold
        trimmedAudio = trimmedAudio(1:row, :);
        break;
    end
end
end