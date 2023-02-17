%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = GGLOH_Descriptor(img, kps_o, kps, patch_size, NBS, NBO, rot_flag)
W = floor(patch_size/2); % 窗半径
X = -W : W; % 邻域x坐标
Y = -W : W; % 邻域y坐标
[XX,YY] = meshgrid(X,Y);
Wcircle = ((XX.^2 + YY.^2) < (W+1)^2)*1.0; % 圆形窗

rr1 = W^2/(2*NBS+1); rr2 = rr1*(NBS+1);
Rho = XX.^2+YY.^2;
Rho(Rho<=rr1) = 1;
Rho(Rho>rr1 & Rho<=rr2) = 2;
Rho(Rho>rr2) = 3;
Rho = Rho .* Wcircle - 1; % 三个区域：0、1、2

if ~rot_flag
    Theta = atan2(YY,XX) + pi; % 取值范围：[0,2pi]
    Theta = mod(floor(Theta*NBS/pi/2),NBS)+1; % 取值范围：[1,NBS]
end

PMOM = Parital_Main_Orientation(img,sqrt(rr1),W,10); % partial main orientation map
% 取值范围：[0,pi]

descriptor = zeros(size(kps,1), (1+2*NBS)*NBO); % descriptor (size: (1+2×s)×o)
for k = 1: size(kps,1)
    x = kps(k,1); x1 = max(1,x-W); x2 = min(x+W,size(img,2));
    y = kps(k,2); y1 = max(1,y-W); y2 = min(y+W,size(img,1));
    
    if rot_flag
        orient = PMOM(y,x);
        kps(k,3) = orient;
        angle = mod(PMOM(y1:y2, x1:x2)-orient, pi); % 局部主方向图，取值范围：[0,pi)
        sin_p = sin(orient);
        cos_p = cos(orient);
        Xr =  cos_p * XX + sin_p * YY;
        Yr = -sin_p * XX + cos_p * YY;
        Theta = atan2(Yr,Xr) + pi; % 取值范围：[0,2pi]
        Theta = mod(floor(Theta*NBS/pi/2),NBS)+1; % 取值范围：[1,NBS]
    else
        kps(k,3) = 0;
        angle = mod(PMOM(y1:y2, x1:x2), pi); % 局部主方向图，取值范围：[0,pi)
    end
    angle_bin = zeros(patch_size+1,patch_size+1)-1; % -1+1=0 表示不统计
    angle_bin(W+y1-y+1:W+y2-y+1, W+x1-x+1:W+x2-x+1) = floor(angle*NBO/pi)+1; % 取值范围：[1,NBO]
    
    feat_center = zeros(1,NBO);
    feat_outer = zeros(2,NBS,NBO);
    for xx = 1:patch_size+1
        for yy = 1:patch_size+1
            Rho_t = Rho(yy,xx);
            Theta_t = Theta(yy,xx);
            angle_t = angle_bin(yy,xx);
            if angle_t<=0 || Rho_t<0 || Rho_t>2
                continue
            elseif Rho_t==0
                feat_center(angle_t) = feat_center(angle_t) + 1;
            else
                feat_outer(Rho_t,Theta_t,angle_t) = ...
                    feat_outer(Rho_t,Theta_t,angle_t) + 1;
            end
        end
    end
    
    % histogram vectors
    des_H = feat_outer;
    des_H1 = des_H(:,1:NBS/2,:);
    des_H2 = des_H(:,NBS/2+1:NBS,:);
    des_D1 = des_H1 + des_H2;
    des_D2 = abs(des_H1 - des_H2);
    des_D2 = des_D2 * max(des_D1(:))/max(des_D2(:));
    des_D = cat(2,des_D1,des_D2);
    des = [feat_center,des_D(:)'];
    
    if norm(des) ~= 0
        des = des /norm(des);
    end
    descriptor(k,:)=des;
end
descriptors = [kps_o,kps,descriptor];