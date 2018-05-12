function unitMap = insertNote(unitMap, tb, object, section)
halfSpace = (section.TrebleRows(2) - section.TrebleRows(1))/2;
if tb == 1
    midCRow = section.TrebleRows(5) + halfSpace*2;
else
    midCRow = section.BassRows(1) - halfSpace*2;
end

img = section.Labeled == object.LabelTag;
[nr, nc] = size(img);

% get kernel type
% note: all kernels were taken from images with halfSpace*2 = 15
if strcmp(object.Label, 'n w')
    kernelPath = 'kernels/wholeNote.jpg';
elseif strcmp(object.Label, 'n h')
    kernelPath = 'kernels/halfNote.jpg';
else
    kernelPath = 'kernels/filledNote.jpg';
end

kernel = imread(kernelPath);
if size(kernel, 3) == 3
    kernel = rgb2gray(kernel);
end

kernel = imbinarize(kernel);
kernelVolume = sum(sum(kernel));

pitchPlot = conv2(img, kernel, 'same');
if strcmp(kernelPath, 'kernels/filledNote.jpg')
    pitchPlot = pitchPlot >= kernelVolume * 0.90;
else
    pitchPlot = pitchPlot >= kernelVolume * 0.60;
end

cc = bwconncomp(pitchPlot);
if cc.NumObjects == 0
    return
end
labeled = labelmatrix(cc);

centroids = {};
for i = 1:cc.NumObjects
    noteSpace = labeled == i;
    stats = regionprops(noteSpace);
    centroids{length(centroids)+1} = round(stats.Centroid);
end

pitches = [];
centroidCols = [];
for i = 1:length(centroids)
    centroidCols(i) = centroids{i}(1);
    actualRow = centroids{i}(2);
    offset = round((midCRow - actualRow)/halfSpace);
    if offset > 14 || offset < -14
        pitches(end+1) = 30;
    else
        pitches(end+1) = offset + 15;
    end
end

[~, idxs] = sort(centroidCols);
durations = object.getNoteDurations();
group = [];

for i = 1:length(idxs)
    idx = idxs(i);
    centroid = centroids{idx};
    if isempty(durations)
        continue
    elseif isempty(group) || abs(centroidCols(group(1))-centroidCols(idx)) < 5
        group(end+1) = idx;
    else
        duration = durations(1);
        durations = durations(2:end);
        for j = 1:length(group)
            unit = Unit(pitches(group(j)), duration);
            unitMap{tb}{pitches(group(j)), centroidCols(group(1))} = unit;
        end
        group = idx;
    end
end
if ~isempty(group) && ~isempty(durations)
    duration = durations(1);
    for j = 1:length(group)
        unit = Unit(pitches(group(j)), duration);
        unitMap{tb}{pitches(group(j)), centroidCols(group(j))} = unit;
    end
end


end

