function visualizeUnitMap(unitMap)
figure
hold on
[nr, nc] = size(unitMap);
count = 0;
for r = 1:nr
    for c = 1:nc
        if isempty(unitMap{r, c})
            continue
        end
        unit = unitMap{r, c};
        if unit.N16ths == 1
            color = 'r*';
        elseif unit.N16ths == 2
            color = 'm*';
        elseif unit.N16ths == 4
            color = 'c*';
        elseif unit.N16ths == 8
            color = 'g*';
        elseif unit.N16ths == 16
            color = 'k*';
        end
        plot(c, r, color);
        count = count + 1;
    end
end
disp(count);
end

