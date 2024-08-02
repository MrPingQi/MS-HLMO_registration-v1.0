%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function kps = Detect_Keypoints(I,scale,radius,N,numOctaves,G_resize,disp)
%% Image pat and image mask
I = abs(I);
imagepat = 5;
I_p = Image_Pat(I,imagepat); % add image pat at boundary
I_p = I_p*255;
msk = Mask(I_p,0);

%% Keypoints detectation
kps = Harris(I_p,scale,0,radius);
kps = Remove_Boundary_Points(kps,msk,max(10,G_resize^(numOctaves-2)));
kps = sortrows(kps,-3);
kps = kps(1:min(N,size(kps,1)),:);
kps(:,1:2) = kps(:,1:2)-imagepat;

%% Show detected keypoints
if disp==1
    figure,imshow(I,[]); 
    hold on;
    plot(kps(:,1),kps(:,2),'r.');
%     for i=1:size(kps,1)
%         text(kps(i,1),kps(i,2),num2str(i),'color','y');
%     end
    title(['Detected Harris keypoints: ',num2str(size(kps,1))])
    drawnow
end


function I_p = Image_Pat(I,s)
[m,n] = size(I);
I_p = zeros([m+2*s,n+2*s]);
I_p(s+1:end-s,s+1:end-s) = I;


function msk = Mask(I,th)
I = I./max(I(:))*255;
msk = double(I>th);
h = D2gauss(7,4,7,4,0);
msk = (conv2(msk,h,'same')>0.5); % 0.8


function p = Remove_Boundary_Points(loc,msk,s)
se = strel('disk',s);
msk = ~(imdilate(~msk,se));
p = [];
for i = 1:size(loc,1)
    if msk(loc(i,2),loc(i,1)) == 1
        p = [p;loc(i,:)];
    end
end
