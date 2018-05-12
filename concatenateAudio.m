function concatenatedAudio = concatenateAudio(audioList)
% audioList = cell array of multiple audio arrays
% concatenatedAudio = audioList as one concatenated audio array

% get totalLength (avoid dynamic array resizing)
concatenatedLength = 0;
for i = 1:length(audioList)
    concatenatedLength = concatenatedLength + length(audioList{i});
end

% concatenate
concatenatedAudio = zeros(concatenatedLength, 2);
audioIdx = 1;
for i = 1:length(audioList)
    audioIdxEnd = audioIdx + length(audioList{i}) - 1;
    concatenatedAudio(audioIdx:audioIdxEnd, :) = audioList{i};
    audioIdx = audioIdxEnd + 1;
end

end

