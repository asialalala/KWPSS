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
tmax = 100000;  % czas symulacji

%zaklocenia
tsok = 2000; % czas skoku
dFmg = 0;
dTzew = 0;
dQt = 0;
dTwz = 0;
dFmw = 0;


%==================== IDENTYFIKACJ =======================%
k1 = (20.2553 - 20)/0.0100000000000000;
Topu1 = 5820- 2000;
Tczas1 = 25390-Topu1;

k2 = (20.2553 - 20)/0.0100000000000000;
Tczas2 = 21425-11955;
Topu2 = 21425 - Tczas2;

%==================== STEROWANIE =======================%
%%%%%%%%%%%%%%%%%%%%%%%%%%         nastawy z metody stycznej
% wartosc zadana 
dTwew = 1;

% nastawy regulacji styczna
% Kp = 0.9*Tczas1/(k1*Topu1);
% Ki = 1;
% Ti = 3.33*Topu1/Kp;



% % nastawy regulacji dwupunktowa
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;


%-------------- porownanie pomieszczen ---------------
% % nastawy regulacji styczna
% Kp = 0.9*Tczas1/(k1*Topu1);
% Ki = 1;
% Ti = 3.33*Topu1/Kp;
% 
% modelOb='obiekt_sterowanie';
% f1=figure(1);
% f1.Position = [0,0,1400,1000];
% clf(f1);
% subplot(2,1,1);
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'b');
% hold on, grid on;
% plot(t, Twew2, 'g--');
% 
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% title("ZN URO (styczna)")
% legend('Twew1', 'Twew2');
% hold off;
% 
% figure(1);
% subplot(2,1,2);
% hold on, grid on;
% plot(t, CvO, 'r');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% title("Cv ZN URO")
% legend( 'CV');
% hold off;
% 
% 
% % nastawy regulacji styczna
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;
% 
% f2=figure(2);
% f2.Position = [0,0,1400,1000];
% clf(f2);
% figure(2);
% subplot(2,1,1);
% modelOb='obiekt_sterowanie';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'g');
% hold on, grid on;
% plot(t, Twew2, 'b--');
% 
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% title("ZN, URO (dwupunktowa)");
% legend('Twew1', 'Twew2');
% hold off;
% 
% figure(2);
% subplot(2,1,2);
% hold on, grid on;
% plot(t, CvO, 'r');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% title("Cv ZN, URO (dwupunktowa)")
% legend( 'CV');
% hold off;


%------------------ porownanie metod -------------------

% % nastawy regulacji styczna
% Kp = 0.9*Tczas1/(k1*Topu1);
% Ki = 1;
% Ti = 3.33*Topu1/Kp;
% 
% modelOb='obiekt_sterowanie_tune';
% disp("err") 
% err
% disp("err2")
% err2


