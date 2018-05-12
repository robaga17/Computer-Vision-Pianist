function baseName = getBaseName(filePath)
% filePath = some file path ('.../folder/folder/something.ext')
% baseName = base name of the file ('something')
filePathChunks = strsplit(filePath, '/');
fileName = filePathChunks{length(filePathChunks)};
fileNameChunks = strsplit(fileName, '.');
extension = fileNameChunks{length(fileNameChunks)};
baseName = fileName(1:end-length(extension)-1);
end

