%LMSʹ��ʾ��
% ��С��������Ӧ�˲��㷨,�������ͳ�������Զ������˲�,ʹ��ӽ�����

%�����źŵĲ���
N=128;
M=16;%�˲����Ľ���
t=1:N;
xn=sin(0.5*t);%�����Զ�˲ο��ź�
yn=rand*xn;%��Զ���߳���صĻ���
en=0.5*cos(3*t)+0.4*sin(7*t+30);%���������ź�
dn=yn+en; %�����Ľ��������ź�(����+��������+��������)
%��֪Զ�˲ο��ź�xn�ͽ��������ź�dn,�󱾵������ź�en�����Ź���

%lms
S1=LeastMeanSquare;
S1.M=M;
%ѡȡ��������
S1.p=rand/max(eig(xn.'*xn)); %�����ź���ؾ�����������ֵ�ĵ���

%NLMS ��������=0.1
S2=LeastMeanSquare;
S2.M=M;
S2.p=[0.1,0.0001];

%NLMS ��������=0.2
S3=LeastMeanSquare;
S3.M=M;
S3.p=[0.2,0.0001];

%�����˲�
y1=[];y2=[];y3=[];
e1=[];e2=[];e3=[];
for i=1:N
    [S1,y1(end+1),e1(end+1)]=LeastMeanSquare(S1,xn(i),dn(i));
    [S2,y2(end+1),e2(end+1)]=LeastMeanSquare(S2,xn(i),dn(i));
    [S3,y3(end+1),e3(end+1)]=LeastMeanSquare(S3,xn(i),dn(i));
end

%��ͼ
figure;
plot(t,en-e1,'r', t,en-e2,'g', t, en-e3,'k');
title('���: ����=LMS,����=NLMS(0.1),��ɫ=NLMS(0.2)')
