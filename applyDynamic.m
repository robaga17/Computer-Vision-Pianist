function unitMap = applyDynamic(unitMap, object)
% object.isDynamic must be true
% applies the dynamic to the appropirate units in unitMap

dynamic = object.Label;
colStart = object.Stats.Centroid(1);
for col = colStart:length(unitMap{1})
    for p = 1:30
        if ~isempty(unitMap{1}{p, col})
            unitMap{1}{p, col}.Dynamic = dynamic;
        end
        if ~isempty(unitMap{2}{p, col})
            unitMap{2}{p, col}.Dynamic = dynamic;
        end
    end
end

end