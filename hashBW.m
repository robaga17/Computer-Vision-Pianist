function hashVal = hashBW(bw)
% Returns a string hash of bw
% bw is a binary image

import java.security.*;
import java.math.*;

if ~islogical(bw)
    bw = imbinarize(bw);
end
[nr, nc] = size(bw);
s = blanks(nr*nc);
i = 0;
for r = 1:nr
    h = binaryVectorToHex(bw(r, :));
    i = i + 1;
    s(i:i+length(h)-1) = h;
    i = i + length(h) - 1;
end
s = s(1:i);
hasher = MessageDigest.getInstance('SHA1');
hashVal = hasher.digest(double(s));
bigInt = BigInteger(1, hashVal);
hashVal = char(bigInt.toString(16));
if length(hashVal) > 10
    hashVal = hashVal(1:10);
end
end

