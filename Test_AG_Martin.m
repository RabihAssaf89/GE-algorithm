C1=find(id==1);
C2=find(id==2);
C3=find(id==3);
C4=find(id==4);
C5=find(id==5);
C6=find(id==6);
C7=find(id==7);
C8=find(id==8);
C9=find(id==9);
C10=find(id==10);
C11=find(id==11);
C12=find(id==12);
C13=find(id==13);
C14=find(id==14);

data1=data(:,C1);
[loadings1,scores1,val_prop] = princomp(data1');

%tmp1 = preprocessing(data1','snv');
data2=data(:,C2);
%tmp2 = preprocessing(data2','snv');
[loadings2,scores2,val_prop] = princomp(data2');

data3=data(:,C3);
%tmp3 = preprocessing(data3','snv');
[loadings3,scores3,val_prop] = princomp(data3');

data4=data(:,C4);
%tmp4 = preprocessing(data4','snv');
[loadings4,scores4,val_prop] = princomp(data4');

data5=data(:,C5);
%tmp5 = preprocessing(data5','snv');
[loadings5,scores5,val_prop] = princomp(data5');

data6=data(:,C6);
%tmp6 = preprocessing(data6','snv');
[loadings6,scores6,val_prop] = princomp(data6');

data7=data(:,C7);
%tmp7 = preprocessing(data7','snv');
[loadings7,scores7,val_prop] = princomp(data7');

data8=data(:,C8);
%tmp8 = preprocessing(data8','snv');
[loadings8,scores8,val_prop] = princomp(data8');


data9=data(:,C9);
%tmp9 = preprocessing(data9','snv');
[loadings9,scores9,val_prop] = princomp(data9');


data10=data(:,C10);
%tmp10 = preprocessing(data10','snv');
[loadings10,scores10,val_prop] = princomp(data10');


data11=data(:,C11);
%tmp11 = preprocessing(data11','snv');
[loadings11,scores11,val_prop] = princomp(data11');


data12=data(:,C12);
%tmp12 = preprocessing(data12','snv');
[loadings12,scores12,val_prop] = princomp(data12');


data13=data(:,C13);
%tmp13 = preprocessing(data13','snv');
[loadings13,scores13,val_prop] = princomp(data13');


data14=data(:,C14);
%tmp14 = preprocessing(data14','snv');
[loadings14,scores14,val_prop] = princomp(data14');

I14 =loadings14(:,1:5);
I1 =loadings1(:,1:5);
I2 =loadings2(:,1:5);
I3 =loadings3(:,1:5);
I4 =loadings4(:,1:5);
I5 =loadings5(:,1:5);
I6 =loadings6(:,1:5);
I7 =loadings7(:,1:5);
I8 =loadings8(:,1:5);
I9 =loadings9(:,1:5);
I10 =loadings10(:,1:5);
I11 =loadings11(:,1:5);
I12 =loadings12(:,1:5);
I13 =loadings13(:,1:5);



M1 = mean(data1');
M2 = mean(data2');
M3 = mean(data3');
M4 = mean(data4');
M5 = mean(data5');
M6 = mean(data6');
M7 = mean(data7');
M8 = mean(data8');
M9 = mean(data9');
M10 = mean(data10');
M11 = mean(data11');
M12 = mean(data12');
M13 = mean(data13');
M14 = mean(data14');

[X_corrected_1,B,res,target_coeff,res_coef] = EMSC(data1,M1',I1,5);
[X_corrected_2,B,res,target_coeff,res_coef] = EMSC(data2,M2',I2,5);
[X_corrected_3,B,res,target_coeff,res_coef] = EMSC(data3,M3',I3,5);
[X_corrected_4,B,res,target_coeff,res_coef] = EMSC(data4,M4',I4,5);
[X_corrected_5,B,res,target_coeff,res_coef] = EMSC(data5,M5',I5,5);
[X_corrected_6,B,res,target_coeff,res_coef] = EMSC(data6,M6',I6,5);
[X_corrected_7,B,res,target_coeff,res_coef] = EMSC(data7,M7',I7,5);
[X_corrected_8,B,res,target_coeff,res_coef] = EMSC(data8,M8',I8,5);
[X_corrected_9,B,res,target_coeff,res_coef] = EMSC(data9,M9',I9,5);
[X_corrected_10,B,res,target_coeff,res_coef] = EMSC(data10,M10',I10,5);
[X_corrected_11,B,res,target_coeff,res_coef] = EMSC(data11,M11',I11,5);
[X_corrected_12,B,res,target_coeff,res_coef] = EMSC(data12,M12',I12,5);
[X_corrected_14,B,res,target_coeff,res_coef] = EMSC(data14,M14',I14,5);
[X_corrected_13,B,res,target_coeff,res_coef] = EMSC(data13,M13',I13,5);


X_corrected = [X_corrected_1 X_corrected_2 X_corrected_3 X_corrected_4 X_corrected_5 X_corrected_6 X_corrected_7 X_corrected_8 X_corrected_9 X_corrected_10 X_corrected_11 X_corrected_12 X_corrected_13 X_corrected_14];
data = X_corrected';

%dataT=[tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 tmp14];
idC=[ones(size(C1)); ones(size(C2)); 2*ones(size(C3)); 2*ones(size(C4)); 3*ones(size(C5)); 3*ones(size(C6)); 4*ones(size(C7)); 4*ones(size(C8)); 5*ones(size(C9)); 5*ones(size(C10)); 6*ones(size(C11)); 6*ones(size(C12)); 7*ones(size(C13)); 7*ones(size(C14))];
dataC=[data1 data2 data3 data4 data5 data6 data7 data8 data9 data10 data11 data12 data13 data14];
idC=[ones(size(C1)); ones(size(C2)); ones(size(C3)); ones(size(C4)); ones(size(C5)); ones(size(C6)); ones(size(C7)); 2*ones(size(C8)); 2*ones(size(C9)); 2*ones(size(C10)); 2*ones(size(C11)); 2*ones(size(C12)); 2*ones(size(C13)); 2*ones(size(C14))];
idC=[ones(size(C1)); ones(size(C2)); ones(size(C3)); 2*ones(size(C4)); 2*ones(size(C5)); 2*ones(size(C6)); 3*ones(size(C7)); 3*ones(size(C8)); 3*ones(size(C9)); 4*ones(size(C10)); 4*ones(size(C11)); 4*ones(size(C12)); 5*ones(size(C13)); 5*ones(size(C14))];
