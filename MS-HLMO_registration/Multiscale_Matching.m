%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    nOctaves_1,nOctaves_2,nLayers,scl_flag)
%% Matching
matches = cell(nOctaves_1,nLayers,nOctaves_2,nLayers);
confidence = zeros(nOctaves_1,nLayers,nOctaves_2,nLayers);
if scl_flag
    for octave2=1:nOctaves_2
        for octave1=1:nOctaves_1
            for layer2=1:nLayers
                for layer1=1:nLayers
    [matches{octave1,layer1,octave2,layer2},...
        confidence(octave1,layer1,octave2,layer2)] = Match_Keypoints(...
        descriptors_1{octave1,layer1},descriptors_2{octave2,layer2});
                end
            end
        end
    end
else
    for octave=1:min(nOctaves_1,nOctaves_2)
        for layer2=1:nLayers
            for layer1=1:nLayers
    [matches{octave,layer1,octave,layer2},...
        confidence(octave,layer1,octave,layer2)] = Match_Keypoints(...
        descriptors_1{octave,layer1},descriptors_2{octave,layer2});
            end
        end
    end
end
clear descriptors_1 descriptors_2;

%% Optimizing
Confidence = zeros(nOctaves_1,nOctaves_2);
Matches = cell(nOctaves_1,nOctaves_2);
for octave1=1:nOctaves_1
    for octave2=1:nOctaves_2
        matches_t = [];
        for layer1=1:nLayers
            for layer2=1:nLayers
                matches_t = [matches_t; matches{octave1,layer1,octave2,layer2}];
            end
        end
        if size(matches_t,1)>0
            matches_t = matches_t(:,[3:4,1:2,5,8:9,6:7,10]);  % Switch kps and kps_t
            [~,index1,~] = unique(matches_t(:,1:2),'rows');
            matches_t = matches_t(index1,:);
            [~,index2,~] = unique(matches_t(:,6:7),'rows');
            matches_t = matches_t(index2,:);
            cor1 = matches_t(:,1:5); cor2 = matches_t(:,6:10);
%             [cor1,cor2,~] = Outlier_Removal(matches_t(:,1:5),matches_t(:,6:10),5);
        end
        if size(cor1,1)>0
            Matches{octave1,octave2} = [cor1,cor2];
            Confidence(octave1,octave2) = size(matches_t,1);
        end
    end
end
[max_O1,max_O2] = find(Confidence==max(max(Confidence)));

MMatches = [];
for i = 1-min(max_O1,max_O2):min(nOctaves_1-max_O1,nOctaves_2-max_O2)
    matches_t = Matches{max_O1+i,max_O2+i};
    if size(matches_t,1)>3
        MMatches = [MMatches; matches_t];
    end
end
[~,index1,~] = unique(MMatches(:,1:2),'rows');
MMatches = MMatches(index1,:);
[~,index2,~] = unique(MMatches(:,6:7),'rows');
MMatches = MMatches(index2,:);
% cor1 = MMatches(:,1:5); cor2 = MMatches(:,6:10);
[cor1,cor2,~] = Outlier_Removal(MMatches(:,1:5),MMatches(:,6:10),5);