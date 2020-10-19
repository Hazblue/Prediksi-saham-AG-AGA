function varargout = ForecastingData(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       'PrediksiSaham', ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ForecastingData_OpeningFcn, ...
                   'gui_OutputFcn',  @ForecastingData_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
    
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ForecastingData is made visible.
function ForecastingData_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for ForecastingData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ForecastingData_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushButtonPrediksi.
function pushButtonPrediksi_allback(hObject, eventdata, handles)


% --- Executes on button press in pushButtonHasil.
function pushButtonHasil_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushButtonLoadData.
function pushButtonLoadData_Callback(hObject, eventdata, handles)
try
    global lenTrain;
    global lenTest;
    global tableStatus;
    global dataExcel;
    global hargaSahamTxt;
    global dataTabel;
    global target;
    global crossOverName;
    global er;
    crossOverName = 'double';
    er = 0.01;
    % persiapan data train dan data test
    % baca file excel dan txt
    [hargaSahamXls,path] = uigetfile('.xlsx');
    % buka data excel  
    [dataExcel] = xlsread(fullfile(path,hargaSahamXls));
    data_size = length(dataExcel);
    lenTrain = 5;
    lenTest = data_size-lenTrain;
    cla
    axes(handles.plotDataSaham)
    plot(dataExcel);
    grid on
    grid minor
    legend('Harga Saham');
    xlabel('hari ke-');
    ylabel('Rp');
    
catch
    msgbox({'Tipe data tidak valid';'Mohon pilih filfe yang sesuai (xls/xlsx)'});
end

%kode program untuk membuat tabel data
try
    k = 1;
    for i=1:152
       for j=1:5
          dataTabel(j,i) = dataExcel(k);
          k = k+1;
       end
    end
   
catch
    msgbox('Gagal memuat data');
end
try
    %% tulis data saham dari excel ke txt
    j = data_size;
    [hargaSahamTxt] = ('Harga Saham\data_saham.txt');
    fid = fopen(hargaSahamTxt, 'w');
    a = 1;
    b = 762;
    for n=lenTest:-1:1
        col = 1;
        Y(a) = dataExcel(b);
        fprintf(fid, '%d\t', Y(a));
        for m=j-1:-1:n
            X(col) = dataExcel(m);
            fprintf(fid, '%d\t', X(col));
            col = col+1;
        end
          for m=j-1:-1:n
            X(col) = dataExcel(m)^2;
            fprintf(fid, '%d\t', X(col));
            col = col+1;
        end
     
        j = j-1;
        a = a+1;
        b = b-1;
        fprintf(fid,'\n');  
    end
    fclose(fid);
    target = dlmread(hargaSahamTxt,'',0,0);
catch
    msgbox({'Gagal mengonversi data'; 'dari (.xls/.xlsx) ke (.txt)'});
end

% --- Executes on button press in buttonProcessForecasting.
function buttonProcessForecasting_Callback(hObject, eventdata, handles)
 try
    global target;
    global popSize;
    global crossOverRate;
    global mutationRate;
    global iteration;
    global BestChrom;
    global er;
    global uji_prediksi;
    global RMSE;
    global data_saham_aktual;
    global dataUjiPrediksi;
    global size;
    global prediksiHasil;
    global bestValueTxt;
    global delimiter;
    global formatSpec;
    global dataArrayGA;
    global bestKromosom;
    popSize = 100;
    crossOverRate = 0.5;
    mutationRate = 0.013;
    iteration = 1000;
    delimiter = '\t';
    formatSpec = '%s%f%f%[^\n\r]';
    bestValueTxt = ('Harga Saham\data_tabel_prediksi.txt');
    data_saham_aktual = target(1:5);
    setappdata(0,'data_saham_aktual',data_saham_aktual);
    er = 0.01;
    tic
        [BestChrom] = GA(target, popSize, crossOverRate, mutationRate, iteration, er);
        disp('The best fitness kromosom: ')
        BestChrom.kromosom.fitness
        disp('The best error value: ')
        RMSE = BestChrom.kromosom.fitness
    toc
    t = toc
catch
    msgbox({'Data yang dimasukkan tidak lengkap';'Mohon lengkapi data untuk prediksi'});
end
try
    global root_mean_square_error;
    uji_prediksi = pengujian_data(BestChrom.kromosom.gen, RMSE, target);
    setappdata(0,'uji_prediksi',uji_prediksi);
    root_mean_square_error = BestChrom.kromosom.fitness;
    setappdata(0,'root_mean_square_error',root_mean_square_error);
    size = 5;
    dataUjiPrediksi = ('Harga Saham\data_uji_prediksi.txt');
    prediksiHasil = prediksi_data(size, target, dataUjiPrediksi, BestChrom);
    
    if (prediksiHasil <= -prediksiHasil)
        prediksiHasil = (prediksiHasil*(-1));
    end
    
    setappdata(0,'prediksiHasil',prediksiHasil);
    fileID = fopen(bestValueTxt, 'r');
    dataArrayGA = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    setappdata(0,'dataArrayGA',dataArrayGA);
    bestKromosom = BestChrom.kromosom.gen
    setappdata(0,'bestKromosom',bestKromosom);
    msgbox({'Proses Algoritma Genetika telah selesai';'Silakan tekan tombol Lihat Hasil';'untuk melihat hasilnya'});
    
    
catch %%exception
    %msgText = getReport (exception)
    msgbox('Proses persiapan data lanjutan tidak berhasil');
end


% proses GA
function [BestKromosom] = GA( target, popSize, cr_rate, mt_rate, max_generation, er)
try
    global rowTarget;
    global colTarget;
    % menginisialisasi populasi
    [rowTarget, colTarget] = size(target);
    g = 1;
    disp(['Generation #' , num2str(g)]);
    yAksen = zeros;
    
    m = 1;
    while m <= popSize
        % menginisialisasi populasi
        [population.kromosom(m).gen, population.kromosom(m).koefisien] = initialize_population( popSize, colTarget );
      
        % menghitung nilai fitness
        [population.kromosom(m).fitness, yAksen(m)] = calculate_fitness( target, population.kromosom(m).gen,  population.kromosom(m).koefisien );
     
        % pengecekan apakah anda nilai regresi yang negatif
        neg = any(yAksen(m)<0);
        if (neg) == 1
            m = m-1;
        end
        m = m+1;
    end
    
    
    % urutkan fitness -> elitism
    [max_val , indx] = sort([ population.kromosom(:).fitness ] , 'descend');
    
    %% main loop
    for g = 2 : max_generation
        disp(['Generation @#' , num2str(g)]);
        for k = 1: 2: popSize
            % tournament selection
            % size(population.kromosom(:)) -> panjang kromosom
            % (chromosome length)
            % 'selection'
            [parent1,parent2] = selection(population);
            % reproduksi
            % cross over
            % 'cross over'
            [child1 , child2] = crossover(parent1 , parent2, cr_rate);
            % mutation
            % 'mutasi'
            [child1] = mutation(child1, mt_rate);
            [child2] = mutation(child2, mt_rate);

            newPopulation.kromosom(k) = child1;
            newPopulation.kromosom(k+1) = child2;
        end
        for i = 1 : popSize
            newPopulation.kromosom(i).koefisien;
            newPopulation.kromosom(i).fitness = calculate_fitness(target, newPopulation.kromosom(i).gen, newPopulation.kromosom(i).koefisien);
        end
        % regeneration
        [ newPopulation ] = regeneration(population, newPopulation, er);
        population = newPopulation; 
    end
    BestKromosom.kromosom.gen = population(1).kromosom.gen;
    BestKromosom.kromosom.koefisien = population(1).kromosom.koefisien;
    BestKromosom.kromosom.fitness = population(1).kromosom.fitness;
catch
    msgbox('Proses GA tidak berhasil');
end


function [ gen, koefisien ] = initialize_population( ukuran_populasi, panjang_kromosom )
try
    for j = 1 : panjang_kromosom
        gen(j) = randi([0 1]);
        koefisien(j) = -1 + (2) .* rand(1,1);
    end
catch
    msgbox('Proses inisialisasi populasi gagal');
end

%PROSES SELEKSI PAKAI TOURNAMENT

% this is tournament selection
function [parent1, parent2] = selection(population)
try
    global popSize;
    % ukuran turnament pool
    tournament_size = 4;
    % [sorted_fitness_values , sorted_kromosom] = sort(normalized_fitness , 'descend');
    for i=1:2
        for j=1:tournament_size
            counter = randi ([1 popSize]);
            temp_population.kromosom(j) = population.kromosom(counter);
        end
        [max_val , indx] = sort([ temp_population.kromosom(:).fitness ] , 'descend');
        parent(i) = temp_population.kromosom(1);
    end
    parent1 = parent(1);
    parent2 = parent(2);
catch
    msgbox('Proses seleksi gagal');
end

%PROSES SELEKSI Nilai Fitness

% this is fitness selection
function [pop] = selectionFitness(population)
try
    % Inisialisasi temporeri populasi
    temppop = population;
    % Mengurutkan temppop berdasarkan nilai fitness tertinggi
    [max_val , indx] = sort([ temppop.kromosom(:).fitness ] , 'descend');
    % Menyimpan 50 nilai fitness tertinggi
    for i=1:50
        temp_population.kromosom(i) = temppop.kromosom(i);              
    end
    % Mengembalikan nilai populasi
    pop = temp_population;
catch
    msgbox('Proses seleksi fitness gagal');
end


% --- Executes on button press in buttonProcessForecastingAGA.
function buttonProcessForecastingAGA_Callback(hObject, eventdata, handles)
 try
    global target;
    global popSize;
    global crossOverRate;
    global mutationRate;
    global iteration;
    global BestChrom;
    global er;
    global uji_prediksi;
    global RMSE;
    global data_saham_aktual;
    global dataUjiPrediksi;
    global size;
    global prediksiHasil;
    global bestValueTxt;
    global delimiter;
    global formatSpec;
    global dataArrayAGA;
    global bestKromosom;
    popSize = 100;
    crossOverRate = 0.5;
    mutationRate = 0.013;
    iteration = 100;
    delimiter = '\t';
    formatSpec = '%s%f%f%[^\n\r]';
    bestValueTxt = ('Harga Saham\data_tabel_prediksi.txt');
    data_saham_aktual = target(1:5);
    setappdata(0,'data_saham_aktual',data_saham_aktual);
    er = 0.01;
    tic
        [BestChrom] = AGA(target, popSize, crossOverRate, mutationRate, iteration, er);
        disp('The best fitness kromosom: ')
        BestChrom.kromosom.fitness
        disp('The best error value: ')
        RMSE = BestChrom.kromosom.fitness
    toc
    t = toc
catch
    msgbox({'Data yang dimasukkan tidak lengkap';'Mohon lengkapi data untuk prediksi'});
end
try
    global root_mean_square_error_AGA;
    uji_prediksi = pengujian_data(BestChrom.kromosom.gen, RMSE, target);
    setappdata(0,'uji_prediksi',uji_prediksi);
    root_mean_square_error_AGA = BestChrom.kromosom.fitness;
    setappdata(0,'root_mean_square_error_AGA',root_mean_square_error_AGA);
    size = 5;
    dataUjiPrediksi = ('Harga Saham\data_uji_prediksi.txt');
    prediksiHasil = prediksi_data(size, target, dataUjiPrediksi, BestChrom);
    
    if (prediksiHasil <= -prediksiHasil)
        prediksiHasil = (prediksiHasil*(-1));
    end
    
    setappdata(0,'prediksiHasil',prediksiHasil);
    fileID = fopen(bestValueTxt, 'r');
    dataArrayAGA = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    setappdata(0,'dataArrayAGA',dataArrayAGA);
    bestKromosom = BestChrom.kromosom.gen
    setappdata(0,'bestKromosom',bestKromosom);
    msgbox({'Proses Algoritma Genetika telah selesai';'Silakan tekan tombol Lihat Hasil';'untuk melihat hasilnya'});
    
    
catch %%exception
    %msgText = getReport (exception)
    msgbox('Proses persiapan data lanjutan tidak berhasil');
end


% proses AGA
function [BestKromosom] = AGA( target, popSize, cr_rate, mt_rate, max_generation, er)
try
    global rowTarget;
    global colTarget;
    % menginisialisasi populasi
    [rowTarget, colTarget] = size(target);
    g = 1;
    disp(['Generation #' , num2str(g)]);
    yAksen = zeros;
    
    m = 1;
    while m <= popSize
        % menginisialisasi populasi
        [population.kromosom(m).gen, population.kromosom(m).koefisien] = initialize_population( popSize, colTarget );
        
        % menghitung nilai fitness
        [population.kromosom(m).fitness, yAksen(m)] = calculate_fitness( target, population.kromosom(m).gen,  population.kromosom(m).koefisien );
        % pengecekan apakah anda nilai regresi yang negatif
        neg = any(yAksen(m)<0);
        if (neg) == 1
            m = m-1;
        end
        m = m+1;
    end
    
    
    % urutkan fitness -> elitism
    [max_val , indx] = sort([ population.kromosom(:).fitness ] , 'descend');
    
    %% main loop
    for g = 2 : max_generation
        disp(['Generation #' , num2str(g)]);
        for k = 1: 2: popSize
            % tournament selection
            % size(population.kromosom(:)) -> panjang kromosom
            % (chromosome length)
            % 'selection'
            % Seleksi populasi dengan 50 nilai fitness tertingii
            [popFitness] = selectionFitness(population);
            % Seleksi parent dengan menggunakan PSO
            [parent1,parent2] = selectionPSO(popFitness);
            % reproduksi
            % cross over
            % 'cross over'
            [child1 , child2] = crossover(parent1 , parent2, cr_rate);
            % mutation
            % 'mutasi'
            [child1] = mutation(child1, mt_rate);
            [child2] = mutation(child2, mt_rate);

            newPopulation.kromosom(k) = child1;
            newPopulation.kromosom(k+1) = child2;
        end
        for i = 1 : popSize
            newPopulation.kromosom(i).koefisien;
            newPopulation.kromosom(i).fitness = calculate_fitness(target, newPopulation.kromosom(i).gen, newPopulation.kromosom(i).koefisien);
        end
        % regeneration
        [ newPopulation ] = regeneration(population, newPopulation, er);
        population = newPopulation; 
    end
    BestKromosom.kromosom.gen = population(1).kromosom.gen;
    BestKromosom.kromosom.koefisien = population(1).kromosom.koefisien;
    BestKromosom.kromosom.fitness = population(1).kromosom.fitness;
catch
    msgbox('Proses GA tidak berhasil');
end



% PROSES PERHITUNGAN NILAI FITNESS
function [fitness,regresi] = calculate_fitness( dataset, populasi, koefisien )
try
    global rowDataset;
    global colDataset;
    [rowDataset, colDataset] = size(dataset);
  
    % nilai awal sumx di-state sebagai array pertama chromosome
    sumx = zeros;
    for i=1:rowDataset
        sumx(i) = populasi(1) * koefisien(1);
        for j=2:colDataset
            sumx(i) = sumx(i) + (populasi(j) * koefisien(j) * dataset(i,j));
        end
    end
    regresi = sum(sumx);
    square = 0;
    jumlah = 0;
    for i=1:rowDataset
        square = power((dataset(i,1)-sumx(i)),2);
        jumlah = jumlah + square;
    end
    error = sqrt(jumlah)/rowDataset;
    fitness = 1/error;
catch
    msgbox('Proses penghitungan nilai fitness gagal');
end


%PROSES SELEKSI PAKAI PSO

% this is tournament selection
function [parent1, parent2] = selectionPSO(population)
try
    % Jumlah populasi
    global size;
    size = 50;
    % Nilai batasan posisi
    Boundary=[1,50];
    % Initialize Constants
    weight=0.5;
    constant1=2;
    constant2=2;
    % Jumlah seleksi yang diinginkan
    nOfSelection=2;
    % Jumlah iterasi
    itrationMax=50;
    % Fungsi nilai rata-rata
    fun=@meandata;
    % Initialize Pariticles
    Positions=zeros(size,nOfSelection);
    for i=1:size
        tempVar = randperm(Boundary(2));
        Positions(i,:) = tempVar(1:nOfSelection);
    end
    % velocity initialization
    Velocity = ones(size,nOfSelection);
    % Initialize Global best
    itration = 1;
    globalBest.value(itration) = inf;
    %% Optimizing
    Particles = struct;

    while(1)
        % Calculating Fitness Values
        for i=1:size
            % Inisialisasi posisi partikel
            Particles(itration).position(i,:) = Positions(i,:);
            % Membuat array berdasarkan nilai fitness pada posisi tertentu
            % Cth: nilai posisi 3 sehingga nilai fitness yang dipakai
            % adalah kromosom nomer 3
            fit = [population.kromosom(Positions(i,1)).fitness population.kromosom(Positions(i,2)).fitness];
            % Merata-rata nilai fitness untuk dijadikan nilai partikel
            Particles(itration).value(i) = fun(fit);
        end
        % Update Position Best
        [Particlesbest.value(itration),ind] = min(Particles(itration).value);
        Particlesbest.position(itration,:) = Particles(itration).position(ind,:);
        % Update Global Best
        if globalBest.value(itration) > Particlesbest.value(itration)
            [globalBest.value(itration),globalBest.value(itration+1)] = deal(Particlesbest.value(itration));
            globalBest.position(itration,:) = Positions(ind(1),:);
        else
            globalBest.value(itration+1) = globalBest.value(itration);
            globalBest.position(itration,:) = globalBest.position(itration-1,:);
        end
        disp('Iteration---->')
        disp(itration)
        disp('gbest value of  fitness=---->')
        disp(globalBest.value(itration))
        % Velocity Update\
        Velocity = (weight*Velocity) + (constant1*rand(1)*(repmat(Particlesbest.position(itration,:),size,1)-Positions)) + ...
            (constant2*rand(1)*(repmat(globalBest.position(itration,:),size,1)-Positions));
        % Postion Update
        Positions = Positions+round(Velocity);
        % Boundary Checking for Position
        Positions(Positions>Boundary(2)) = round(rand(1)*(Boundary(2)-1))+1;
        Positions(Positions<Boundary(1)) = round(rand(1)*(Boundary(2)-1))+1;
        for i=1:size
            if length(unique( Positions(i,:) )) ~= nOfSelection
            tempVar = randperm(Boundary(2));
            Positions(i,:) = tempVar(1:nOfSelection);
            end
        end
        % Loop Breaking is Positions all are same or itertion acheived maximum
        % itertion
        count=0;
        for i=1:size-1;
            if Positions(i,:) == Positions(i+1,:)
                count = count+1;
            end
        end
        if (count == size-1) || (itration >= itrationMax)
            fprintf('\n******Iteration completed******\n')
            break
        end
        itration = itration+1;
    end
    Selection=globalBest.position(itration,:);
    %SelectionValue=globalBest.value(itration);
    disp('Selection---->')
    disp(Selection)
    parent1 = population.kromosom(Selection(1));
    parent2 = population.kromosom(Selection(2));
catch
    msgbox('Proses seleksi PSO gagal');
end


% proses crossover
function [child1,child2] = crossover(parent1,parent2, cr_rate)
try
    global colTarget;
    child1 = parent1;
    child2 = parent2;
    ub = colTarget - 1;
    lb = 1;
    Cross_P1 = abs(round ( (ub - lb) *rand() + lb ));
    Cross_P2 = Cross_P1;
    while Cross_P2 == Cross_P1
        Cross_P2 = abs(round (  (ub - lb) *rand() + lb  ));
    end
    if Cross_P1 > Cross_P2
        temp =  Cross_P1;
        Cross_P1 =  Cross_P2;
        Cross_P2 = temp;
    end
    Part1 = parent1.gen(1:Cross_P1);
    Part2 = parent2.gen(Cross_P1 + 1 :Cross_P2);
    Part3 = parent1.gen(Cross_P2+1:end);
    child1.gen = [Part1 , Part2 , Part3];
    Part1 = parent2.gen(1:Cross_P1);
    Part2 = parent1.gen(Cross_P1 + 1 :Cross_P2);
    Part3 = parent2.gen(Cross_P2+1:end);
    child2.gen = [Part1 , Part2 , Part3];
    R1 = rand();
    if R1 <= cr_rate
        child1 = child1;
    else
        child1 = parent1;
    end
    R2 = rand();
    if R2 <= cr_rate
        child2 = child2;
    else
        child2 = parent2;
    end
catch %exception
    %msgReport (exception)
    msgbox('Proses cross over gagal');
end


% proses mutasi
function [child] = mutation(child,mutation_rate)
try
    global colTarget;
    for k = 1: colTarget
        R = rand();
        if R < mutation_rate
            child.gen(k) = ~ child.gen(k);
        end
    end
catch
    msgbox('Proses mutasi gagal');
end


% proses regenerasi
function [ newPopulation2 ] = regeneration(population , newPopulation, Er)
try
    global popSize;
    Elite_no = round(popSize * Er);
    [max_val , indx] = sort([ population.kromosom(:).fitness ] , 'descend');

    % The elites from the previous population
    for k = 1 : Elite_no
        newPopulation2.kromosom(k).gen  = population.kromosom(indx(k)).gen;
        newPopulation2.kromosom(k).koefisien  = population.kromosom(indx(k)).koefisien;
        newPopulation2.kromosom(k).fitness  = population.kromosom(indx(k)).fitness;
    end

    % The rest from the new population
    for k = Elite_no + 1 :  popSize
        newPopulation2.kromosom(k).gen  = newPopulation.kromosom(k).gen;
        newPopulation2.kromosom(k).koefisien  = newPopulation.kromosom(k).koefisien;
        newPopulation2.kromosom(k).fitness  = newPopulation.kromosom(k).fitness;
    end
catch
   msgbox('Proses regenerasi gagal'); 
end


% proses evaluasi
function islooping = evaluation(population)
try    
    global popSize;
    for i=1:popSize
        if population(i).fitness > 100
            islooping = false;
        else
            islooping = true;
        end
    end
catch
   msgbox('Proses evaluasi gagal'); 
end




%PERBANDINGAN DATA
function [ data_uji ] = pengujian_data( kromosom, error, target )
    % Y^2 - 2Y'Y + (Y'^2-RMSE^2) = 0
    % a=1 ; b=-2Y' ; c=(Y'^2-RMSE^2)
    % Y'~>regresi <=> kromosom*target
    % RMSE=error
    % rumus mencari akar-akar dari persamaan kuadrat dengan rumus a,b,c 
    % (x1,x2) = [(-b)<+/->(square(b^2-4*a*c))]/(2*a)
    global rowDataset;
    global colDataset; 
    for i=1:rowDataset
        regresi(i) = kromosom(1);
        for j=2:colDataset
            
            regresi(i) = regresi(i) + (kromosom(j)*target(i,j));
        end
        data_uji(i)  = regresi(i)+error;
    end
    
    data_uji;

