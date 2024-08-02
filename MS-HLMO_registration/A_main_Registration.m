%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   Beijing Key Laboratory of Fractional Signals and Systems,
%   Multi-Dimensional Signal and Information Processing Institute,
%   School of Information and Electronics, Beijing Institute of Technology
% Contact: gao-pingqi@qq.com

% MS-HLMO for multi-source/multi-modal images matching/registration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc; clear;
addpath('functions')

%% Is there any obvious intensity difference (multi-modal)
int_flag = 1; % yes:1, no:0
%% Is there any obvious rotation difference
rot_flag = 1;
%% Is there any obvious scale difference
scl_flag = 1;
%% What spatial transformation model do you need at the end
trans_form = 'affine';  % similarity, affine, projective
%% What image pair output form do you need at the end
out_form = 'union';  % reference, union, inter
%% Do you want the visualization of registration results
Is_flag = 1;  % Visualization show
I3_flag = 1;  % Overlap form
I4_flag = 1;  % Mosaic form

%% Parameters
G_resize = 2;  % Gaussian pyramid downsampling ratio, default: 2
nOctaves1 = 3; % Gaussian pyramid octave number, default: 3
nOctaves2 = 3; 
G_sigma = 1.6; % Gaussian blurring standard deviation, default: 1.6
nLayers = 4;   % Gaussian pyramid layer number, default: 4
radius = 2;    % Local non-maximum suppression radius, default: 2
N = 5000;      % Keypoints number threhold, default: 5000
patch_size = 72; % GGLOH patchsize, default: 72 or 96
NBS = 12;        % GGLOH localtion division, default: 12
NBO = 12;        % GGLOH orientation division, default: 12
Error = 5;       % Outlier removal pixel loss, default: 5 or 3
K = 1;           % Experimental repetition times

%% Read Images
[image_1,file1,~] = Readimage;
[image_2,file2,~] = Readimage;
% [image_1,~,~] = Readimage(file1);
% [image_2,~,~] = Readimage(file2);

%% Image Preproscessing
resample1 = 1; resample2 = 1;
[I1_s,I1] = Preproscessing(image_1,resample1,[]);  % I1:参考图像; Reference image
[I2_s,I2] = Preproscessing(image_2,resample2,[]);  % I2:待配准图像; Sensed image
figure; subplot(121),imshow(I1_s); subplot(122),imshow(I2_s); drawnow
% figure; subplot(121),imshow(I1,[]); subplot(122),imshow(I2,[]); drawnow

%%
fprintf('\n开始图像配准，请耐心等待...\n Image registration starts, please be patient...\n\n'); ts=cputime;

%% Keypoints Detection
ratio = sqrt(size(I1,1)*size(I1,2)/(size(I2,1)*size(I2,2)));
if ratio>=1
    r2 = radius; r1 = round(radius*ratio);
else
    r1 = radius; r2 = round(radius/ratio);
end
tic,keypoints_1 = Detect_Keypoints(I1,6,r1,N,nOctaves1,G_resize,1);
    t=num2str(toc); fprintf(['已完成参考图像特征点检测，用时 ',t,'s\n']);
                    fprintf([' Done keypoints detection of reference image, time: ',t,'s\n']);
tic,keypoints_2 = Detect_Keypoints(I2,6,r2,N,nOctaves2,G_resize,1);
    t=num2str(toc); fprintf(['已完成待配准图像特征点检测，用时 ',t,'s\n']);
                    fprintf([' Done keypoints detection of sensed image, time: ',t,'s\n\n']);

%% Keypoints Description
tic,descriptors_1 = Multiscale_Descriptor(I1,keypoints_1,patch_size,NBS,NBO,...
    nOctaves1,nLayers,G_resize,G_sigma,int_flag,rot_flag);
    t=num2str(toc); fprintf(['已完成参考图像描述符建立，用时 ',t,'s\n']);
                    fprintf([' Done keypoints description of reference image, time: ',t,'s\n']);
tic,descriptors_2 = Multiscale_Descriptor(I2,keypoints_2,patch_size,NBS,NBO,...
    nOctaves2,nLayers,G_resize,G_sigma,int_flag,rot_flag);
    t=num2str(toc); fprintf(['已完成待配准图像描述符建立，用时 ',t,'s\n']);
                    fprintf([' Done keypoints description of sensed image, time: ',t,'s\n\n']);

%% Keypoints Matching
tic
if K==1
    [cor1_o,cor2_o] = Multiscale_Matching(descriptors_1,descriptors_2,...
        nOctaves1,nOctaves2,nLayers,scl_flag);
    [cor1,cor2] = Outlier_Removal(cor1_o,cor2_o,Error);
else
    Num = zeros(1,K); correspond_1 = cell(K,1); correspond_2 = cell(K,1);
    for k = 1:K
        [cor1_o,cor2_o] = Multiscale_Matching(descriptors_1,descriptors_2,...
            nOctaves1,nOctaves2,nLayers,scl_flag);
        [cor1,cor2] = Outlier_Removal(cor1_o,cor2_o,Error);
        correspond_1{k} = cor1; correspond_2{k} = cor2; Num(k) = size(cor1,1);
    end
    [~,index] = max(Num);
    cor1 = correspond_1{index}; cor2 = correspond_2{index};
end
    t=num2str(toc); fprintf(['已完成特征点匹配，用时 ',t,'s\n']);
                    fprintf(['Done keypoints matching, time: ',t,'s\n\n']);
    matchment = Show_Matches(I1_s,I2_s,cor1/resample1,cor2/resample2,0);

%% Image transformation
tic,[I1_r,I2_r,I1_rs,I2_rs,I3,I4,t_form,~] = Transformation(image_1,image_2,...
    cor1,cor2,trans_form,out_form,1,Is_flag,I3_flag,I4_flag);
    t=num2str(toc); fprintf(['已完成图像变换，用时 ',t,'s\n']);
                    fprintf([' Done image transformation，time: ',num2str(toc),'s\n\n']);
    figure,imshow(I3),title('Overlap Form');
    figure,imshow(I4),title('Mosaic Form');

%% Save results
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__'); tic
cors = {cor1;cor2}; Imwrite(cors,['.\save_image\',Date,'0 corresponds.mat']);
if exist('matchment') && ~isempty(matchment) && isvalid(matchment)
    saveas(matchment,['.\save_image\',Date,'0 Matching result.jpg']);
end
Imwrite(I1_r ,['.\save_image\',Date,'1 Reference image.tif']);
Imwrite(I2_r ,['.\save_image\',Date,'2 Registered image.tif']);
Imwrite(I1_rs,['.\save_image\',Date,'3 Reference image show.jpg']);
Imwrite(I2_rs,['.\save_image\',Date,'4 Registered image show.jpg']);
Imwrite(I3   ,['.\save_image\',Date,'5 Overlap of results.jpg']);
Imwrite(I4   ,['.\save_image\',Date,'6 Mosaic of results.jpg']);
t=num2str(toc); fprintf(['配准结果已经保存在程序根目录下的save_image文件夹中，用时',t,'s\n']);
                fprintf([' Registration results are saved in the save_image folder, time: ',t,'s\n']);