function xGrad = getXGrad(img)

img = double(img);
kernel = [0, 0, 0; 0, 1, -1; 0, 0, 0];

xGrad = conv2(img, kernel, 'same');