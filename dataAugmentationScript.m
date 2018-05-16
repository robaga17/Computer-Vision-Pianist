% Rotates and/or flips training data
% The script is idempotent (training data won't be flooded with duplicates)
%     since images are named via hashBW()

labelsToRotate = {'lrest', 'n ee', 'n eeee', 'n h', 'n q', 'n w', 'natural', 'sharp'};
labelsToFlipX = {'bracket', 'lrest', 'n w'};
labelsToFlipY = {'lrest', 'n w'};

for i = 1:length(labelsToRotate)
    label = labelsToRotate{i};
    jpgs = dir(['train/', label, '/*.jpg']);
    for jpg = jpgs'
        img = imbinarize(imread(['train/', label, '/', jpg.name]));
        img2 = imrotate(img,180);
        imwrite(img2, ['train/', label, '/', hashBW(img2), '.jpg']);
    end
end

for i = 1:length(labelsToFlipX)
    label = labelsToFlipX{i};
    jpgs = dir(['train/', label, '/*.jpg']);
    for jpg = jpgs'
        img = imbinarize(imread(['train/', label, '/', jpg.name]));
        img2 = flip(img ,1);
        imwrite(img2, ['train/', label, '/', hashBW(img2), '.jpg']);
    end
end

for i = 1:length(labelsToFlipY)
    label = labelsToFlipY{i};
    jpgs = dir(['train/', label, '/*.jpg']);
    for jpg = jpgs'
        img = imbinarize(imread(['train/', label, '/', jpg.name]));
        img2 = flip(img ,2);
        imwrite(img2, ['train/', label, '/', hashBW(img2), '.jpg']);
    end
end