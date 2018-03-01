%�������ַ�ʽ��ͬ
%
%
N=64;
x=rectwin(31);
%���������λͼ
freqz(x,1,N);

%
%����Ƶ�׺͸�������Ƶ��
%[h,w]=freqz(x,1,N);%�ȼ����¼���
h = fft(x,N*2);
h = h(1:N);
w = linspace(0,pi-pi/N,N);

figure;
%�����ͼ
subplot(211);
plot(w/pi,abs(h))
ylabel('����(dB)')
xlabel('��һ��Ƶ��(\times\pi rad/sample)')
grid on;

%����λͼ
subplot(212);
plot(w/pi,angle(h)*180/pi);
ylabel('��λ(�Ƕ�)')
xlabel('��һ��Ƶ��(\times\pi rad/sample)')
grid on;