% modelSt='sterowanie';
% [t]=sim(modelSt,tmax);    % t - wektor czasu
% f3=figure(3);
% f3.Position = [0,0,1400,1000];
% clf(f3);
% figure(3);
% subplot(2,1,1);
% plot(t, TwewSt1, 'r'), grid on, hold on; 
% 
% % nastawy regulacji dwupunktowa
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;
% 
% plot(t, TwewSt2, 'b');
% 
% % nastawy regulacji z tune
% plot(t, TwewSt1Mat, 'g');
% 
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend('PV dla modelu z pkt przegiecia własy PID', ...
%     'PV dla modelu z metodu dwupunktowej własny PID', ...
%     'PV dla modelu z tune');
% title("porownanie sterowania dla doboru nastaw z dwuch metod identyfikacji i tune")
% hold off;
% 
% figure(3);
% subplot(2,1,2);
% hold on, grid on;
% plot(t, CvSt1, 'r--');
% plot(t, CvSt2, 'b--');
% plot(t, Cv1Mat, 'g--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% title("Sterowanie wyznaczaone metoda stycznych")
% legend('CV dla modelu z pkt przegiecia własy PID', ...
%     'CV dla modelu z metodu dwupunktowej własny PID', ...
%     'CV dla modelu z tune');
% hold off;


%---------------- porownanie modeli z obiektem ------------------

%------------------------
% nastawy regulacji styczna
Kp = 0.9*Tczas1/(k1*Topu1);
Ki = 1;
Ti = 3.33*Topu1/Kp;
modelOb='obiekt_sterowanie_tune';

% %obiekt 
% modelOb='obiekt_sterowanie';
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% f4 = figure(4);
% f4.Position = [0,0,1400,1000];
% clf(f4);
% figure(4);
% subplot(2,1,1);
% plot(t1, Twew1, 'g'), hold on, grid on;
% plot(t1, Twew2, 'b:');
% CvO_1=CvO;
% ----------------------------------
% styczna ZN
% modelSt='sterowanie';
% [t2]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t2, TwewSt1, 'r');
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt", "PV model");
% title("Wynik sterowania na obiekcie i modelu ze sterowaniem z nastawami z ZN z identyfikacji styczną")
% hold off;
% 
% figure(4);
% subplot(2,1,2);
% hold on; grid on;
% plot(t1, CvO_1, 'g--');
% plot(t2, CvSt1 + Fmw0, 'r--');
% legend("Fmw obiekt", "CV model");
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% title("Sterowania na obiekcie i modelu ze sterowaniem z nastawami z ZN z identyfikacji styczną")

% % --------------------------
% nastawy regulacji dwupunktowa
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;
% 
% modelOb='obiekt_sterowanie';
% f5 = figure(5);
% f5.Position = [0,0,1400,1000];
% clf(5);
% figure(5);
% subplot(2,1,1);
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t1, Twew1, 'g'), hold on, grid on;
% plot(t1, Twew2, 'b:');
% 
% modelSt='sterowanie';
% [t2]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t2, TwewSt2, 'r'), grid on;
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt","PV model");
% title("Wynik sterowania termeraturą na obiekcie i modelu ze sterowaniem z nastawami z ZN z identyfikacji metodą dwupunktową")
% hold off;
% 
% figure(5);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvO, 'g--');
% plot(t2, CvSt2 + Fmw0, 'r--')
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("Fmw obiekt", "CV model");
% title("Sterowanie termeraturą na obiekcie i modelu ze sterowaniem z nastawami z ZN z identyfikacji metodą dwupunktową")

% % -------------------------
% nastawy z tune
% Kp = 0.06016;
% Ki = 4.35489929311168e-06;
% Ti = 1/Ki;


