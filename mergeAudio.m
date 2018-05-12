function mergedAudio = mergeAudio(audio1,audio2)
% Merges audio1 and audio2

% TODO: allow overlapping merge for more continuity

[nRows1, ~] = size(audio1);
[nRows2, ~] = size(audio2);

padding = abs(nRows1 - nRows2);

if nRows1 < nRows2
    audio1 = [audio1; zeros(padding, 2)];
elseif nRows1 > nRows2
    audio2 = [audio2; zeros(padding, 2)];
end

mergedAudio = audio1 + audio2;

end

