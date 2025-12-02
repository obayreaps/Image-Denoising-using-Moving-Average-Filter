function mean_filter_image_demo
% MEAN_FILTER_IMAGE_DEMO
% Read an image, add Gaussian noise, and apply only a moving-average (mean)
% filter. The mean filter is implemented with a normalized 2D box kernel.
%
% Edit kernelSize or noise variance at the top as needed.

% --- Parameters ---
kernelSize = [3 3];       % [rows cols] neighborhood for mean (odd integers recommended)
noiseVar    = 0.2;       % variance for imnoise Gaussian (0..1)

% --- Read image (example builtin coins.jpg if available) ---
I = imread('');  % replace filename if needed

% Convert to grayscale if RGB
if size(I,3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end
Igray = im2double(Igray);

% Add Gaussian noise
noisy = imnoise(Igray, 'gaussian', 0, noiseVar);

% Create normalized box (mean) kernel and apply with conv2 (same size)
h = ones(kernelSize) / prod(kernelSize);
meanFiltered = conv2(noisy, h, 'same');

% Alternative: use imfilter with symmetric padding for better edges
% meanFiltered = imfilter(noisy, h, 'symmetric', 'same');

% Display results
figure('Name','Moving-Average Filter Demo','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(1,3,1); imshow(Igray);       title('Original (grayscale)');
subplot(1,3,2); imshow(noisy);       title(sprintf('Noisy (Gaussian, var=%.3g)', noiseVar));
subplot(1,3,3); imshow(meanFiltered); title(sprintf('Mean Filtered (%dx%d)', kernelSize(1), kernelSize(2)));

end
