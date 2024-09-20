%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = GGLOH_Descriptor(img, kps, ...
    patch_size, NBA, NBO, int_flag, rot_flag)

W = floor(patch_size/2);  % ���뾶
X = -W : W;  % ����x����
Y = -W : W;  % ����y����
[XX,YY] = meshgrid(X,Y);
Wcircle = ((XX.^2 + YY.^2) < (W+1)^2) * 1.0;  % Բ�δ�

rr1 = W^2/(2*NBA+1); rr2 = rr1*(NBA+1);
Rho = XX.^2+YY.^2;
Rho(Rho<=rr1) = 1;
Rho(Rho>rr1 & Rho<=rr2) = 2;
Rho(Rho>rr2) = 3;
Rho = Rho .* Wcircle - 1;  % ��������0��1��2

[PMOM_m,PMOM_o] = Parital_Main_Orientation(img,1,sqrt(rr1),4,int_flag);
% Partial Main Orientation Map, ȡֵ��Χ��[0,pi)

if rot_flag
%     kps = [kps,diag(PMOM_o(kps(:,2),kps(:,1)))];  % fast
    kps = Base_Direction(kps,PMOM_m,PMOM_o,W,NBO);  % normal
    sinth = sin(kps(:,end));
    costh = cos(kps(:,end));
else
    kps = [kps,zeros(size(kps,1),1)];
    Theta = atan2(YY,XX) + pi;  % ȡֵ��Χ��[0,2pi]
    Theta = mod(floor(Theta*NBA/pi/2),NBA)+1;  % ȡֵ��Χ��[1,NBA]
end

weight = zeros(patch_size+1,patch_size+1);
descriptor = zeros(size(kps,1), (1+2*NBA)*NBO);  % descriptor (size: (1+2��NBA)��NBO)
for k = 1:size(kps,1)
    x = kps(k,1); x1 = max(1,x-W); x2 = min(x+W,size(img,2));
    y = kps(k,2); y1 = max(1,y-W); y2 = min(y+W,size(img,1));
    
    angle = PMOM_o(y1:y2, x1:x2);  % �ֲ�������ͼ��ȡֵ��Χ��[0,pi)
    if rot_flag
        sin_p = sinth(k); cos_p = costh(k);
        Xr =  cos_p * XX + sin_p * YY;
        Yr = -sin_p * XX + cos_p * YY;
        Theta = atan2(Yr,Xr) + pi;  % ȡֵ��Χ��[0,2pi]
        Theta = mod(floor(Theta*NBA/pi/2),NBA)+1;  % ȡֵ��Χ��[1,NBA]
        angle = mod(angle-kps(k,end), pi);  % ȡֵ��Χ��[0,pi)
    end
    angle_bin = zeros(patch_size+1,patch_size+1)-1;  % -1+1=0 ��ʾ��ͳ��
    angle_bin(W+y1-y+1:W+y2-y+1, W+x1-x+1:W+x2-x+1) = floor(angle*NBO/pi)+1;  % ȡֵ��Χ��[1,NBO]
    weight(W+y1-y+1:W+y2-y+1, W+x1-x+1:W+x2-x+1) = PMOM_m(y1:y2, x1:x2);
    
    feat_center = zeros(1,NBO);
    feat_outer = zeros(2,NBA,NBO);
    for xx = 1:patch_size+1
        for yy = 1:patch_size+1
            Rho_t = Rho(yy,xx);
            Theta_t = Theta(yy,xx);
            angle_t = angle_bin(yy,xx);
            if angle_t<=0 || Rho_t<0 || Rho_t>2
                continue
            elseif Rho_t==0
                feat_center(angle_t) = feat_center(angle_t) + weight(xx,yy);
            else
                feat_outer(Rho_t,Theta_t,angle_t) = ...
                    feat_outer(Rho_t,Theta_t,angle_t) + weight(xx,yy);
            end
        end
    end
    
    % histogram vectors
    des = feat_outer;
    if rot_flag
        des_H1 = des(:,1:NBA/2,:);
        des_H2 = des(:,NBA/2+1:NBA,:);
        des_D1 = des_H1 + des_H2;
        des_D2 = abs(des_H1 - des_H2);
        des_D2 = des_D2 * max(des_D1(:))/max(des_D2(:));
        des = cat(2,des_D1,des_D2);
    end
    des = [feat_center,des(:)'];
    
    if ~int_flag
        des = des /norm(des);
    end
    descriptor(k,:) = des;
end
descriptors = [kps,descriptor];