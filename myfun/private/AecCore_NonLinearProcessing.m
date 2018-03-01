function [S,e]=AecCore_NonLinearProcessing(S,e,xfw)
% ���������з������˲�
%  S    = ������������
%  e    = ���Ƶı�������,����ź�
%  xfw  = Զ�˼Ӵ�Ƶ��,N+1������
% ���ػ����������̶���ʹ���������

%���ϴκϲ���,2N������.��������,��Ӧaec.eBuf
S.eBuf = [S.eBuf([end/2+1:end]);e]; 

% ------------------------
% xfw = Զ�˼Ӵ�Ƶ��
% dfw = ���˼Ӵ�Ƶ��
% efw = ���Ӵ�Ƶ��
% xfwBuf = �����˲�����Χ�ڵ�Զ��Ƶ��,�������M��xfw,ÿ�ж�ΪԶ��Ƶ��, N+1xM ����
S.xfwBuf=[xfw, S.xfwBuf(:,1:end-1)];

%�Ӵ�,����Ƶ������й©.
dfw = TimeToFrequency(S.dBuf,true);
efw = TimeToFrequency(S.eBuf,true);
% ------------------------
%TODO Ϊʲô��� 10*S.mult, ���80 ms
% 8kHzʱ,ÿ�δ��� S.M/8=8 msʱ������.
S.delayEstCtr = S.delayEstCtr+1;
if S.delayEstCtr == 10 * S.mult
    S.delayEstCtr = 0;
    % xfw��dfw�ļ򵥶����㷨. ��LMSԭ���
    % ϵ��������Ȩ�������,������Ϊ��Ӧ��,��ǰ�ο��ź�
    wfEn = sum(S.wfBuf.*conj(S.wfBuf));%ϵ��������,��ģƽ��=abs(WFb)^2
    [wfEnMax, S.delayIdx] = max(wfEn);%wfEnMaxΪ�������,delayIdxΪ�������
end
xfw = S.xfwBuf(:,S.delayIdx);%ʹ�ü򵥶�����Զ�˼Ӵ�Ƶ��

% ---------- Power estimate smoothing
% .sd = ���˹�����
% .se = ������
% .sx = Զ�˹�����
% sdSum = ���˹���
% seSum = ����
gCoh = [0.9, 0.1;0.93, 0.07];
gamma = gCoh(S.mult, :);%ƽ��ϵ��
% Smoothed PSD
S.sd  = gamma(1)*S.sd  + gamma(2)*(dfw.*conj(dfw));
S.se  = gamma(1)*S.se  + gamma(2)*(efw.*conj(efw));
% We threshold here to protect against the ill-effects of a zero farend.
% The threshold is not arbitrarily chosen, but balances protection and
% adverse interaction with the algorithm's tuning.
% TODO: investigate further why this is so sensitive.
S.sx  = gamma(1)*S.sx  + gamma(2)*max(xfw.*conj(xfw),15);
S.sde = gamma(1)*S.sde + gamma(2)*efw.*conj(dfw);
S.sxd = gamma(1)*S.sxd + gamma(2)*xfw.*conj(dfw);
sdSum = sum(S.sd);
seSum = sum(S.se);

% ---------- Divergent filter safeguard(��ɢ����)
% .divergeState  = ���������Ƿ�ɢ
if S.divergeState == 0
    % ����(seSum) > ���˹���(sdSum)ʱ,��Ϊ��ɢ
    if seSum > sdSum; S.divergeState = 1; end
else
    if seSum*1.05 < sdSum;  S.divergeState = 0; end
end
% ����ɢ��,ֱ��ʹ�ý�������.
if S.divergeState == 1; efw = dfw; end

% Reset if error is significantly larger than nearend (13 dB).
if seSum > sdSum*19.95; S.wfBuf=zeros(size(S.wfBuf)); end % Block-based FD NLMS
% ------------------------ ����
targetSupp = [-6.9, -11.5, -11.5]; %-6.9f, -11.5f, -18.4f
minOverDrive = [1.0, 3.0, 5.0];
PREF_BAND_SIZE = 24;
prefBandQuant = 0.75;
prefBandQuantLow = 0.5;
prefBandSize = PREF_BAND_SIZE / S.mult;
minPrefBand  = 4 / S.mult + 1;
maxPrefBand  = minPrefBand + prefBandSize-1;

% ---------- Subband coherence(һ����)
% cohde = �������������,ֵԽ��,����ԽС
% cohxd = Զ������������,ֵԽ��,����Խ��
% ��ΪN+1������,��Χ��[0,1]
% ����Լ��㹫ʽ: (a.*b)^2/ (a^2 .* b^2)
cohde = S.sde.*conj(S.sde)./(S.se.*S.sd + 1e-10);
cohxd = S.sxd.*conj(S.sxd)./(S.sx.*S.sd + 1e-10);

%-----------
% hNlDeAvg = Ϊ����������Ծ�ֵ,Խ��Խ��
% hNlXdAvg = ΪԶ�˽��˲�����Ծ�ֵ,Խ��Խ��.
% ��ΪN+1������,��Χ��[0,1]
% ��ֵ���㶼ѡȡ�˲���Ƶ��[minPrefBand:maxPrefBand]
% ����FFT����,��Ƶi,��ӦƵ�� 2(i-1)/N * fs, ��
%   minPrefBand->8/64*fs/S.mult=8k/8=1k
%   maxPrefBand->56/64*fs/S.mult=7k
% ����, 8kHz��16kHzʱ,��ѡȡ[1k,7k]Hz
% ע����ͨ�������������Χ[20,20k]Hz
hNlDeAvg = sum(cohde(minPrefBand:maxPrefBand))/prefBandSize;
hNlXdAvg = 1 - sum(cohxd(minPrefBand:maxPrefBand))/prefBandSize;


