function [KDATA,IMG] = load_echoes(fullname,ntraces_begin,ntraces_end);
% INPUTS: 1: name of the fid file
% OPTIONAL: 2: beginning slice to output 3: end slice to output
 
fid = fopen(fullname,'r','ieee-be');
%fid = fopen(fullname,'r');
 
% Read datafileheader
nblocks   = fread(fid,1,'int32');
ntraces   = fread(fid,1,'int32');
np        = fread(fid,1,'int32');
ebytes    = fread(fid,1,'int32');
tbytes    = fread(fid,1,'int32');
bbytes    = fread(fid,1,'int32');
vers_id   = fread(fid,1,'int16');
status    = fread(fid,1,'int16');
nbheaders = fread(fid,1,'int32');

 
s_data    = bitget(status,1);
s_spec    = bitget(status,2);
s_32      = bitget(status,3);
s_float   = bitget(status,4);
s_complex = bitget(status,5);
s_hyper   = bitget(status,6);
 
clear ebytes tbytes bbytes vers_id nbheaders status s_data s_spec s_complex s_hyper


%ntraces are slices
%nblocks are phase encodes
%np are readout*2 (because of complex data)
%but it is ordered np,ntraces,nblocks
%there is a header inbetween every block
if s_float == 1
    read_size=np*ntraces*nblocks+7*nblocks;
    data = fread(fid,read_size,'*float32');
elseif s_32 == 1
    read_size=np*ntraces*nblocks+7*nblocks;
    data = fread(fid,read_size,'*int32');
else
    read_size=np*ntraces*nblocks+14*nblocks;
    data = fread(fid,read_size,'*int16');
end
fclose(fid);

if exist('ntraces_end')==0
    ntraces_begin=1;
    ntraces_end=ntraces;
end
% ntraces_begin
% ntraces_end
% ntraces
% np
% ntraces
% nblocks
data=reshape(data,np*ntraces+7,nblocks);
data=data(8:np*ntraces+7,:);

% if nargin==1
data=complex(data((ntraces_begin-1)*np+1:2:np*ntraces_end,:),data((ntraces_begin-1)*np+2:2:np*ntraces_end,:));
%     data=complex(data(8:2:np*ntraces+7,:),data(9:2:np*ntraces+7,:));
% KDATA=permute(reshape(data,np/2,ntraces_end-ntraces_begin+1,nblocks),[1 3 2]);
KDATA=reshape(data,np/2,ntraces_end-ntraces_begin+1,nblocks);
% else
%     cdata=[];
%     for j=0:ntraces-1
% 
%         
%     end
% end



%use the following for display
%imshow(fftshift(abs(ifft2(kdata(:,:,45)))),[]);

if nargout>1
    IMG=fftshift(abs(ifft2(KDATA)));
end
