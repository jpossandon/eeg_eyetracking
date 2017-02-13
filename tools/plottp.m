function plottp(cfg)


figure,
set(gcf,'Position',[32 140 1145 565])
subplot(2,2,1)
plot(cfg.foi,cfg.t_ftimwin,'.-'),hold all
set(gca,'XTick',0:5:max(cfg.foi))
axis([0 max(cfg.foi) 0 max(cfg.t_ftimwin)])
grid on
xlabel('Frequency (Hz)')
ylabel('Time Window (s)')

subplot(2,2,2)
plot(cfg.foi,cfg.tapsmofrq,'.-')
set(gca,'XTick',0:5:max(cfg.foi))
axis([0 max(cfg.foi) 0 max(cfg.tapsmofrq)])
grid on
xlabel('Frequency (Hz)')
ylabel('BandWidth (Hz)')

subplot(2,2,3)
numtapers                   = 2.*cfg.t_ftimwin.*cfg.tapsmofrq-1;

plot(cfg.foi,numtapers,'.-')
set(gca,'XTick',0:5:max(cfg.foi))
axis([0 max(cfg.foi) 0 2*max(numtapers)])
grid on
xlabel('Frequency (Hz)')
ylabel('# tapers')