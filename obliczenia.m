close all

%==================== IDENTYFIKACJA =======================%
% wartości nominalne
TwewN = 20;     %oC
TgpN = 70;      %oC
TzewN = -20;    %oC
TgzN = 90;      %oC
QgN = 2000;    % moc grzałki W
QtN = 0;        % moc "wyłączonej" grzałki W
TwzN = 130;     %oC
TwpN = 110;     %oC
TozN = TgzN;    %oC
TopN = TgpN;    %oC


Vw = 10*6*2;   % pojemnośc pokoju m^3
Vg = 1*0.5*0.25; % pojemność grzałki m^3
Vvo1 = 1;     % pojemność 1 połowy węzła ciepłowniczego m^3
Vvo2 = 1;     % pojemność 2 połowy węzła ciepłowniczego m^3

Cpw = 1000;     % ciepło własiściwe powietrza J/(kg*K)
Cmg = 4175;     % ciepło własiściwe wody J/(kg*K)
Row = 1.2;      % gęstość powietrza kg/m^3
Rog = 960;      % gęstość wody kg/m^3

%-----------------------
% identyfikacja parametrów statycznych
FmgN = QgN/(Cpw*(TgzN - TgpN));
Kcg = QgN/(TgpN-TwewN);                         
Kcw = QgN/(TwewN-TzewN);
Kco = 2*QgN/(TwpN-TozN);
FmwN = Kco*(TwpN - TozN)/(Cpw*(TwzN - TwpN));
FmoN = Kco*(TwpN - TozN)/(Cpw*(TozN - TopN));

%-----------------------
% identyfikacja parametrów dynamicznych
Cvw = Cpw*Row*Vw*2;       % pojemność cieplna powietrza w pokoju
                          % 2 - chcemy zwiekszyc znaczenie ścian
Cvg = Cmg*Rog*Vg;         % pojemność cieplna grzejnika
Cvo1 = Cvg;    
Cvo2 = Cvg;    

%-----------------------
% sprawdzenie
assert(Kcg > 0, "Ujemny współczynik przenikania")
assert(Kcw > 0, "Ujemny wspólczynnik przenikania")
assert(0 == (Kcg*(TgpN - TwewN) - Kcw*(TwewN-TzewN)), "Rownania statyczne nierowne")
assert(0 == (Cpw*FmgN*(TgzN-TgpN)-Kcg*(TgpN - TwewN)), "Rownania statyczne nierowne")

%==================== PUNKT PRACY =======================%
% warunki początkowe
Tzew0 = TzewN + 0;  % 0 - nominalne
Tgz10 = TgzN + 0;    % 0 - nominalne
Tgz20 = TgzN + 0;    % 0 - nominalne
Qg0 = QgN*1.0;      % 1.0 - nominalne
Fmg0 = FmgN*1.0;    % 1.0 - nominalne
Twz0 = TwzN + 0;    % 0 - nominalnie

Fmg10 = Fmg0;
Fmg20 = Fmg0;
Fmw0 = FmwN;

T0 = 0; % s opoznienie czasowe

% stan równowagi        (dla nominalnych warubkowpoczatkowcyh Twew0 = TwewN i Tgp0 = TgpN)
Twew10 = (Cpw*Fmg10 *Kcg*Tgz10 + Kcw*(Kcg + Cpw*Fmg10)*Tzew0)/(Kcg*Kcw + Cpw*Fmg10*(Kcg + Kcw));
Twew20 = (Cpw*Fmg20 *Kcg*Tgz20 + Kcw*(Kcg + Cpw*Fmg20)*Tzew0)/(Kcg*Kcw + Cpw*Fmg20*(Kcg + Kcw));
Tgp10 = ((Kcg + Kcw)*Twew10 - Kcw*Tzew0)/(Kcg);
Tgp20 = ((Kcg + Kcw)*Twew20 - Kcw*Tzew0)/(Kcg);

Top0 = TopN;  % PRZYBLIZENIE 3
Toz0 = TozN; % Fmg0*Kco/(Kco*Fmg0 + Cpw*Fmg0*Fmg0 + Kco*Fmg0)*(Twz0 + (Cpw*Fmg0)*Top0/(Kco)); % JESLI JEST ZLE PRZYJMIN TozN
Twp0 = TwpN; % (Cpw*Fmg0+Kco)*Toz0/Kco - (Cpw*Fmg0 + Kco)*Top0/Kco; % JEŚLI JEST ŹLE PRZYJMIJ TwpN

SumT0 = (Tgp10*Fmg10 + Tgp20*Fmg20)/(Fmg10 + Fmg20);

