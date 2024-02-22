figure;
yyaxis left
plot(DataTimeTable.Time,DataTimeTable.CPIAUCSL)
ylabel("CPI");
yyaxis right
plot(DataTimeTable.Time,DataTimeTable.M1SL);
ylabel("Money Supply");
