classdef Section < MusicPlayer
    
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
            unitMap = cell(30, nc);
            for i = 1:length(objects)
                object = objects{i};
                if object.isRest()
                    unitMap{30, object.Stats.Centroid(1)} = Unit(15, object.getRestDuration());
                elseif object.isNote()
                    % do kernel stuff, put it in unit map
                    durations = object.getNoteDurations();
                    % TODO: implement half notes and whole notes
                    if ismember(16, durations) || ismember(8, durations)
                        % right now, just turning them into rests
                        unitMap{30, object.Stats.Centroid(2)} = Unit(15, sum(durations));
                    end
                    unitMap = insertNote(unitMap, object, self);
                end
            end
        end
        
        function audio = getAudio(self)
            objects = self.findObjects();
            [~, nc] = size(self.Image);
            trebleNotes = cell(1, nc);
            bassNotes = cell(1, nc);
            middleRow = (self.TrebleRows(5) + self.BassRows(1)) / 2;
            % TODO: clean this logic
            for i = 1:length(objects)
                object = objects{i};
                % TODO: add methods to musical object that determine
                % properties of note
                if length(object.Label) < 2 || ~(strcmp(object.Label(1:2), 'n ') || strcmp(object.Label, 'qrest'))
                    continue
                end
                objectCenterCol = object.BoundingBox(1) + round(object.BoundingBox(3)/2);
                objectCenterRow = object.BoundingBox(2) + round(object.BoundingBox(4)/2);
                if objectCenterRow < middleRow
                    trebleNotes{objectCenterCol} = Note(self, object);
                else
                    bassNotes{objectCenterCol} = Note(self, object);
                end
            end
            for i = 1:length(objects)
                object = objects{i};
                if ~strcmp(object.Label, 'dot')
                    continue
                end
                middleRow = (self.TrebleRows(5) + self.BassRows(1)) / 2;
                objectCenterCol = object.BoundingBox(1) + round(object.BoundingBox(3)/2);
                objectCenterRow = object.BoundingBox(2) + round(object.BoundingBox(4)/2);
                if objectCenterRow < middleRow
                    for j = objectCenterCol-1:-1:objectCenterCol-30
                        if ~isempty(trebleNotes{j})
                            trebleNotes{j}.Dotted = 1;
                            break
                        end
                    end
                else
                    for j = objectCenterCol-1:-1:objectCenterCol-30
                        if ~isempty(bassNotes{j})
                            bassNotes{j}.Dotted = 1;
                            break
                        end
                    end
                end
            end
            audioList = cell(nc, 1);
            k = 0;
            for i = 1:length(self.BarLines)-1
                barLineStart = self.BarLines(i);
                barLineEnd = self.BarLines(i+1);
                trebleAudioList = {};
                bassAudioList = {};
                for j = barLineStart:barLineEnd-1
                    if ~isempty(trebleNotes{j})
                        trebleAudioList{length(trebleAudioList)+1} = trebleNotes{j}.getAudio();
                    end
                    if ~isempty(bassNotes{j})
                        bassAudioList{length(bassAudioList)+1} = bassNotes{j}.getAudio();
                    end
                end
                trebleAudio = concatenateAudio(trebleAudioList);
                bassAudio = concatenateAudio(bassAudioList);
                k = k + 1;
                audioList{k} = mergeAudio(trebleAudio, bassAudio);
            end
            audio = concatenateAudio(audioList);
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
                stats.BoundingBox = bb;
                % create image
                isoObjImg = objImg(bb(2):bb(2)+bb(4), bb(1):bb(1)+bb(3));
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
            % TODO: better removal proccess
            %   Account for curves
            %   Account for the row below
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
            [nr, ~] = size(img);
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
            % TODO: implement removeText()
%             regions = cell(3, 1);
%             offsets = zeros(size(regions));
%             regions{1} = img(1:self.TrebleRows(1), :);
%             offsets(1) = 0;
%             regions{2} = img(self.TrebleRows(5):self.BassRows(1), :);
%             offsets(2) = self.TrebleRows(5) - 1;
%             regions{3} = img(self.BassRows(5):nr, :);
%             offsets(3) = self.BassRows(5) - 1;
%             wordBBs = [];
%             words = {};
%             for i = 1:length(regions)
%                 text = ocr(regions{i});
%                 for j = 1:length(text.Words)
%                     word = text.Words{j};
%                     valid = ((length(word) > 1 && sum(isstrprop(word, 'alphanum'))/length(word) > .5));
%                     valid = valid && text.WordConfidences(j) > .6;
%                     valid = valid || strcmp(word, '@');
%                     valid = valid && ~strcmp(word, 'VI') && ~strcmp(word, 'V1');
%                     if valid
%                         wordBB = text.WordBoundingBoxes(j, :);
%                         wordBB = floor(wordBB);
%                         wordBB(2) = wordBB(2) + offsets(i);
%                         wordBB(3) = wordBB(3) + 1;
%                         wordBB(4) = wordBB(4) + 1;
%                         img(wordBB(2):wordBB(2)+wordBB(4), wordBB(1):wordBB(1)+wordBB(3)) = ...
%                             img(wordBB(2):wordBB(2)+wordBB(4), wordBB(1):wordBB(1)+wordBB(3)) * 0;
%                         wordBBs = [wordBBs; wordBB];
%                         words{length(words)+1} = word;
%                     end
%                 end
%             end
% %             imshow(self.Image);
% %             for i = 1:size(wordBBs, 1)
% %                 bb = wordBBs(i, :);
% %                 r =        ('Position', bb, 'EdgeColor', 'r');
% %                 keyboard;
% %                 delete(r);
% %             end
%             self.Image = img;
%             self.WordBoundingBoxes = wordBBs;
        end
        
    end
end

