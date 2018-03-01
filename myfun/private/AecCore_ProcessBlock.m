function [S,e]=AecCore_ProcessBlock(S,d,xf)
% ����������NLMS ��һ����С��������Ӧ�˲��㷨 
%   S   = ����ʵ��
%   d   = ����ʱ���ź�,N������
%   xf  = Զ��Ƶ��,N+1������
% ----------------------
S.dBuf=[S.dBuf([end/2+1:end]);d];%���ϴκϲ���,2N������.��������,��Ӧaec.dBuf
% S.xPow = ƽ��Զ�˹�����,N+1����ЧƵ������
% df = ����Ƶ��,N+1������
% ------------------------  Power estimation
df = TimeToFrequency(S.dBuf);
far_power_spectrum = xf.* conj(xf);%Զ�˹�����,��ģƽ��=abs(xf)^2;
near_power_spectrum = df.*conj(df);
S.xPow = 0.9*S.xPow + 0.1*S.M*far_power_spectrum;
S.dPow = 0.9*S.dPow + 0.1*near_power_spectrum;

%TODO Estimate noise power. Wait until dPow is more stable.

%TODO Smooth increasing noise power from zero at the start,
%     to avoid a sudden burst of comfort noise.

%TODO ProcessHowling
%S=ProcessHowling(S, far_power_spectrum, near_power_spectrum);

% NLMS - ��һ����С��������Ӧ�˲��㷨
% *** ��Ƶ���Ͻ���,����Ӧ�˲�
% xfBuf = �����˲�����Χ�ڵ�Զ��Ƶ��,�������M��xf,ÿ�ж�ΪԶ��Ƶ��, N+1xM ����
% wfBuf = ����Ӧ�˲�ϵ������,ÿ����Ϊг��Ƶ��(M����ͷ)Ȩ��ϵ��,N+1xM ����
%         ��xfBuf��M��Զ��Ƶ��,ÿ�����ض�г��Ƶ��.
%         ��������M����г��Ƶ�׽��м�Ȩ���,���ǻ���Ƶ�׹���.
% yf = ���ƵĻ����ź�Ƶ��,N+1������.
% y  = ���ƵĻ����ź�,N������
% ----------------------   Filtering 
S.xfBuf = [xf,S.xfBuf(:,1:end-1)];% �������M��Զ��г��Ƶ��,N+1 x M ����
yf = FilterFar(S);%N+1������
ykt = FrequencyToTime(yf);
y = ykt(end/2+1:end);%�任ǰ��ǰһ����������,�ʱ��������ں�һ�� 

% e = �����ź���������Ƶ����,�������������,N������
% ef = ������Ƶ��,N+1������
% erfb = ���л���������������ź�
% ----------------------   Error estimation 
e = d - y; %ʵ�ʽ����ź���������Ƶ����,����������

%TODO �������Ƶ��,ǰ��Ϊ�β�0, �ϴ����ǿ��Ϊ0?
ef = TimeToFrequency([zeros(size(e));e]);% FD version for cancelling part (overlap-save)

ef = ScaleErrorSignal(S, ef);
S = FilterAdaptation(S, ef);%����Ȩ��wfBuf

%--------------------------------------------------------------------------
function yf=FilterFar(S)
%��ÿ��M��г��Ƶ��,��Ȩ��,�������,N+1������.��ӦC����FilterFar()
%����ͬʱ����N+1�ε�NLMS�˲�
yf = sum(S.xfBuf .* S.wfBuf, 2);

%--------------------------------------------------------------------------
% NLMS ������ʽ 
%      W[k] = W[k-1] + 2pX'D = W + aX'D/(X'X+b)
% �˴� b=1e-10, X'X=S.xPow, a=S.mu
function ef=ScaleErrorSignal(S,ef)
ef = ef./(S.xPow + 1e-10);
absEf = abs(ef);
idx = find(absEf > S.errThresh);
if ~isempty(idx)
    ef(idx) = ef(idx)*S.errThresh./(absEf(idx)+1e-10);
end
ef = ef.*S.mu;

%--------------------------------------------------------------------------
function S=FilterAdaptation(S,ef)
PP = conj(S.xfBuf).*repmat(ef, 1, S.M); %xfBufΪN+1xM��,efΪN+1������
%TODO ifft/fft? Ϊʲô����PPֱ����ΪFPH
IFPP = FrequencyToTime(PP);%ʱ���ź�2NxM��
IFPP(end/2+1:end,:)=0;%ֻȡ�ϰ벿��ʱ��
FPH = TimeToFrequency(IFPP);
S.wfBuf = S.wfBuf + FPH;
