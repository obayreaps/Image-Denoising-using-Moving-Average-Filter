function discrete_conv_fixedY_demo_masked
% DISCRETE_CONV_FIXEDY_DEMO_MASKED
% Interactive demo:
% 1) x[n] (finite)
% 2) h[n] (shiftable via slider)
% 3) y[n] = conv(x, h_shifted) (updates with slider) — plotted in yellow
%    indices with no overlap (product always zero) are explicitly zeroed via a mask
% 4) Y[n] = conv(x, h) (fixed, computed once)
%
% Edit x and h at the top to test different signals.

% --- User signals (edit as needed) ---
x = double([0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0]); % finite x, length Nx
h = [0.5 1 0.5];                                % finite h, length L

Nx = numel(x);
L = numel(h);

% Precompute fixed full convolution Y (unchanging)
Y = conv(x, h);                % length Ny_fixed = Nx + L - 1
Ny = numel(Y);
nY = 0:(Ny-1);

% Initial shift
k0 = 0;

% Build initial shifted h (zero-padded into Ny window) and initial y
h_shifted = shift_h_into_window(h, k0, Ny);
y = conv_with_masked_overlap(x, h_shifted, Ny);

% --- Create figure and 4 subplots ---
f = figure('Name','Discrete Convolution — fixed Y[n] (masked)','Units','normalized','Position',[0.15 0.15 0.7 0.7]);

subplot(4,1,1);
st1 = stem(0:(Nx-1), x, 'filled', 'Color', [0 0.4470 0.7410]);
title('x[n]'); xlabel('n');

subplot(4,1,2);
st2 = stem(0:(Ny-1), h_shifted, 'filled', 'Color', [0.8500 0.3250 0.0980]);
st2.MarkerFaceColor = [0.8500 0.3250 0.0980];
title('h[n] (shiftable)'); xlabel('n');

subplot(4,1,3);
st3 = stem(nY, y, 'filled', 'Color', [1 1 0]);    % yellow
st3.MarkerFaceColor = [1 1 0];
title('y[n] = conv(x, h_{shifted}) (changes with slider)'); xlabel('n');

subplot(4,1,4);
st4 = stem(nY, Y, 'filled', 'Color', [0.4660 0.6740 0.1880]);
st4.MarkerFaceColor = [0.4660 0.6740 0.1880];
title('Y[n] = conv(x, h) (fixed)'); xlabel('n');

% --- Slider UI (integer shift) ---
uicontrol('Style','text','Units','normalized','Position',[0.22 0.01 0.2 0.04],...
    'String','Shift k (samples)','FontWeight','bold','BackgroundColor',get(f,'Color'));
sld = uicontrol('Style','slider','Units','normalized','Position',[0.45 0.01 0.45 0.05],...
    'Min',-Nx,'Max',Nx,'Value',k0,'SliderStep',[1/(2*(Nx+L)) 5/(2*(Nx+L))],...
    'Callback',@(src,~) sliderCallback(round(src.Value)));
txt = uicontrol('Style','text','Units','normalized','Position',[0.02 0.01 0.18 0.04],...
    'String',['k = ' num2str(k0)],'BackgroundColor',get(f,'Color'));
addlistener(sld,'ContinuousValueChange',@(src,evt) set(src,'Value',round(src.Value)));

    function sliderCallback(k)
        k = round(k);
        set(txt,'String',['k = ' num2str(k)]);
        h_shifted = shift_h_into_window(h, k, Ny);
        set(st2,'YData', h_shifted);
        y = conv_with_masked_overlap(x, h_shifted, Ny);
        set(st3,'YData', y);
        drawnow;
    end

end

% --- helper: place h into length-M window with integer shift k (1-based indices) ---
function hs = shift_h_into_window(hvec, k, M)
    Lh = numel(hvec);
    hs = zeros(1, M);
    startIdx = 1 + k;                 % desired start index (may be <1 or >M)
    endIdx = startIdx + Lh - 1;
    % Clip indices to window [1..M] and corresponding h indices
    wStart = max(1, startIdx);
    wEnd   = min(M, endIdx);
    if wStart <= wEnd
        hStart = 1 + (wStart - startIdx);
        hEnd   = hStart + (wEnd - wStart);
        hs(wStart:wEnd) = hvec(hStart:hEnd);
    end
end

% --- helper: convolve x with contiguous nonzero portion of h_shifted,
%     enforce zeros where there is no overlap via mask, then pad/truncate to M_out (Ny)
function y_out = conv_with_masked_overlap(xvec, h_window, M_out)
    nz = find(h_window ~= 0);
    if isempty(nz)
        y_out = zeros(1, M_out);
        return;
    end
    h_eff = h_window(min(nz):max(nz));
    y_tmp = conv(xvec, h_eff);              % length = Nx + length(h_eff) - 1

    % Build overlap mask: convolution of nonzero indicators
    mask_tmp = conv(double(xvec ~= 0), double(h_eff ~= 0));  % same length as y_tmp
    % Force to zero where there is no overlap (mask == 0)
    y_tmp(mask_tmp == 0) = 0;

    % Pad or truncate to M_out
    if numel(y_tmp) < M_out
        y_out = [y_tmp zeros(1, M_out - numel(y_tmp))];
    else
        y_out = y_tmp(1:M_out);
    end
end
