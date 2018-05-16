function tempo = tempoMatcher(words)
% Tries to find the best matching tempo term in words
% Returns corresponding bpm
% If no match is good enough, returns 100

tempo = 100; % default

terms = {'largo', 'adagio', 'andante', 'moderato', 'allegro'};
tempos = [50, 71, 90, 114, 140];

minDist = inf;
minIdx = 1;
for i = 1:length(terms)
    for j = 1:length(words)
        if length(words{j}) < 4
            continue
        end
        levDist = levDistance(terms{i}, words{j});
        if levDist < minDist
            minDist = levDist;
            minIdx = i;
        end
    end
end

if minDist <= 2
    tempo = tempos(minIdx);
end

end

