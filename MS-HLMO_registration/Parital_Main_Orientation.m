%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function orientation = Parital_Main_Orientation(I,R1,R2,s)

hx = [-1,0,1;-2,0,2;-1,0,1]; % 一阶梯度 Sobel算子
hy = [1,2,1;0,0,0;-1,-2,-1];
Gx = imfilter(I, hx, 'replicate');
Gy = imfilter(I, hy, 'replicate');

W = floor(R2); % 窗半径
dx = -W : W; % 邻域x坐标
dy = -W : W; % 邻域y坐标
[dx,dy] = meshgrid(dx,dy);
Wcircle = ((dx.^2 + dy.^2) < (W+1)^2)*1.0; % 圆形窗
Patchsize = 2*W+1;

if s==1
    h = fspecial('gaussian',[Patchsize,Patchsize], R1/6)*(s-i)/s;
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
Gxy = conv2(Gx.*Gy, h, 'same');

orientation = atan2(2*Gxy,Gxx-Gyy)/2 + pi/2; % 取值范围：[-pi,pi] ——> [0,pi]