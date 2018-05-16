% This script was used to shorten the pitches recieved from http://theremin.music.uiowa.edu/MISpiano.html
% i.e. reduce the audio quality to improve space efficiency and runtime

oggs = dir('pitchesLong/*.ogg');
for ogg = oggs'
    [y, f] = audioread(['pitchesLong/', ogg.name]);
    for i = 1:4:length(y)
        y(i) = (y(i) + y(i+1) + y(i+2) + y(i+3)) / 4;
    end
    y2 = y(1:4:end, :);
    endIdx = min([length(y2), 56000]);
    y2 = y2(1:endIdx, :);
    f2 = f / 4;
    audiowrite(['pitches/', ogg.name], y2, f2);
end