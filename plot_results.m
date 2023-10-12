lambda = 10;                % Лямбда в распределении Пуассона для генерации случайных временных промежутков
scalingStep = 2;            % Шаг при увеличении количества экземпляров при масштабировании +-scalingStep
scalingLoopDelay = 5;       % Промежуток между срабатыванием алгоритма масштабирования
maxCores = 35;              % Максимально возможное количество экземпляров
lowerUtilThreshold = 50;    % Нижний порог утилизации при масштабировании
upperUtilThreshold = 80;    % Верхний порог утилизации при масштабировании
serviceRate = 1;            % Скорость обслуживания запроса экземпляром
routineRate = 4;            % Скорость пользовательского потока запросов
initialLoopWaitTime = 50;   % Период ожидания перед началом работы алгоритма масштабирования
lenOfCoreFIFO = 100;        % Максимальная длинна очереди запросов для одного экземпляра
Price_com = 14;             % Стоимость работы одного экземпляра
Price_bw = 14;              % Стоимость использования полосы пропускания
initialCoresVal = 7;        % Количество экземпляров в начале симуляции
attackRateArr = 0:2:18;     % Скорости атак


utilArr = [];
delayArr = [];
coresArr = [];


for attackRate = attackRateArr

    set_param('EDoS_model/Multiprocessor_scalable_system/Gain1', 'Gain', num2str(initialCoresVal)); 

    simOut = sim("EDoS_model");
    
    util = simOut.util.Data;
    delay = simOut.delay.Data;
    cores = simOut.cores.Data;
    

    utilLast = mean(util(end-100 : end));
    delayLast = mean(delay(end-100 : end));
    coresLast = cores(end);
    utilArr = [utilArr, utilLast];
    delayArr = [delayArr, delayLast];
    coresArr = [coresArr, coresLast];
end
figure;
hold on; grid on;
plot(attackRateArr, utilArr, 'LineWidth', 2, 'Color', 'red');
title("Utilization");
xlabel("attack rate");
ylabel("Utilization, %")

% Time scaling
del = (delayArr - delayArr(1));
del = del ./ max(del);
del = 3.25 * del + 1;

figure;
hold on; grid on
plot(attackRateArr, del, 'LineWidth', 2, 'Color', 'blue');
title("Delay");
xlabel("attack rate");
ylabel("Delay, ms");


% Calculation of damage cost
cost = Price_bw .* (attackRateArr + routineRate) + Price_com .* coresArr;

figure;
hold on; grid on
plot(attackRateArr, cost, 'LineWidth', 2, 'Color', 'green');
title("Damage cost");
xlabel("attack rate");
ylabel("Cost, %")
