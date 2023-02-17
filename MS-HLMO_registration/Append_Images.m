%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function im = Append_Images(image_1,image_2,option)
[~,~,B1]=size(image_1);
[~,~,B2]=size(image_2);
if B1~=1 && B1~=3
    image_1=sum(image_1,3);
end
image_1=image_1-min(image_1(:));
image_1=image_1/mean(image_1(:))/1.7;
if B2~=1 && B2~=3
    image_2=sum(image_2,3);
end
image_2=image_2-min(image_2(:));
image_2=image_2/mean(image_2(:))/2;

[M1,N1,B1]=size(image_1);
[M2,N2,B2]=size(image_2);
if(B1==1 && B2==3)
    temp=image_1;
    image_1(:,:,1)=temp; image_1(:,:,2)=temp; image_1(:,:,3)=temp;
elseif(B1==3 && B2==1)
    temp=image_2;
    image_2(:,:,1)=temp; image_2(:,:,2)=temp; image_2(:,:,3)=temp;
end

if option==1
    if (M1 < M2)
         image_1(M2,1) = 0;
    else
         image_2(M1,1) = 0;
    end
    im = [image_1 image_2];
elseif option==2
    if (N1 < M2)
         image_1(1,N2) = 0;
    else
         image_2(1,N1) = 0;
    end
    im = [image_1;image_2];
end