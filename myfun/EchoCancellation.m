function [S,e] = EchoCancellation(S,x,d)
%������������������
% ���������ɷֳɵĶ�����̺���������
% �Խ����źŽ��л�������,����x��d��ʱ�����Ѷ���
%   S   = ����ʵ��
%   x   = Զ��ʱ���ź�,N������
%   d   = ����ʱ���ź�,N������
% ���ظù��̶���,�����������ź�(����������)
%��ʼ�����ò���
%   S.fs �źŲ���Ƶ��
%   S.N  ÿ�δ���Ĳ�������
%   S.M  NLMS ����
%   S.NLP �������˲�����[1,3]
if nargin == 0 %��������
    if nargout > 1; error('Redundant output parameters'); end
    %Ĭ�ϵ����ò���
    S.fs = nan; S.N = 64; S.M=36; S.NLP = 1; 
    %��̬����
    S.xfwBuf = nan;
    return;
elseif nargin < 3
    error('Insufficient input parameters')
end

%��ʼ��
if isnan(S.xfwBuf); S = AecCore_Initialize(S); end

%����Զ��Ƶ��
S.xBuf=[S.xBuf([end/2+1:end]);x];%���ϴκϲ���,2N������
xf = TimeToFrequency(S.xBuf); %Զ��Ƶ��,N+1������
xfw= TimeToFrequency(S.xBuf, true);%Զ�˼Ӵ�Ƶ��,N+1������

%�������
[S,e] = AecCore_ProcessBlock(S, d, xf);

%�������˲�
[S,e] = AecCore_NonLinearProcessing(S, e, xfw);

% ����
% amplitude ���
% power     ����
