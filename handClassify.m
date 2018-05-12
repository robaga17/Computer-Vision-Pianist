function [] = handClassify()

% pdfs = dir('data/*.pdf');
% for pdf = pdfs'
%     pdf2imgs('data', 'images', pdf.name);
%     delete(['data/', pdf.name]);
% end


jpgs = dir('data/*.jpg');
for jpg = jpgs'
    load model classifier;
    page = Page(['data/', jpg.name]);
    sections = page.getSections();
    hashSet = java.util.HashSet();
    for i = 1:length(sections)
        section = sections{i};
        [nr, nc] = size(section.Image);
        objects = section.findObjects();        
        for j = 1:length(objects)
            object = objects{j};
            bb = object.Stats.BoundingBox;
            isoObjImg = (section.Image(bb(2):bb(2)+bb(4), bb(1):bb(1)+bb(3)));
            paddedObjImg = padarray(isoObjImg, [5, 5], 0, 'both');
            hashVal = hashBW(isoObjImg);
            if hashSet.contains(hashVal)
                continue
            end
            
            % TODO: utilize fact that object will already have been
            % classified
            [predictedLabelIdx, score] = predict(classifier, single(paddedObjImg));
            predictedLabel = classifier.Labels(predictedLabelIdx);
            predictedLabel = predictedLabel{1};
            if exist(['train/', predictedLabel, '/', hashVal, '.jpg'], 'file')
               continue
            end
            r1 = max(1, bb(2)-100);
            r2 = min(nr, bb(2)+bb(4)+100);
            c1 = max(1, bb(1)-100);
            c2 = min(nc, bb(1)+bb(3)+100);
            hold on
            img = imshow(~section.Image(r1:r2, c1:c2));
            bb(1) = min(95, bb(1));
            bb(2) = min(95, bb(2));
            bb(3) = bb(3) + 10;
            bb(4) = bb(4) + 10;
            r = rectangle('Position', bb, 'EdgeColor', 'r');
            fprintf('predicted label: %s\nscore: %.4f\n', predictedLabel, max(score));
            label = input('', 's');
            delete(r); 
            delete(img);
            if strcmp(label, '')
                continue
            end
            if strcmp(label, '''')
               label = predictedLabel;
            end
            folder = ['train/', label];
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            imwrite(paddedObjImg, [folder, '/', hashVal, '.jpg']);
        end
        close all
    end
    delete(['data/', jpg.name]);

end

