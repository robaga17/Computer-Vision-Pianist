function pdf2imgs(sourceFolder, destinationFolder, pdf)
% converts pdf to jpgs
% images will be stored in images folder
% pdf contains .pdf file extension
% imagemagick must be installed https://www.imagemagick.org/script/download.php

sourceFolder = strrep(sourceFolder, '\', '/');

command = ['magick -density 300 "', sourceFolder, '/', pdf, '" -quality 100 "', ...
    destinationFolder, '/', pdf(1:end-4), '.jpg"'];

[status, cmdout] = dos(command);
if status ~= 0
    error(cmdout)
end

