%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matchment = Show_Matches(I1,I2,cor1,cor2,option)
[I3,cor1,cor2] = Append_Images(I1,I2,cor1,cor2,option,'middle'); % 'top','middle','bottom'
matchment = figure; imshow(I3); hold on
if option==1
    title(['Left is reference image --- ',num2str(size(cor1,1)),' matching pairs --- Right is sensed image']);
    cols = size(I1,2);
    for i=1:size(cor1,1)
        line([cor1(i,1) cor2(i,1)+cols],[cor1(i,2) cor2(i,2)], 'Color', 'y');
        plot(cor1(i,1),cor1(i,2),'go', 'Color', 'r')
        plot(cor2(i,1)+cols,cor2(i,2),'g+', 'Color', 'g')
    end
    % for i=1:size(cor1,1)
    %     text(cor1(i,1),cor1(i,2),num2str(i),'color','y');
    %     text(cor2(i,1)+cols,cor2(i,2),num2str(i),'color','y');
    % end
elseif option==2
    title(['Top is reference image --- ',num2str(size(cor1,1)),' matching pairs --- Bottom is sensed image']);
    rows = size(I1,1);
    for i=1:size(cor1,1)
        line([cor1(i,1) cor2(i,1)],[cor1(i,2) cor2(i,2)+rows], 'Color', 'y');
        plot(cor1(i,1),cor1(i,2),'go', 'Color', 'r')
        plot(cor2(i,1),cor2(i,2)+rows,'g+', 'Color', 'g')
    end
    % for i=1:size(cor1,1)
    %     text(cor1(i,1),cor1(i,2),num2str(i),'color','y');
    %     text(cor2(i,1),cor2(i,2)+rows,num2str(i),'color','y');
    % end
end
hold off


function [img,cor1,cor2] = Append_Images(I1,I2,cor1,cor2,option,pos)
[~,~,B1] = size(I1);
[~,~,B2] = size(I2);
if B1~=1 && B1~=3
    I1 = sum(I1,3);
end
I1 = Visual(I1);
if B2~=1 && B2~=3
    I2 = sum(I2,3);
end
I2 = Visual(I2);

[M1,N1,B1] = size(I1);
[M2,N2,B2] = size(I2);
if(B1==1 && B2==3)
    temp = I1;
    I1(:,:,1) = temp; I1(:,:,2) = temp; I1(:,:,3) = temp;
elseif(B1==3 && B2==1)
    temp = I2;
    I2(:,:,1) = temp; I2(:,:,2) = temp; I2(:,:,3) = temp;
end

if option==1
    switch pos
    case 'top'
        if (M1 < M2)
            I1(M2,1) = 0;
        else
            I2(M1,1) = 0;
        end
    case 'middle'
        if (M1 < M2)
            dM = floor(abs(M1-M2)/2);
            temp = I1;
            I1 = zeros(M2,N1,size(I1,3));
            I1(dM+1:dM+M1,:,:) = temp;
            cor1(:,2) = cor1(:,2)+dM;
        else
            dM = floor(abs(M1-M2)/2);
            temp = I2;
            I2 = zeros(M1,N2,size(I2,3));
            I2(dM+1:dM+M2,:,:) = temp;
            cor2(:,2) = cor2(:,2)+dM;
        end
    end
    img = [I1,I2];
elseif option==2
    if (N1 < M2)
        I1(1,N2) = 0;
    else
        I2(1,N1) = 0;
    end
    img = [I1;I2];
end