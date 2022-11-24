# Compentencia Final

4 modelos

Modelo 1001:
    FE: Catedra - LAG 1 + LAG 2 - Tendencias 4 - Under 60% - dd rank cero fijo

    TS: 
        Train       |   2019 completo + 202011 202012 202101 202102 202103 202104 202105
        Validate    |   202106
        Test        |   202107
        Final Train |   2019 completo + 202101 202102 202103 202104 202105 202106 202107

Modelo 1002:
    FE: catedra - Random forest - LAG 1 + LAG 2 - Tendencias 3 - Canaritos 30% - Under 25% - dd rank cero fijo

    TS: 
        Train       |   201906 201907 201908 201909 201910 202011 202012 202101 202102 202103 202104 202105
        Validate    |   202106
        Test        |   202107
        Final Train |   201908 201909 201910 201911 201912 202101 202102 202103 202104 202105 202106 202107

Modelo 1003:
    FE nn - LAG 1 + LAG 2 - Tendencias 5 - Under 60% - dd cerofijo

    TS: 
        Train       |   201906 201907 201908 201909 201910 201911 201912 202011 202012 202101 202102 202103 
        Validate    |   202106
        Test        |   202107
        Final Train |   201906 201907 201908 201909 201910 201911 201912 202101 202102 202103 202106 202107

Modelo 1004:
    FE Catedra - LAG 1 + LAG 2 - Tendencias 4 - Canaritos 20% - dd rank cero fijo

    TS: 
        Train       |   201910 201911 201912 202010 202011 202012 202101 202102 202103
        Validate    |   202106
        Test        |   202107
        Final Train |   201910 201911 202011 202012 202101 202102 202103 202106 202107