% .hNlXdAvgMin = hNlXdAvg����Сֵ,�Զ������󲢱�����
if hNlXdAvg < 0.75 & hNlXdAvg < S.hNlXdAvgMin
    S.hNlXdAvgMin = hNlXdAvg;
end

% .stNearState = �Ƿ�ֻ�н����ź�
if hNlDeAvg > 0.98 & hNlXdAvg > 0.9 %���/���˸߶����,Զ��/���˸߶Ȳ����
    S.stNearState = 1;
elseif hNlDeAvg < 0.95 | hNlXdAvg < 0.8
    S.stNearState = 0;
end

%-----------
% .echoState = �Ƿ���ڻ���
% hNl = �������������cohde,������Զ�˲������(1 - cohxd),���н�С��ֵ
% hNlFb = hNl�����ֵ
% hNlFbLow = hNl�е���С��ֵ
if S.hNlXdAvgMin == 1  %Զ�˽��˲����,��û�л���
    %��ʼ���״ν���
    S.echoState = 0;
    S.overDrive = minOverDrive(S.NLP);
   if S.stNearState == 1
       hNl = cohde;
       hNlFb = hNlDeAvg;
       hNlFbLow = hNlDeAvg;
    else
       hNl = 1 - cohxd;
       hNlFb = hNlXdAvg;
       hNlFbLow = hNlXdAvg;
    end
else % hNlXdAvgMin != 1
    if S.stNearState == 1 % ���ǽ����ź�
       S.echoState = 0;
       hNl = cohde;
       hNlFb = hNlDeAvg;
       hNlFbLow = hNlDeAvg;
    else
       S.echoState = 1;
       hNl = min(cohde, 1-cohxd);
       %Select an order statistic from the preferred bands.
       %�Ӵ������������
       hNlPref = sort(hNl(minPrefBand:minPrefBand+prefBandSize));
       hNlFb = hNlPref(floor(prefBandQuant * prefBandSize));
       hNlFbLow = hNlPref(floor(prefBandQuantLow * prefBandSize));
    end
end %hNlXdAvgMin == 1


%TODO Ϊʲô������.hNlXdAvgMin(Խ��Խ��)
S.hNlXdAvgMin = min(S.hNlXdAvgMin + 0.0006 / S.mult, 1);

%-----------
% Track the local filter minimum to determine suppression overdrive.
% .hNlFbLocalMin = hNlFbLow����Сֵ(Խ��Խ��), �Զ������󲢱�����
if hNlFbLow < 0.6 & hNlFbLow < S.hNlFbLocalMin
    % �������˵�����Ա�С,���ֻ����Ŀ����Ժܴ�
    S.hNlFbLocalMin = hNlFbLow;
    S.hNlFbMin = hNlFbLow;
    S.hNlNewMin = true;%�������״̬
    S.hNlMinCtr = 0;%������0
end
%TODO Ϊʲô������.hNlFbLocalMin
S.hNlFbLocalMin = min(S.hNlFbLocalMin + 0.0008 / S.mult, 1);

if S.hNlNewMin
    S.hNlMinCtr = S.hNlMinCtr+1;
    if S.hNlMinCtr == 2 %��������2ʱ,��λ
        S.hNlNewMin = 0;
        S.hNlMinCtr = 0;
        %TODO ΪʲôҪ����,�ﵽ��ʱ����.overDrive ��Ŀ��
        S.overDrive = max(targetSupp(S.NLP)/(log(S.hNlFbMin + 1e-10) + 1e-10), minOverDrive(S.NLP));
    end
end

%-----------
% Smooth the overdrive.
if S.overDrive < S.overDriveSm
    S.overDriveSm = 0.99 * S.overDriveSm + 0.01 * S.overDrive;
else
    S.overDriveSm = 0.9 * S.overDriveSm + 0.1 * S.overDrive;
end
efw = OverdriveAndSuppress(S, hNl, hNlFb, efw);

% Overlap and add to obtain output.
tmp = FrequencyToTime(efw, true);
e = tmp(1:end/2) + S.outBuf;
S.outBuf = tmp(end/2+1:end);
%--------------------------------------------------------------------------
%��Ƶ����
function [efw,hNl]=OverdriveAndSuppress(S, hNl, hNlFb, efw)
% hNl = �������������,[0,1]
% hNlFb = ��ֵ
% efw = 
%  .overDriveSm
% ------------------------ ����
weightCurve = [0 ; 0.3 * sqrt(linspace(0,1,64))' + 0.1]; %������ֵ��Ȩ����, �������ƹ���ֵ
overDriveCurve = [sqrt(linspace(0,1,65))' + 1]; %��Ƶ��ָ����

idx = find(hNl > hNlFb);
if ~isempty(idx)
    % hNl�г��� hNlFb��ֵ,����S.weightCurve���м�Ȩ
    % Ŀ��:  ���Խ������г�����ֵ��ֵ.
    hNl(idx) = weightCurve(idx).*hNlFb + (1-weightCurve(idx)).*hNl(idx);
end
%
hNl = hNl.^(S.overDriveSm * overDriveCurve);
%Ƶ�����൱��ʱ����,���൱������ź�ͨ���˴��ݺ���ΪhNl���˲���
efw = efw .* hNl;
