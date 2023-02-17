%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I_t = Gaussian_Scaling(I,I_t,Octave,Layer,G_resize,sig)
if(Octave==1 && Layer==1)
    I_t = I;
elseif(Layer==1)
    I_t = imresize(I,1/G_resize^(Octave-1),'bicubic');
else
    window_gaussian = round(2*sig);
    window_gaussian = 2*window_gaussian+1;
    w = fspecial('gaussian',[window_gaussian,window_gaussian],sig);
    I_t = imfilter(I_t,w,'replicate');
end
end