%==================== SYMULACJE =======================%
%symulacja
tmax = 200000;  % czas symulacji

%zaklocenia
tsok = 2000; % czas skoku
dFmg = 0;
dTzew = 0;
dQt = 0;
dTwz = 0;
dFmw = 0.0200000000000000;

figure(1) ;

model='model_rownan';
[t]=sim(model,tmax);    % t - wektor czasu
%wykresy
plot(t, Twew1, 'r'), grid on;
hold on;
plot(t, Twew2, 'g--');
figure(2) ;
plot(t, Top, 'c');
hold on;

dFmg = 0;
dTzew = 0;
dQt = 0;
dTwz = 1;
dFmw = 0;

model='model_rownan';
[t]=sim(model,tmax);    % t - wektor czasu
%wykresy
figure(1) ;
plot(t, Twew1, 'b'), grid on;
hold on;
plot(t, Twew2, 'c--');
figure(2) ;
plot(t, Top, 'r');

dFmg = 0;
dTzew = 0;
dQt = 0;
dTwz = 0;
dFmw = 0.1*FmwN;

model='model_rownan';
[t]=sim(model,tmax);    % t - wektor czasu
%wykresy
figure(1) ;
plot(t, Twew1, 'm'), grid on;
hold on;
plot(t, Twew2, 'k--');
figure(2) ;
plot(t, Top, 'm');

figure(1) ;
title("Reakcja Twew na skoki o 10%Fmw i o 1 ^oC");
xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
legend('Twew1 - skok dTzew','Twew2- skok dTzew', ...
    'Twew1 - skok dTwz','Twew2- skok dFmw', ...
    'Twew1 - skok dTwz','Twew2- skok dFmw');
figure(2) ;
title("Reakcja Top na skoki o 10%Fmw i o 1 ^oC");
legend('skok dTzew','skok dTwz', 'skok dTwz');
xlabel("t[s]"), ylabel("Top[^{\circ}C]");




%==================== IDENTYFIKACJ =======================%
k1 = (20.2553 - 20)/0.0100000000000000;
Topu1 = 5820- 2000;
Tczas1 = 25390-Topu1;

k2 = (20.2553 - 20)/0.0100000000000000;
Tczas2 = 21425-11955;
Topu2 = 21425 - Tczas2;


% figure, plot(t, Twew1, 'r'), grid on, title("Identyfikacja obiektu");
% xlabel("t[s]"), ylabel("Twew1[^{\circ}C]");
% hold on;
% modelPrzeg='identyfikacja';
% [t]=sim(modelPrzeg,tmax);    % t - wektor czasu
% % wykresy
% plot(t, TwewId1, 'b');
% plot(t, TwewId2, 'g');
% legend('obiekt rzeczywisty','identyfikacja - pkt przegiecia','identyfikacja - metoda dwupkt');


%==================== STEROWANIE =======================%
%%%%%%%%%%%%%%%%%%%%%%%%%%         nastawy z metody stycznej
% wartosc zadana 
dTwew = 1;

% nastawy regulacji
Kp = 0.9*Tczas1/(k1*Topu1);
Ki = 1;
Ti = 3.33*Topu1/Kp;

%wykresy
% modelSt='sterowanie';
% [t]=sim(modelSt,tmax);    % t - wektor czasu
% figure, plot(t, TwewSt1, 'r'), grid on, title("Sterowanie Twew1 z wykorzystaniem nastaw z identyfikacji ze styczną");
% xlabel("t[s]"), ylabel("Twew1[^{\circ}C]");
% hold on;
% 
% modelOb='obiekt_sterowanie';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'g');
% 
% legend('model - pkt przegiecia', 'obiekt rzeczywisty');
% 
% hold off;
% 
% figure, plot(t, Twew1, 'g');
% grid on, title("Sterowanie Twew1 - porownanie na obiekcie");
% xlabel("t[s]"), ylabel("Twew1[^{\circ}C]");
% hold on;
% %%%%%%%%%%%%%%%%%%%%%%%%%%        nastawy z metody dwupunktowa
% % nastawy regulacji
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;
% 
% %wykresy
% 
% modelOb='obiekt_sterowanie';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'b');
% legend('model - metoda styczna','model - metoda dwupkt');
% hold off;
% 
% figure,plot(t, Twew1, 'b');
% hold on;
% modelSt='sterowanie';
% [t]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t, TwewSt2, 'k') , grid on, title("Sterowanie Twew1 z wykorzystaniem nastaw z identyfikacji dwupunktowej");
% xlabel("t[s]"), ylabel("Twew1[^{\circ}C]");
% 
% legend('obiekt rzeczywisty', 'model - metoda dwupkt');
% 





