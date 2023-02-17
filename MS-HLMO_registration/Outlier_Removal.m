%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = Outlier_Removal(cor1,cor2,Error)

H=FSC(cor1(:,1:2),cor2(:,1:2),'affine',2);
Y_=H*[cor1(:,1:2)';ones(1,size(cor1(:,1:2),1))];
Y_(1,:)=Y_(1,:)./Y_(3,:);
Y_(2,:)=Y_(2,:)./Y_(3,:);
E=sqrt(sum((Y_(1:2,:)-cor2(:,1:2)').^2));
inliersIndex=E<Error;
cor1 = cor1(inliersIndex, :);
cor2 = cor2(inliersIndex, :);