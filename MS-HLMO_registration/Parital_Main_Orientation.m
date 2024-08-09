%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [magnitude,orientation] = Parital_Main_Orientation(I,R1,R2,s,int_flag)

hx = [-1,0,1;-2,0,2;-1,0,1]; % 一阶梯度 Sobel算子
hy = [-1,-2,-1;0,0,0;1,2,1];
Gx = imfilter(I, hx, 'replicate');
Gy = imfilter(I, hy, 'replicate'); clear I;

W = floor(R2); % 窗半径
dx = -W : W; % 邻域x坐标
dy = -W : W; % 邻域y坐标
[dx,dy] = meshgrid(dx,dy);
Wcircle = ((dx.^2 + dy.^2) < (W+1)^2)*1.0; % 圆形窗
Patchsize = 2*W+1;

if s==1
    h = fspecial('gaussian',[Patchsize,Patchsize], R1/6);
else
    step = (R2-R1)/(s-1);
    h = zeros(Patchsize,Patchsize);
    for i=0:s-1
        sigma = (R1+step*i)/6;
        h = h + fspecial('gaussian',[Patchsize,Patchsize], sigma);
    end
end
h = h.*Wcircle;

Gxx = conv2(Gx.*Gx, h, 'same');
Gyy = conv2(Gy.*Gy, h, 'same');
Gxy = conv2(Gx.*Gy, h, 'same'); clear Gx Gy
Gsx = Gxx-Gyy;                  clear Gxx Gyy;
Gsy = 2*Gxy;                    clear Gxy;

orientation = atan2(Gsy,Gsx)/2 + pi/2;  % 取值范围：[-pi,pi] ——> [0,pi]
orientation = mod(orientation,pi);  % 取值范围：[0,pi] ——> [0,pi)
if int_flag
    magnitude = orientation*0+1;
else
    magnitude = sqrt(sqrt(Gsx.^2+Gsy.^2));
end