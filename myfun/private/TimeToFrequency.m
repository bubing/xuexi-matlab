function f=TimeToFrequency(s,w)
% ���ٸ��ϱ任,ʱ�����ֵ��Ƶ��
%   s ����ֵ
%   w �����Ӵ�
% ����
%   f ��Ƶ��,����,����Ϊs��һ��+1
%
if nargin > 1 & w
    sqrtHanning=[0;sqrt(hanning(length(s)-1))];%��sqrtHanning[N+1]==1,���Դ�Ϊ���ĶԳ�
    f = fft(s.*sqrtHanning);
else
    f = fft(s);
end
%��Ϊf(2:2N)��ֱ�������ǶԳƵ�,ȥ������ĶԳƷ���
f= f(1:end/2+1, :);
%------------��ӦC�����
% aec_rdft_forward_128(float fft[128])
% fft ����128������, ���65������,����SCALE
% ����:
%   aec_rdft_forward_128(fft);
%   xf[2][65];//xf[0]Ϊʵ��,xf[1]Ϊ�鲿
%   xf[1][0] = 0;
%   xf[1][64] = 0;
%   xf[0][0] = fft[0]; //xf[0][0],xf[0][64]Ϊֱ������.
%   xf[0][64] = fft[1];
%   for (i = 1; i < 64; i++) {
%       xf[0][i] = fft[2 * i];
%       xf[1][i] = fft[2 * i + 1];
%   }

