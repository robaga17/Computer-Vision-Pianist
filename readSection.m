function sectionAudio = readSection(section ,trebleRows, bassRows, state)
outline = [];

% todo: remove measure lines, change removeLines, feed downwards on last
% line

[nr, nc] = size(section);

[cc, labeled] = extractObjects(section);
imshow(section);

for i = 1:cc.NumObjects
    untrimmedObject = labeled == i;
    object = untrimmedObject;
    object(~any(object,2), :) = [];
    object(:, ~any(object,1)) = [];
    object = padarray(object, [1,1], 0, 'both');

    if isMusicalObject(object)
        type = identifyMusicalObject(object);
        outline.update(type, object, untrimmedObject);
    end
end
    
sectionAudio = outline.compile();

% figure
% imshow(section)
% hold all
% for i = 1:length(trebleRows)
%     line([1, nc], [trebleRows(i), trebleRows(i)]);
% end
% for i = 1:length(bassRows)
%     line([1, nc], [bassRows(i), bassRows(i)]);
% end

end

