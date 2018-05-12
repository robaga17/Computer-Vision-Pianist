function [cc, labeled] = extractObjects(img)
% https://www.mathworks.com/help/images/ref/bwboundaries.html
objects = {};

cc = bwconncomp(img);
labeled = labelmatrix(cc);



% stats = regionprops(bwImg, 'BoundingBox' ); 
% for k = 1:length(stats) 
%     bb = stats(k).BoundingBox; S
%     rectangle('Position', [bb(1),bb(2),bb(3),bb(4)], 'EdgeColor','r','LineWidth',2 );
% end

% [B, L] = bwboundaries(bw, 'holes');
% boundingBoxes = zeros(length(B), 4);
% i = 0;
% for k = 1:length(B)
%     boundary = B{k};
%     minRow = min(boundary(:,1));
%     maxRow = max(boundary(:,1));
%     minCol = min(boundary(:,2));
%     maxCol = max(boundary(:,2));
%     if (maxRow - minRow) * (maxCol - minCol) < nr*nc/2
%         i = i + 1;
%         boundingBoxes(i, :) = [minRow, maxRow, minCol, maxCol];
%     end
% end
% 
% boundingBoxes = boundingBoxes(1:i, :);
% [nBBs, ~] = size(boundingBoxes);
% 
% for k = 1:nBBs
%     rectangle('Position', 


