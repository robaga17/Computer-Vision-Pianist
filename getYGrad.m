function yGrad = getYGrad(img)

img = double(img);
kernel = [0, 0, 0; 0, 1, 0; 0, -1, 0];

yGrad = conv2(img, kernel, 'same');