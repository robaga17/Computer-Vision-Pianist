function unitMap = insertNote(unitMap, object, section)
trebleRows = section.TrebleRows;
bassRows = section.BassRows;
halfSpace = (trebleRows(2) - trebleRows(1))/2;
trebleMidCRow = trebleRows(5) + halfSpace*2;
bassMidCRow = bassRows(1) - halfSpace*2;

img = section.Labeled == object.LabelTag;
[nr, nc] = size(img);

kernel = imread('kernels/filledNote.jpg');
if size(kernel, 3) == 3
    kernel = rgb2gray(kernel);
end
kernel = imbinarize(kernel);
kernelVolume = sum(sum(kernel));
[kr, kc] = size(kernel);

pitchPlot = conv2(img, kernel, 'same');
pitchPlot = pitchPlot == sum(sum(kernel));
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
    trebleOffset = round((actualRow - trebleMidCRow)/halfSpace);
    bassOffset = round((actualRow - bassMidCRow)/halfSpace);
    if abs(trebleOffset) < abs(bassOffset)
        % in treble cleff
        pitches(length(pitches)+1) = trebleOffset;
    else
        % in bass cleff
        pitches(length(pitches)+1) = bassOffset;
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
            unitMap{pitches(group(j))+15, centroidCols(group(1))} = unit;
        end
        group = idx;
    end
end
if ~isempty(group) && ~isempty(durations)
    duration = durations(1);
    for j = 1:length(group)
        unit = Unit(pitches(group(j)), duration);
        unitMap{pitches(group(j))+15, centroidCols(group(j))} = unit;
    end
end

end

