function [classifier, imds] = trainClassifier()

imds = imageDatastore('train', 'IncludeSubfolders', true, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
bag = bagOfFeatures(imds, 'Verbose', false);
classifier = trainImageCategoryClassifier(imds, bag, 'Verbose', false);

save newestModel.mat classifier;

end

