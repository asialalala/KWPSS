close all
orange = [0.85, 0.33, 0.1];
%==================== IDENTYFIKACJA =======================%
% wartości nominalne
TwewN = 20;     %oC
TgpN = 70;      %oC
TzewN = -20;    %oC
TgzN = 90;      %oC
QgN = 2000;    % moc grzałki W
QtN = 0;        % dodatkowe starty ciepła
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

T0 = 10; % s opoznienie czasowe

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
tmax = 180000;  % czas symulacji


%zaklocenia
tsok = 80000; % czas skoku
dFmg1 = 0; %0.05*Fmg10;
dFmg2 = 0; %0.05*Fmg20;
dTzew = 0;
dQt1 = 0;
dQt2 = 0;
dTwz = 0;
dFmw = 0; %0.1*FmwN;

dTwew1 = 0;
dTwew2 = 0;
dTwewWsp = -1;

%==================== IDENTYFIKACJA  LOKALNIE =======================%


k1= (0.329)/0.0050;
Topu1 = 3080 - 2000;
Tczas1 = 15543 - Topu1 - 2000;


% weryfikacja, aby działała, trzeba usunąć regilatory lokalne
% f1 = figure(1);
% modelOb = "regulacjapogodowaobiekt";
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew2, 'k');
% hold on;
% modelOb = "model_loklany";
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, TwewModel2, 'b');
% title("Identyfikacja");
% xlabel("t[s]");
% ylabel("Twew[^{\circ}C]");
% legend("Twew", "TweweModel2");


%==================== STEROWANIE LOKALNIE =======================%

% nastawy
Kp = 0.9*Tczas1/(k1*Topu1);
Ki = 1;
Ti = 3.33*Topu1/Kp;


% DWA STEROWANIA LOKALNE --------------------------------------

% f1 = figure(1);
% modelOb = "dwa_lokalne";
% [t]=sim(modelOb,tmax);    % t - wektor czasu
% plot(t, Twew1, 'k');
% hold on;
% plot(t, Twew2, 'b--');
% title("Sterowanie Twew1 i Twew2 dla dwuch regulatorów lokalnych");
% xlabel("t[s]");
% ylabel("T^{\circ}C]");
% legend("Twew1", "Twew2");



%==================== STEROWANIE  CENTRALNIE Z LOKALNYM  =======================%

% ze sprawozdania
kC= 67.44;
TopuC = 648;
TczasC = 8022;

% regulacja pogodowa cieplowania
az_wz = (TwzN - TzewN)/(TwewN - TzewN);
bz_wz = (TwzN - TwewN)/(TwewN - TzewN);
ap_wz = (TwpN - TzewN)/(TwewN - TzewN);
bp_wz = (TwpN - TwewN)/(TwewN - TzewN);

% regulacja pogodowa wezel
az_gz = (TgzN - TzewN)/(TwewN - TzewN);
bz_gz = (TgzN - TwewN)/(TwewN - TzewN);
ap_gz = (TgpN - TzewN)/(TwewN - TzewN);
bp_gz = (TgpN - TwewN)/(TwewN - TzewN);

TopuCiep = 2000;
TemVec = [-20,20];

% ======================================  STEROWANIE RAZEM

% nastawy dla lokalnego
KpC = 0.9*TczasC/(kC*TopuC);
KiC = 1;
TiC = 3.33*TopuC/Kp;

f19 = figure(19);
modelOb = "centralne";
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(t, Twew1, 'g--');
hold on;
plot(t, Twew2, 'b--');

f21 = figure(21);
plot(t, CvC, 'g--');
hold on;

f19 = figure(19);
Kp = TczasC/(kC*TopuC);
Ki = 0;
Ti = 3.33*TopuC/Kp; % obojetnie jaka wartosc

modelOb = "centralneP";
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(t, Twew1, 'm--');
hold on;
plot(t, Twew2, 'r--');
f21 = figure(21);
plot(t, CvC, 'm--');

f19 = figure(19);
Kp = Tczas1/(k1*Topu1)*6;
Ki = 0;
modelOb = "centralneP";
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(t, Twew1, 'k--');
hold on;
plot(t, Twew2, 'c--');


title("Sterowanie Twew1 i Twew2 PV");
xlabel("t[s]");
ylabel("T^{\circ}C]");
legend("Twew1  PI", "Twew2  PI", "Twew1  P", "Twew2  P", "Twew1  P popraw", "Twew2  P popraw");

f21 = figure(21);
plot(t, CvC, 'k--');
xlabel("t[s]");
ylabel("f m^3/s");
legend("cv PI", "cv P", "cv P poraw");

Emin = -0.5;
Emax = 0.5;
Fmin = 0;
Fmax = FmwN;

f20 = figure(20);
modelOb = "centralne_dwustawny";
[t]=sim(modelOb,tmax);    % t - wektor czasu
plot(t, Twew1, 'g--');
hold on;
plot(t, Twew2, 'b--');
title("Sterowanie Twew1 i Twew2 PV");
xlabel("t[s]");
ylabel("T^{\circ}C]");
legend("Twew1 2 dwustawne", "Twew2 2 dwustawne");

f21 = figure(22);
plot(t, CvC, 'k');
xlabel("t[s]");
ylabel("f m^3/s");
legend("cv ");