% --- Executes on button press in buttonLihatHasil.
function buttonLihatHasil_Callback(hObject, eventdata, handles)
global data_saham_aktual;
global uji_prediksi;
global data_prediksi_saham;

data_prediksi_saham = getappdata(0, 'prediksiHasil')
data_saham_aktual = getappdata(0,'data_saham_aktual');
uji_prediksi = getappdata(0,'uji_prediksi');
axes(handles.plotPerbandingan);
plot(1:size(data_prediksi_saham,2), data_prediksi_saham,'b');
%%plot(1:size(data_saham_aktual,2), data_saham_aktual,'g');
%%plot(1:size(data_saham_aktual), flip(data_saham_aktual),'g',1:size(data_prediksi_saham,2),flip(data_prediksi_saham),'r');
grid on
grid minor
legend('Data Prediksi','asdsad')
xlabel('hari ke-');
ylabel('Rp');
handles.textGantiPerbandinganPrediksi.String = {'Perbandingan Data Aktual dan Data Prediksi Harga Saham';'pada tahun 2016-2019'};
    
    global root_mean_square_error;
    global root_mean_square_error_AGA;
    root_mean_square_error = getappdata(0,'root_mean_square_error');
    root_mean_square_error_AGA = getappdata(0,'root_mean_square_error_AGA');
    set(handles.text7,'String',root_mean_square_error);
    set(handles.text8,'String',root_mean_square_error_AGA);
    set(handles.uitable1,'data',round(data_prediksi_saham),'ColumnName',{'Hari 1','Hari 2','Hari 3','Hari 4','Hari 5'});
    



