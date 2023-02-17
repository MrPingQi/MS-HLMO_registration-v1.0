%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: 384118576@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [I1_s,I1,r1,I2_s,I2,r2] = Preproscessing(image_1,image_2,radius)

%% Data fitting and normalization for image1
I_o = double(image_1);
if size(image_1,3)==1
    I1_s = I_o;
    I1 = I1_s;
elseif size(image_1,3)==3
    I1_s = I_o;
    I1 = ((I_o(:,:,1).^2.2+(1.5*I_o(:,:,2)).^2.2+(0.6*I_o(:,:,3)).^2.2)/(1+1.5^2.2+1.6^2.2)).^(1/2.2);
else
    I1_s = sum(I_o,3);
    I1 = I1_s;
end
I1_s = Visual(I1_s);
I1 = Visual(I1);

%% Data fitting and normalization for image2
I_o = double(image_2);
if size(image_2,3)==1
    I2_s = I_o;
    I2 = I2_s;
elseif size(image_2,3)==3
    I2_s = I_o;
    I2 = ((I_o(:,:,1).^2.2+(1.5*I_o(:,:,2)).^2.2+(0.6*I_o(:,:,3)).^2.2)/(1+1.5^2.2+1.6^2.2)).^(1/2.2);
else
    I2_s = sum(I_o,3);
    I2 = I2_s;
end
I2_s = Visual(I2_s);
I2 = Visual(I2);

%% Gaussian denoising
sigma=0.5;
w=2*round(3*sigma)+1;
w=fspecial('gaussian',[w,w],sigma);
I1=imfilter(I1,w,'replicate');
I2=imfilter(I2,w,'replicate');

%% LNMS Parameters of keypoints detection
ratio = sqrt((size(I1,1)*size(I1,2))/(size(I2,1)*size(I2,2)));
if ratio>=1
    r2 = radius; r1 = round(radius*ratio);
else
    r1 = radius; r2 = round(radius/ratio);
end