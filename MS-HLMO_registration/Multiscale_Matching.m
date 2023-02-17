%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
    numOctaves_1,numOctaves_2,numLayers)
%% Matching
matches = cell(numOctaves_1,numLayers,numOctaves_2,numLayers);
confidence = zeros(numOctaves_1,numLayers,numOctaves_2,numLayers);
for Octave2=1:numOctaves_2
    for Octave1=1:numOctaves_1
        for Layer2=1:numLayers
            for Layer1=1:numLayers
des_1 = descriptors_1{Octave1,Layer1};
des_2 = descriptors_2{Octave2,Layer2};
[matches{Octave1,Layer1,Octave2,Layer2},...
    confidence(Octave1,Layer1,Octave2,Layer2)] = Match_Keypoint(des_1,des_2);
            end
        end
    end
end
    

%% Preferring
Confidence = zeros(numOctaves_1,numOctaves_2);
Matches = cell(numOctaves_1,numOctaves_2);
for Octave1=1:numOctaves_1
    for Octave2=1:numOctaves_2
        matches_t = [];
        for Layer1=1:numLayers
            for Layer2=1:numLayers
                matches_t = [matches_t; matches{Octave1,Layer1,Octave2,Layer2}];
            end
        end
        if size(matches_t,1)>0
            [~,index1,~] = unique(matches_t(:,1:2),'rows');
            matches_t = matches_t(index1,:);
            [~,index2,~] = unique(matches_t(:,6:7),'rows');
            matches_t = matches_t(index2,:);
        else
            Confidence(Octave1,Octave2) = 0;
            continue
        end
        if size(matches_t,1)>0
            Matches{Octave1,Octave2} = matches_t;
            Confidence(Octave1,Octave2) = size(matches_t,1);
        else
            Confidence(Octave1,Octave2) = 0;
        end
    end
end
[max_O1,max_O2] = find(Confidence==max(max(Confidence)));

MMatches = [];
for i = 1-min(max_O1,max_O2):min(numOctaves_1-max_O1,numOctaves_2-max_O2)
    aaa = Matches{max_O1+i,max_O2+i};
    if size(aaa,1)>3
        MMatches = [MMatches; aaa];
    end
end
[~,index1,~] = unique(MMatches(:,1:2),'rows');
MMatches = MMatches(index1,:);
[~,index2,~] = unique(MMatches(:,6:7),'rows');
MMatches = MMatches(index2,:);
cor1 = MMatches(:,1:5); cor2 = MMatches(:,6:10);