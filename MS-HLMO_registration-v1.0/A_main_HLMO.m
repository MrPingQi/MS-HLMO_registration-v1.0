%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   1. National Key Laboratory of Science and Technology on Space-Born Intelligent Information Processing
%   2. School of Information and Electronics, Beijing Institute of Technology (BIT), Beijing 100081, China
%   3. Beijing Institute of Technology, Zhuhai (ZHBIT), Guangdong 519088, China
% Contact: gao-pingqi@qq.com

% MS-HLMO for multi-source/multi-modal images matching/registration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc; clear;
addpath('functions','func_Math')
save_path = '.\save_image\';

%% Is there any obvious intensity difference (multi-modal)
int_flag = 1;  % yes:1, no:0
%% Is there any obvious rotation difference
rot_flag = 1;
%% Is there any obvious scale difference
scl_flag = 0;
%% What spatial transformation model do you need at the end
trans_form = 'affine';  % similarity, affine, projective
%% What image pair output form do you need at the end
out_form = 'union';  % reference, union, inter
%% Do you want the visualization of registration results
Is_flag = 1;  % Visualization show
I3_flag = 1;  % Overlap form
I4_flag = 1;  % Mosaic form

%% Parameters
G_resize  = 2;    % Gaussian pyramid downsampling ratio, default: 2
nOctaves1 = 3;    % Gaussian pyramid octave number, default: 3
nOctaves2 = 3; 
G_sigma   = 1.6;  % Gaussian blurring standard deviation, default: 1.6
nLayers   = 2;    % Gaussian pyramid layer number, default: 4 or 2
thresh    = 50;   % Harris response threshold, default: 50 (Could be set to 0)
radius    = 2;    % Local non-maximum suppression radius, default: 2
Npoint    = 5000; % Keypoints number threshold, default: 5000
patchsize = 72;   % GGLOH patchsize, default: 72 or 96
NBA       = 12;   % GGLOH localtion division, default: 12
NBO       = 12;   % GGLOH orientation division, default: 12
Error     = 5;    % Outlier removal pixel loss, default: 5 or 3
K         = 1;    % Outlier removal repetition times

%% Read Images
[image_1,file1,~] = Readimage;
[image_2,file2,~] = Readimage;
% [image_1,~,~] = Readimage(file1);
% [image_2,~,~] = Readimage(file2);

%% Image preproscessing
resample1 = 1; resample2 = 1;
% [~,resample1] = Deal_Extreme(image_1,64,512,0);
% [~,resample2] = Deal_Extreme(image_2,64,512,0);
[I1_s,I1] = Preproscessing(image_1,resample1,[]);  % I1:参考图像; Reference image
[I2_s,I2] = Preproscessing(image_2,resample2,[]);  % I2:待配准图像; Sensed image
figure; subplot(121),imshow(I1_s); subplot(122),imshow(I2_s); drawnow
% figure; subplot(121),imshow(I1,[]); subplot(122),imshow(I2,[]); drawnow

%% Start
fprintf('\n*开始图像配准，请耐心等待...\n Image registration starts, please be patient...\n\n');
warning off; t = [];

%% Keypoints detection
ratio = sqrt(size(I1,1)*size(I1,2)/(size(I2,1)*size(I2,2)));
if ratio>=1
    r2 = radius; r1 = round(radius*ratio);
else
    r1 = radius; r2 = round(radius/ratio);
end
tic,keypoints_1 = Detect_Keypoint(I1,6,thresh,r1,Npoint,nOctaves1,G_resize,1);
    t(1)=toc; fprintf(['已完成参考图像特征点检测，用时 ',num2str(t(1)),'s\n']);
              fprintf([' Done keypoints detection of reference image, time: ',num2str(t(1)),'s\n']);
tic,keypoints_2 = Detect_Keypoint(I2,6,thresh,r2,Npoint,nOctaves2,G_resize,1);
    t(2)=toc; fprintf(['已完成待配准图像特征点检测，用时 ',num2str(t(2)),'s\n']);
              fprintf([' Done keypoints detection of sensed image, time: ',num2str(t(2)),'s\n\n']);

%% Keypoints description
tic,descriptors_1 = Multiscale_Descriptor(I1,keypoints_1,patchsize,NBA,NBO,...
    nOctaves1,nLayers,G_resize,G_sigma,int_flag,rot_flag);
    t(3)=toc; fprintf(['已完成参考图像描述符建立，用时 ',num2str(t(3)),'s\n']);
              fprintf([' Done keypoints description of reference image, time: ',num2str(t(3)),'s\n']);
tic,descriptors_2 = Multiscale_Descriptor(I2,keypoints_2,patchsize,NBA,NBO,...
    nOctaves2,nLayers,G_resize,G_sigma,int_flag,rot_flag);
    t(4)=toc; fprintf(['已完成待配准图像描述符建立，用时 ',num2str(t(4)),'s\n']);
              fprintf([' Done keypoints description of sensed image, time: ',num2str(t(4)),'s\n\n']);

%% Keypoints matching
tic,[cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves1,nOctaves2,nLayers,Error,K,scl_flag);
    t(5)=toc; fprintf(['已完成特征点匹配，用时 ',num2str(t(5)),'s\n']);
              fprintf([' Done keypoints matching, time: ',num2str(t(5)),'s\n\n']);
    matchment = Show_Matches(I1_s,I2_s,cor1,cor2,0);
    cor1 = cor1/resample1; cor2 = cor2/resample2;

%% Image transformation
tic,[I1_r,I2_r,I1_rs,I2_rs,I3,I4,t_form,~] = Transformation(image_1,image_2,...
    cor1,cor2,trans_form,out_form,1,Is_flag,I3_flag,I4_flag);
    t(6)=toc; fprintf(['已完成图像变换，用时 ',num2str(t(6)),'s\n']);
              fprintf([' Done image transformation，time: ',num2str(t(6)),'s\n\n']);
    figure,imshow(I3),title('Overlap Form'); drawnow
    figure,imshow(I4),title('Mosaic Form'); drawnow

%% Done
T=num2str(sum(t)); fprintf(['*已完成图像配准，总用时 ',T,'s\n']);
                   fprintf([' Done image registration, total time: ',T,'s\n\n']);

%% Save results
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__'); tic
cors = {cor1;cor2}; Imwrite(cors,[save_path,Date,'0 corresponds.mat']);
if exist('matchment','var') && ~isempty(matchment) && isvalid(matchment)
    saveas(matchment,[save_path,Date,'0 Matching result.jpg']);
end
Imwrite(I1_r ,[save_path,Date,'1 Reference image.tif']);
Imwrite(I2_r ,[save_path,Date,'2 Registered image.tif']);
Imwrite(I1_rs,[save_path,Date,'3 Reference image show.jpg']);
Imwrite(I2_rs,[save_path,Date,'4 Registered image show.jpg']);
Imwrite(I3   ,[save_path,Date,'5 Overlap of results.jpg']);
Imwrite(I4   ,[save_path,Date,'6 Mosaic of results.jpg']);
t(7)=toc; disp(['配准结果已经保存在 ', save_path,' 中，用时',num2str(t(7)),'s']);
          disp([' Registration results are saved at ', save_path,', time: ',num2str(t(7)),'s']);