%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [matches, num_keys] = Match_Keypoint(descriptor_1,descriptor_2)
warning off
key1 = descriptor_1(:,1:5); des1 = descriptor_1(:,6:end);
key2 = descriptor_2(:,1:5); des2 = descriptor_2(:,6:end);

%% Match the keypoints
[indexPairs,~] = matchFeatures(des1,des2,'MaxRatio',1,'MatchThreshold', 100);
cor1 = key1(indexPairs(:, 1), :);
cor2 = key2(indexPairs(:, 2), :);
[cor2,index]=unique(cor2,'rows');
cor1=cor1(index,:);
num_keys = size(cor1,1);
if(num_keys<4)
    num_keys = 0; matches = [];
    return
end

%% Remove incorrect matches
H=FSC(cor1(:,3:4),cor2(:,3:4),'affine',2);
Y_=H*[cor1(:,3:4)';ones(1,size(cor1,1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-cor2(:,3:4)').^2));
inliersIndex=E<3;
cor1 = double(cor1(inliersIndex, :));
cor2 = double(cor2(inliersIndex, :));
matches = [cor1,cor2];
num_keys = size(cor1,1);