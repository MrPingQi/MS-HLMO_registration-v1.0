%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   Beijing Key Laboratory of Fractional Signals and Systems,
%   School of Information and Electronics, Beijing Institute of Technology
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;
%% Make fileholder for save images
if (exist('save_image','dir')==0)
    mkdir('save_image');
end

%% Read images
[image_1, image_2] = Readimage;
% image_1=imresize(image_1,1/2,'bicubic');
% image_2=imresize(image_2,1/2,'bicubic');

%% Image preproscessing
resample1 = 1/1; resample2 = 1/1;
[I1_o,I1] = Preproscessing(image_1,resample1); % I1: Reference image
[I2_o,I2] = Preproscessing(image_2,resample2); % I2: Image to be registered
figure,imshow(I1,[]),title('Reference image');
figure,imshow(I2,[]),title('Image to be registered');

%% Parameters
G_resize = 2;  % Gaussian pyramid downsampling unit, default:2
G_sigma = 1.6; % Gaussian pyramid blurring unit, default:1.6
nOctaves_1 = 3; nOctaves_2 = 3; % Gaussian pyramid octave number
nLayers = 4;   % Gaussian pyramid layer number
sigma = 10;   % Harris: Upper standard deviation of Gaussian kernel
thresh = 50; % Harris: Cornerness discriminant threshold
radius = 5;  % Harris: LNSM patch radius, default: 5, 2, or 1
N = 2000;    % Feature points number threshold
patch_size = 96; % HLMO: patch size (scale)
NA = 12;         % HLMO: Subregion division number
NO = 12;         % HLMO: Orientation quantification number
rotate = 1; % Is there obvious rotation between the images, Yes:1, No:0
trans_form = 'affine'; % Transformation: 'similarity','affine','projective'

%% Registration algorithm
warning off
fprintf('\n** Registration starts, have fun\n\n'); ts=cputime;

[keypoints_1,keypoints_2] = Keypoints_Detection(I1,I2,...
    sigma,thresh,radius,N,nOctaves_1,nOctaves_2,G_resize);

[descriptors_1,descriptors_2] = Keypoints_Description(...
    I1,keypoints_1,I2,keypoints_2,patch_size,NA,NO,rotate,...
    nOctaves_1,nOctaves_2,nLayers,G_resize,G_sigma);

[cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves_1,nOctaves_2,nLayers);
cor1(:,1:2) = cor1(:,1:2)/resample1; cor2(:,1:2) = cor2(:,1:2)/resample2;

%%
% I1_s = I1; I2_s = I2_o(:,:,[3,2,1]);
I1_s = I1_o; I2_s = I2_o;
% I1_s=I1_s-min(I1_s(:)); I1_s=I1_s/mean(I1_s(:))/2;
% I2_s=I2_s-min(I2_s(:)); I2_s=I2_s/mean(I2_s(:))/2;
matchment = Show_Matches(I1_s,I2_s,cor1,cor2,1);

%% Image transforming
tic;
[I1_r,I2_r,I3,I4] = Transformation_union(I1_s,I2_s,cor1,cor2,trans_form);
% [I1_r,I2_r,I3,I4] = Transformation_inter(I1_s,I2_s,cor1,cor2,trans_form);
    str=['Done: Image tranformation, time cost: ',num2str(toc),'s\n\n']; fprintf(str); tic

%% Time and Result
te=cputime-ts;
str=['** Done: Image registration, time cost: ',num2str(te),'s\n\n']; fprintf(str);
figure; imshow(I3,[]); title('Fusion Form');
figure; imshow(I4,[]); title('Checkerboard Form'); 

%% Save images
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__');
str=['.\save_image\',Date,'1 Matching Result','.jpg']; saveas(matchment,str);
str=['.\save_image\',Date,'2 Reference Image','.jpg']; imwrite(I1_r,str);
str=['.\save_image\',Date,'3 Transformed Image','.jpg']; imwrite(I2_r,str);
str=['.\save_image\',Date,'4 Fusion of results','.jpg']; imwrite(I3,str);
str=['.\save_image\',Date,'5 Checkerboard of results','.jpg']; imwrite(I4,str);
str='The registration results are saved in the save_image folder\n\n'; fprintf(str);
