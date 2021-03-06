function [xoffSet, yoffSet, dispx,dispy,x, y] = meas_disp(template,rect, img, xtemp, ytemp, max_displacement, resolution)
%MEAS_DISPLACEMENT_GPU_ARRAY Summary of this function goes here
%   Detailed explanation goes here
% disp('PRE-INITIALIZATION');
% tic;
% global vid_height;
% global vid_width;
% vid_height = 1024;
% vid_width = 1280;
% Xm =40*10^(-6); %distance according to chip dimensions in microns
% Xp = 184.67662; %distance according image in pixels. Correspond to Xm
%%    ************************** WHOLE PIXEL PRECISION COORDINATES *************************

    MIN_DISPLACEMENT = 2;

    %DEFINE SEARCH AREA - obtained from no interpolated image
    width = max_displacement; 
    height = max_displacement;

    search_area_xmin = rect(1) - width;
    search_area_ymin = rect(2)- height;
    search_area_width = 2*width+rect(3);
    search_area_height = 2*height+rect(4);
    [search_area, search_area_rect] = imcrop(img,[search_area_xmin search_area_ymin search_area_width search_area_height]); 
%     disp(toc);

    %PERFORM NORMALIZED CROSS-CORRELATION
    %Note: Jessica tried to perform Gradient Descent NCC Surface but
    %the timing was problematic.  The NCC Surface algorithm only
    %accepted entire images, and was subsequently too slow.
    c = normxcorr2(template, search_area);

    %FIND PEAK CROSS-CORRELATION
    [ypeak, xpeak] = find(c==max(c(:)));   
    xpeak = gather(xpeak+round(search_area_rect(1))-1);
    ypeak = gather(ypeak+round(search_area_rect(2))-1);

    new_xmin = (xpeak - rect(3));
    new_ymin = (ypeak - rect(4));
    
%     [moved_template, displaced_rect] = imcrop(img, [new_xmin new_ymin rect(3) rect(4)]);
%     new_search_area_xmin = displaced_rect(1) - MIN_DISPLACEMENT;
%     new_search_area_ymin = displaced_rect(2) - MIN_DISPLACEMENT;
%     new_search_area_width = 2*MIN_DISPLACEMENT+displaced_rect(3);
%     new_search_area_height = 2*MIN_DISPLACEMENT+displaced_rect(4);
%     [new_search_area, new_search_area_rect] = imcrop(img, [new_search_area_xmin new_search_area_ymin new_search_area_width new_search_area_height]);
%     
%     new_xpeak = xpeak + round(new_search_area_rect(1));
%     new_ypeak = ypeak + round(new_search_area_rect(2));
    
    yoffSet = new_ymin;
    xoffSet = new_xmin;
    
    %DISPLACEMENT IN PIXELS
    y = ypeak - ytemp;
    x = xpeak - xtemp;
    
    %DISPLACEMENT In meters
%     dispx = Xm*x/Xp;
%     dispy = Xm*y/Xp;
    %resolution's units are m/pixel
    dispx = x * resolution;
    dispy = y * resolution;
end
