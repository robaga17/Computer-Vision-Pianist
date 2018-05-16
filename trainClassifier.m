function [classifier, imds] = trainClassifier()
% Trains a classifier based on the image data in train folder
% Saves classifier to newestModel.mat
% You must manually save the classifier to model.mat (this is what the
% program uses)

imds = imageDatastore('train', 'IncludeSubfolders', true, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
bag = bagOfFeatures(imds, 'Verbose', false);
classifier = trainImageCategoryClassifier(imds, bag, 'Verbose', false);

save newestModel.mat classifier;

end