% 
% 
% modelOb='obiekt_sterowanie_tune';
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% f6 = figure(6);
% f6.Position = [0,0,1400,1000];
% clf(f6);
% figure(6);
% subplot(2,1,1), plot(t1, Twew1Mat, 'g'), hold on, grid on;
% plot(t1, Twew2Mat, 'b:');
% 
% modelSt='sterowanie';
% [t2]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t2, TwewSt1Mat, 'r');
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt","PV model");
% title("Wynik sterowania na obiekcie i modelu ze sterowaniem z nastawami wyzanczonymi za pomoca tune");
% hold off;
% 
% figure(6);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvOMat, 'g--');
% plot(t2, Cv1Mat + Fmw0, 'r--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("Fmw obiekt", "CV model");
% title("Sterowanie na obiekcie i modelu ze sterowaniem z nastawami wyzanczonymi za pomoca tune");
% hold off;


% -------------------------
% % nastawy z CC styczna
% a=k1*Topu1/Tczas1;
% tau=Topu1/(Topu1 + Tczas1);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu1/Kp;


% 
% modelOb='obiekt_sterowanie_tune';
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% f7 = figure(7);
% f7.Position = [0,0,1400,1000];
% clf(f7);
% figure(7);
% subplot(2,1,1), plot(t1, Twew1Mat, 'g'), hold on, grid on;
% plot(t1, Twew2Mat, 'b:');
% 
% modelSt='sterowanie';
% [t2]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t2, TwewSt1Mat, 'r');
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt","PV model");
% title("Wynik sterowania termeraturą na obiekcie i modelu ze sterowaniem z nastawami z CC z identyfikacji metodą stycznej")
% hold off;
% 
% figure(7);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvO, 'g--');
% plot(t2, Cv1Mat + Fmw0, 'r--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("Fmw obiekt", "CV model");
% title("Sterowanie termeraturą na obiekcie i modelu ze sterowaniem z nastawami z CC z identyfikacji metodą stycznej")
% hold off;
% 
% 
% % -------------------------
% nastawy z CC dwupunktowa
% a=k2*Topu2/Tczas2;
% tau=Topu2/(Topu2 + Tczas2);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu2/Kp;
% modelOb='obiekt_sterowanie';
% disp("err") 
% err
% disp("err2")
% err2


% 
% modelOb='obiekt_sterowanie';
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% f8 = figure(8);
% f8.Position = [0,0,1400,1000];
% clf(f8);
% figure(8);
% subplot(2,1,1), plot(t1, Twew1Mat, 'g'), hold on, grid on;
% plot(t1, Twew2Mat, 'b:');
% 
% modelSt='sterowanie';
% [t2]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t2, TwewSt1Mat, 'r');
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt","PV model");
% title("Wynik sterowania termeraturą na obiekcie i modelu ze sterowaniem z nastawami z CC z identyfikacji metodą dwupunktową")
% hold off;
% 
% figure(8);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvO, 'g--');
% plot(t2, Cv1Mat + Fmw0, 'r--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("Fmw obiekt", "CV model");
% title("Sterowanie termeraturą na obiekcie i modelu ze sterowaniem z nastawami z CC z identyfikacji metodą dwupunktową")
% hold off;

% ------------------ porownanie obiektu -------

% % tune
% Kp = 0.06016;
% Ki = 4.35489929311168e-06;
% Ti = 1/Ki;
% 
% % nastawy z tune
% modelOb='obiekt_sterowanie_tune';
% [t1]=sim(modelOb,tmax);    % t - wektor czasu
% f9 = figure(9);
% f9.Position = [0,0,1400,1000];
% clf(f9);
% figure(9);
% subplot(2,1,1), plot(t1, Twew1Mat, 'g'), hold on, grid on;
% plot(t1, Twew2Mat, 'k:');
% 
% % nastawy regulacji styczna ZN
% Kp = 0.9*Tczas1/(k1*Topu1);
% Ki = 1;
% Ti = 3.33*Topu1/Kp;
% 
% modelOb='obiekt_sterowanie';
% [t2]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t2, Twew1, 'c');
% plot(t2, Twew2, 'b:');
% CvO_1 = CvO;
% 
% % nastawy regulacji dwupunktowa ZN
% Kp = 0.9*Tczas2/(k2*Topu2);
% Ki = 1;
% Ti = 3.33*Topu2/Kp;
% 
% modelOb='obiekt_sterowanie';
% [t3]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t3, Twew1, 'r');
% plot(t3, Twew2, 'g:');
% CvO_2 = CvO;
% 
% % wyznaczone dla metody ze stycznej Cohen-Coon
% a=k1*Topu1/Tczas1;
% tau=Topu1/(Topu1 + Tczas1);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu1/Kp;
% 
% modelOb='obiekt_sterowanie';
% [t4]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t4, Twew1, 'k');
% plot(t4, Twew2, 'r:');
% CvO_3=CvO;
% 
% % wyznaczone dla metody dwu pkt Cohen-Coon
% a=k2*Topu2/Tczas2;
% tau=Topu2/(Topu2 + Tczas2);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu2/Kp;
% 
% modelOb='obiekt_sterowanie';
% [t5]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t5, Twew1, 'b');
% plot(t5, Twew2, 'm:');
% CvO_4 = CvO;
% 
% 
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 tune", "Twew2 tune", "Twew1  styczna ZN", "Twew2 styczna ZN", "Twew1  dwu pkt. ZN", "Twew2 dwu pkt. ZN", ...
%     "Twew1  styczna CC", "Twew2 styczna CC", "Twew1  dwu pkt. CC", "Twew2 dwu pkt. CC");
% title("Wynik sterowania temperatura na obiekcie")
% hold off;
% 
% figure(9);
% subplot(2,1,2);
% hold on; grid on;
% plot(t1, CvOMat, 'g--');
% plot(t2, CvO_1, 'c--');
% plot(t3, CvO_2, 'r--');
% plot(t4, CvO_3, 'k--');
% plot(t5, CvO_4, 'b--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("Fmw tune", "Fmw styczna ZN",  "Fmw  dwu pkt.ZN", ...
%     "Fmw styczna CC", "Fmw  dwu pkt. CC");
% title("Sterowanie na obiekcie")
% hold off;
% 


