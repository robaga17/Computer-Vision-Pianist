classdef Section < handle
    % represents one treble staff, bass staff region
    
    properties
        Image
        TrebleRows
        BassRows
        BarLines
        CC
        Labeled
    end
    
    methods
        function section = Section(img, trebleRows, bassRows)
            section.Image = img;
            section.TrebleRows = trebleRows;
            section.BassRows = bassRows;
            barCols = section.getBarCols();
            section.removeBarLines(barCols);
            section.removeText();
            section.CC = bwconncomp(section.Image);
            section.Labeled = labelmatrix(section.CC);
        end
        
        function show(self)
            imshow(self.Image);
        end
        
        function unitMap = getUnitMap(self)
            objects = self.findObjects();
            [~, nc] = size(self.Image);
            trebleMap = cell(30, nc);
            bassMap = cell(30, nc);
            unitMap = {trebleMap, bassMap};
            % add notes
            for i = 1:length(objects)
                object = objects{i};
                % determine if object is in treble (1) or bass (2)
                tb = self.trebleOrBass(object);
                if object.isRest()
                    rowPos = object.Stats.Centroid(2);
                    if tb == 1 && (rowPos < self.TrebleRows(2) || rowPos > self.TrebleRows(4))
                        continue
                    elseif tb == 2 && (rowPos < self.BassRows(2) || rowPos > self.BassRows(4))
                        continue
                    end
                    unitMap{tb}{30, object.Stats.Centroid(1)} = Unit(30, object.getRestDuration());
                elseif object.isNote()
                    % put it in unit map
                    unitMap = insertNote(unitMap, tb, object, self);
                end
            end
            % add modifications
            for i = 1:length(objects)
                object = objects{i};
                tb = self.trebleOrBass(object);
                if strcmp(object.Label, 'dot')
                    unitMap = applyDot(unitMap, tb, object, self);
                elseif object.isAccidental()
                    unitMap = applyAccidental(unitMap, tb, object, self);
                elseif strcmp(object.Label, 'accent')
                    unitMap = applyAccent(unitMap, tb, object, self);
                elseif object.isDynamic()
                    unitMap = applyDynamic(unitMap, object);
                end
            end
        end
        
        function tb = trebleOrBass(self, object)
            % returns 1 if object in treble, 2 if bass
            trebleDist = abs(self.TrebleRows(1) - object.Stats.Centroid(2));
            bassDist = abs(self.BassRows(5) - object.Stats.Centroid(2));
            if trebleDist < bassDist
                tb = 1;
            else
                tb = 2;
            end
        end
        
        function objects = findObjects(self)
            cc = self.CC;
            labeled = self.Labeled;
            objects = {};
            load model classifier
            for labelTag = 1:cc.NumObjects
                % isolate object
                objImg = labeled == labelTag;
                stats = regionprops(objImg);
                stats.Centroid = round(stats.Centroid);

                if stats.Area < 4
                    % remove object from labeled
                    labeled = double(labeled) .* ~(double(objImg));
                    labeled = uint8(labeled);
                    continue
                end

                % create bounding box
                bb = stats.BoundingBox;
                bb = floor(bb);
                bb(3) = bb(3) + 1;
                bb(4) = bb(4) + 1;
                bb(1) = max(1, bb(1));
                bb(2) = max(1, bb(2));
                stats.BoundingBox = bb;
                % create image
                try
                    isoObjImg = objImg(bb(2):bb(2)+bb(4)-1, bb(1):bb(1)+bb(3)-1);
                catch
                    keyboard
                end
                isoObjImg = padarray(isoObjImg, [5, 5], 0, 'both');
                % create label
                [labelIdx, ~] = predict(classifier, single(isoObjImg));
                label = classifier.Labels(labelIdx);
                label = label{1};
                % turn lrest into hrest or wrest
                if strcmp('lrest', label)
                    trebleDist = abs(stats.Centroid(2) - self.TrebleRows(1));
                    bassDist = abs(stats.Centroid(2) - self.BassRows(5));
                    if trebleDist < bassDist
                        rows = self.TrebleRows;
                    else
                        rows = self.BassRows;
                    end
                    if abs(stats.Centroid(2) - rows(2)) < abs(stats.Centroid(2) - rows(3))
                        label = 'wrest';
                    else
                        label = 'hrest';
                    end
                end
                % create object
                objects{length(objects)+1} = MusicalObject(labelTag, stats, label);
            end
        end

        function barCols = getBarCols(self)
            % staffRows = all rows that contain a staff line
            % a single staff line can be spread over multiple rows
            img = self.Image;
            [~, nc] = size(img);
            % make 0=black and 1=white to make logic easier
            img = ~img;

            colSums = sum(img(self.TrebleRows(1)+2:self.BassRows(5)-1,:), 1);
            
            % collect all cols that are below the threshold
            THRESHOLD = 5;
            barCols = zeros(nc, 1);
            i = 0;
            for j = 1:nc
                if colSums(j) < THRESHOLD
                    i = i + 1;
                    barCols(i) = j;
                end
            end
            barCols = barCols(1:i);
            
            if isempty(barCols)
                error('staffRows is empty');
            end
        end
        
        function [img, barLines] = removeBarLines(self, barCols)
            % to remove staff lines, for each staffRow copy the row above
            img = self.Image;
            
            for i = 1:length(barCols)
                barCol = barCols(i);
                img(:, barCol) = img(:, barCol-1);
            end

            % to get staffLines, get median of each group of staffRows
            barLines = zeros(length(barCols), 1);
            i = 1;
            j = 1;
            while j <= length(barCols)
                k = 1;
                % find grouping
                while j+k <= length(barCols) && barCols(j+k) == barCols(j)+k
                    k = k + 1;
                end
                % get median of grouping
                barLines(i) = barCols(floor((2*j+k-1)/2));
                i = i + 1;
                j = j + k;
            end
            barLines = barLines(1:i-1);
            self.Image = img;
            self.BarLines = barLines;
        end
        
        function removeText(self)
            img = self.Image;
            [nr, nc] = size(img);
      
            topBound = self.TrebleRows(1);
            while topBound > 1 && any(img(topBound, :))
                topBound = topBound - 1;
            end
            bottomBound = self.BassRows(5);
            while bottomBound < nr && any(img(bottomBound, :))
                bottomBound = bottomBound + 1;
            end
            self.TrebleRows = self.TrebleRows - topBound + 1;
            self.BassRows = self.BassRows - topBound + 1;
            self.Image = img(topBound:bottomBound, :);
        end
        
    end
end

