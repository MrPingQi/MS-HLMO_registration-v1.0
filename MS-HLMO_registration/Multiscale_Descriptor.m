%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = Multiscale_Descriptor(I,kps,patch_size,NBS,NBO,...
    nOctaves,nLayers,G_resize,G_sigma,rot_flag)

if nLayers<=1
    sig = 0;
else
    sig = Get_Gaussian_Scale(G_sigma,nLayers);
end

I_t = [];
descriptors = cell(nOctaves,nLayers);
for octave=1:nOctaves
    kps_t = round(kps(:,1:2)./G_resize^(octave-1));
    [~,index,~] = unique(kps_t,'rows');
    for layer=1:nLayers
        I_t = Gaussian_Scaling(I, I_t, octave, layer, G_resize, sig(layer));
        descriptor = GGLOH_Descriptor(I_t, kps(index,1:2), kps_t(index,:),...
            patch_size, NBS, NBO, rot_flag);
        descriptors{octave,layer} = descriptor;
    end
end

function sig = Get_Gaussian_Scale(sigma,numLayers)
sig=zeros(1,numLayers);
sig(1)=sigma;
k=2^(1.0/(numLayers-1));
for i=2:1:numLayers
    sig_previous=k^(i-2)*sigma;
    sig_current=k*sig_previous;
    sig(i)=sqrt(sig_current^2-sig_previous^2);
end