% ------------------- cohe-coon
% 
% % wyznaczone dla metody ze stycznej Cohen-Coon
% a=k1*Topu1/Tczas1;
% tau=Topu1/(Topu1 + Tczas1);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu1/Kp;
% 
% f8 = figure(8);
% f8.Position = [0,0,1400,1000];
% clf(f8);
% figure(8);
% subplot(2,1,1);
% modelOb='obiekt_sterowanie';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'g'), hold on, grid on;
% plot(t, Twew2, 'b:');
% 
% modelSt='sterowanie';
% [t]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t, TwewSt1, 'r');
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt","PV model");
% title("Porowananie sterowania termeratura na obiekcie i modelu ze sterowaniem wyzanczonym z identyfikacji ze styczna, nastawy Cohen-Coon")
% hold off;
% 
% figure(8);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvO, 'g--');
% plot(t, CvSt1 + Fmw0, 'r--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("CV obiekt", "CV model");
% title("Porowananie sterowania termeratura na obiekcie i modelu ze sterowaniem wyzanczonym za pomoca tune");
% hold off;
% 
% 
% 
% % wyznaczone dla metody dwupunktowej Cohen-Coon
% a=k1*Topu2/Tczas2;
% tau=Topu1/(Topu2 + Tczas2);
% Kp = (0.2/a)*(1+(0.92*tau/(1-tau)));
% Ki = 1;
% Ti = (3.3-3*tau)/(1+1.2*tau)*Topu2/Kp;
% 
% f9 = figure(9);
% f9.Position = [0,0,1400,1000];
% clf(f9);
% figure(9);
% subplot(2,1,1);
% modelOb='obiekt_sterowanie';
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'g'), hold on, grid on;
% plot(t, Twew2, 'b:');
% 
% modelSt='sterowanie';
% [t]=sim(modelSt,tmax);    % t - wektor czasu
% plot(t, TwewSt2, 'r'), grid on;
% xlabel("t[s]"), ylabel("Twew[^{\circ}C]");
% legend("Twew1 obiekt", "Twew2 obiekt", "PV model");
% title("Porowananie sterowania termeratura na obiekcie i modelu ze sterowaniem wyzanczonym z identyfikacji dwupunktowej, Cohen-Coon")
% hold off;
% 
% figure(9);
% subplot(2,1,2);
% hold on, grid on;
% plot(t1, CvO, 'g--');
% plot(t, CvSt2 + Fmw0, 'r--');
% xlabel("t[s]"), ylabel("Fmw['^{m^{3}}/_{s}']");
% legend("CV obiekt", "CV model");
% title("Porowananie sterowania termeratura na obiekcie i modelu ze sterowaniem wyzanczonym za pomoca tune");
% hold off;
% 
% 
% 
% 
% % to do
% %  - zrob cv na innych wykresach pod spodem
% % - wyznaczyc parametry tune, teraz nie da sie pobrac
% 
% 
% 
% 
% 
% 
% 
