%�������ݼ�
format long
fs_list=[8000;16000;16000];
dir_list=['pcm/g7_voice_06/';'pcm/my_voice_01/';'pcm/my_voice_02/';];
test=1;
%-----------------------
%��ȡ�ź�����Ϊ������
% rrin = Զ���ź�
% ssin = �����ź�
%-----------------------
dir=dir_list(test, :);
fs=fs_list(test);
fid=fopen([dir 'farend.pcm'], 'rb');
rrin=fread(fid,inf,'int16');
fclose(fid);

fid=fopen([dir 'aec_near.pcm'], 'rb');
ssin=fread(fid,inf,'int16');
fclose(fid);

%ÿ��ȡ64���������ϴ�һ������,64*2������ֵ,FFT��õ���ЧƵ��(65���������)
% N  = ÿ�δ����������
% Nb = �ܹ��������
% M  = ���36��Ƶ��,��ΪNLMS�㷨��ͷ,NLMS�Ľ���
%-----------------------
N=64;
M=36;
len=length(ssin);
Nb=floor(len/N)-M; %�������
%-----------------------
S = EchoCancellation;
S.N=N;
S.M=M;
S.fs=fs;
S.NLP=1;
%-----------------------
fid = fopen([dir 'aecOut.pcm'], 'wb');
for kk=1:Nb
    pos = N * (kk-1) + 1;
    [S,r] = EchoCancellation(S,rrin(pos:pos+N-1), ssin(pos:pos+N-1));
    fwrite(fid, r, 'int16');  
end
fclose(fid);