%DATA PREDIKSI
function [dataPrediksi] = prediksi_data(size, target, dataUjiPrediksi, BestChrom)
try
global counter;
global errorPredict;
errorPredict=100;
counter = length(target);
fid2 = fopen(dataUjiPrediksi, 'w');
for prepare=1:5
    dataPreparation(prepare) = target(counter);
    counter = counter - 1;
end
for predict=1:size
    for kolom1=1:size
        preX(predict,kolom1) = dataPreparation(kolom1);
        fprintf(fid2, '%d\t', preX(predict,kolom1));
    end
    for kolom2=(size+1):(2*size)
        preX(predict,kolom2) = dataPreparation(kolom2-5);
        fprintf(fid2, '%d\t', preX(predict,kolom2).^2);
    end
    fprintf(fid2, '\n'); 
    temp_dataPreparation = dataPreparation;
    % regresiData = randi([0,100],1,1);
    [~,regresiData] = calculate_fitness(temp_dataPreparation, BestChrom.kromosom.gen, BestChrom.kromosom.koefisien);
    dataPreparation(1) = regresiData+errorPredict;
    for swap=2:5
        dataPreparation(swap) = temp_dataPreparation(swap-1);
    end
    dataPrediksi = abs(dataPreparation(end:-1:1));
end
fclose(fid2);
catch
    msgbox('Proses prediksi data gagal');
end

function simpanButton_Callback(hObject, eventdata, handles)
try
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_prediksi_saham;
data_prediksi_saham = getappdata(0, 'prediksiHasil')
[excelName,excelPath] = uiputfile('*.xlsx')
headers = {'Hari 1','Hari 2','Hari 3','Hari 4','Hari 5'};
data = get(handles.uitable1, 'data');
datacell = num2cell(data);
a = [headers;datacell];
x1Range = 'Prediksi Saham'
xlswrite([excelPath excelName],a,x1Range)
catch exception
    msgText(exception)
    %msgbox('Proses prediksi data gagal');
end


% --- Executes during object creation, after setting all properties.
function panelGA_CreateFcn(hObject, eventdata, handles)
set(handles.panelGA, 'visible', 'off');

% --- Executes during object creation, after setting all properties.
function panelAGA_CreateFcn(hObject, eventdata, handles)
set(handles.panelAGA, 'visible', 'off');



