function s=FrequencyToTime(f,w)
% ���ٸ�����任,Ƶ��ʱ�����ֵ
%   f ��Ƶ��,����
%   w �����Ӵ�
% ����
%   s ����ֵ,����Ϊf��2��-2
%
f = [f ; flipud(conj(f(2:end-1,:)))];%��ȫƵ��,��Ӧifft����Ҫ��
s = real(ifft(f));
if nargin > 1 & w
    sqrtHanning=[0;sqrt(hanning(length(s)-1))];%��sqrtHanning[N+1]==1,���Դ�Ϊ���ĶԳ�
    s = s.*sqrtHanning;
end
%------------��ӦC�����
% aec_rdft_inverse_128(float fft[128])
% fft ����65������,���128������, ����NOSCALE,�����Ҫ�ֹ�����
% ����:
%   fft[0] = xf[0][0];
%   fft[1] = xf[0][64];
%   for (i = 1; i < 64; i++) {
%       fft[2 * i] = xf[0][i];
%       fft[2 * i + 1] = xf[1][i];
%   }
%   aec_rdft_inverse_128(fft);
%   // fft scaling
%   {
%     float scale = 2.0f / 128;
%     for (j = 0; j < 128; j++)
%       fft[j] *= scale;
%   }
