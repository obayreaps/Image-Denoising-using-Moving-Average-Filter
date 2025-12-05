%% Image Denoising using Moving Average Filter
%% Implemented by Kevin Le

%Load Image
img = imread('img/coins.jpg'); %Load any image
if size(img,3) == 3           %Checks how many layers in 3rd dimension
    img = rgb2gray(img);      %if colored, then convert it to gray to work on 1 layer
end
img = im2double(img);        %Convert image to double-precision floating-point format
                             %essential for image processing/filtering

%Add Gaussian noise to simulate high-frequency noise
noiseVar = 0.15; 
noisyImg = imnoise(img, 'gaussian', 0, noiseVar);

%Create a 3x3 kernal moving average filter
k = 3;
kernel = ones(k, k) / (k*k);

%Apply 2-D convolution with noisy image and 3x3 kernal filter
filteredImg = conv2(noisyImg, kernel, 'same');

%Display original, noisy, and filtered versions of the image
figure;
subplot(1,3,1);
imshow(img);
title('Original Image');

subplot(1,3,2);
imshow(noisyImg);
title('Noisy Image');

subplot(1,3,3);
imshow(filteredImg);
title('Filtered Image (3x3 MA)');
