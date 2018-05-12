function pdf2imgs(sourceFolder, destinationFolder, pdf)
% pdf contains .pdf file extension

sourceFolder = strrep(sourceFolder, '\', '/');

command = ['magick -density 300 "', sourceFolder, '/', pdf, '" -quality 100 "', ...
    destinationFolder, '/', pdf(1:end-4), '.jpg"'];

[status, cmdout] = dos(command);
if status ~= 0
    error(cmdout)
end

% TODO: add conversion from color to greyscale

