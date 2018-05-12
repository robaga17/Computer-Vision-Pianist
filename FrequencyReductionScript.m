oggs = dir('pitches/*.ogg');
for ogg = oggs'
    [y, f] = audioread(['pitches/', ogg.name]);
    y2 = y(1:4:end, :);
    endIdx = min([length(y2), 56000]);
    y2 = y2(1:endIdx, :);
    f2 = f / 4;
    audiowrite(['pitches2/', ogg.name], y2, f2);
end