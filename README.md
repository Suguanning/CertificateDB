# CertificateDB

# 部分文件说明
## ./contract/...
##### 官方所附带的参考文献提供的代码
    ./contract/CertificateDB.sol
    
##### 本工程所编写的程序(核心代码)
    ./contract/Certificates.sol
    
##### 用于练习的合约
    ./contract/Test.sol
## ./test/...

##### 用于调试练习合约的测试脚本
    ./test/arraytest.js
    
##### 测试脚本，用于测试插入数据的
    ./test/datatest.js
    
##### 测试脚本，用于测试取出整个pdf数据
    ./test/pdftest.js
## ./nodeTest/...
##### 用nodejs编写的测试脚本，功能为取出特定合约地址内的某pdf数据并保存为pdf文件
    ./nodeTest/test.js

## 启动Ganache
    ganache -g 1 -l 268435455 --miner.callGasLimit 268435455

DBMI    Biomedical Informatics Research Alexander Jimenez       05/10/2022      05/10/2025      10000000001.pdf 06/05/2022      856912
DBMI    Biomedical Informatics Responsible Conduct of Research  Alexander Long  07/24/2017      07/24/2020      10000000002.pdf 07/26/2017      630803        
DBMI    Biomedical Informatics Research Alexander Martin        12/31/2017      12/31/2020      10000000003.pdf 01/11/2018      848280
Human Genome    Introduction to Genomics and Bioinformatics     Alexander Nguyen        05/18/2019      05/18/2021      10000000004.pdf 05/29/2019      76602 
Human Genome    Introduction to Genomics and Bioinformatics     Alexander Ortiz 09/29/2021      09/29/2023      10000000005.pdf 10/26/2021      76300
Human Genome    Introduction to Genomics and Bioinformatics     Alexander Scott 04/08/2017      04/08/2019      10000000006.pdf 04/26/2017      76374
DBMI    Biomedical Data Only Research   Alexander Taylor        03/18/2017      03/18/2020      10000000007.pdf 04/01/2017      471648
DBMI    Biomedical Informatics Responsible Conduct of Research  Alexander Wright        06/19/2022      06/19/2025      10000000008.pdf 07/16/2022      635847
DBMI    Biomedical Data Only Research   Amanda Evans    01/12/2017      01/12/2020      10000000009.pdf 01/15/2017      468723
Human Genome    Introduction to Genomics and Bioinformatics     Amanda Jimenez  06/03/2022      06/03/2024      10000000010.pdf 06/12/2022      76342
DBMI    Biomedical Data Only Research   Amanda Long     02/10/2021      02/10/2024      10000000011.pdf 03/01/2021      467953
DBMI    Biomedical Informatics Responsible Conduct of Research  Amanda Lopez    03/11/2019      03/11/2022      10000000012.pdf 03/16/2019      625962        
DBMI    Biomedical Informatics Responsible Conduct of Research  Amanda Murphy   07/24/2020      07/24/2023      10000000013.pdf 08/13/2020      631496        
DBMI    Biomedical Informatics Responsible Conduct of Research  Amanda Patel    12/12/2017      12/12/2020      10000000014.pdf 12/16/2017      624363        
DBMI    Biomedical Data Only Research   Amanda Reyes    05/31/2021      05/31/2024      10000000015.pdf 06/24/2021      468578
Human Genome    Introduction to Genomics and Bioinformatics     Amy Collins     04/22/2022      04/22/2024      10000000016.pdf 04/29/2022      75745
DBMI    Biomedical Data Only Research   Amy Gray        02/16/2020      02/16/2023      10000000017.pdf 03/15/2020      464359
DBMI    Biomedical Informatics Responsible Conduct of Research  Amy James       01/01/2021      01/01/2024      10000000018.pdf 01/01/2021      619130
DBMI    Biomedical Data Only Research   Amy Nguyen      05/03/2021      05/03/2024      10000000019.pdf 05/25/2021      466958
DBMI    Biomedical Informatics Responsible Conduct of Research  Amy Taylor      04/03/2022      04/03/2025      10000000020.pdf 05/03/2022      620646
DBMI    Biomedical Informatics Responsible Conduct of Research  Amy White       11/08/2017      11/08/2020      10000000021.pdf 11/26/2017      617438
DBMI    Biomedical Informatics Research Andrew Bailey   07/28/2021      07/28/2024      10000000022.pdf 08/23/2021      835140
DBMI    Biomedical Data Only Research   Andrew Bennett  03/28/2021      03/28/2024      10000000023.pdf 04/16/2021      471226
DBMI    Biomedical Data Only Research   Andrew Edwards  01/05/2017      01/05/2020      10000000024.pdf 01/09/2017      471514
DBMI    Biomedical Data Only Research   Andrew Kelly    01/03/2020      01/03/2023      10000000025.pdf 01/05/2020      468330
DBMI    Biomedical Informatics Responsible Conduct of Research  Andrew Miller   09/19/2017      09/19/2020      10000000026.pdf 09/22/2017      628330
DBMI    Biomedical Informatics Responsible Conduct of Research  Andrew Morgan   02/09/2020      02/09/2023      10000000027.pdf 03/09/2020      635127
Human Genome    Introduction to Genomics and Bioinformatics     Andrew Myers    02/13/2019      02/13/2021      10000000028.pdf 03/06/2019      76136
DBMI    Biomedical Data Only Research   Andrew Price    07/09/2020      07/09/2023      10000000029.pdf 07/15/2020      468497
Human Genome    Introduction to Genomics and Bioinformatics     Andrew Sanchez  05/05/2021      05/05/2023      10000000030.pdf 06/04/2021      76361
DBMI    Biomedical Data Only Research   Angela Adams    11/07/2017      11/07/2020      10000000031.pdf 11/18/2017      467842
DBMI    Biomedical Informatics Research Angela Baker    04/04/2021      04/04/2024      10000000032.pdf 05/01/2021      830562
DBMI    Biomedical Data Only Research   Angela Gomez    11/08/2021      11/08/2024      10000000033.pdf 11/21/2021      468485
DBMI    Biomedical Informatics Research Angela Hughes   01/09/2017      01/09/2020      10000000034.pdf 01/28/2017      833973
DBMI    Biomedical Informatics Responsible Conduct of Research  Angela Jackson  08/31/2017      08/31/2020      10000000035.pdf 09/11/2017      632109
DBMI    Biomedical Data Only Research   Angela James    11/21/2021      11/21/2024      10000000036.pdf 12/03/2021      467991
Human Genome    Introduction to Genomics and Bioinformatics     Angela Jimenez  05/23/2021      05/23/2023      10000000037.pdf 06/02/2021      76210
DBMI    Biomedical Data Only Research   Angela Johnson  05/25/2020      05/25/2023      10000000038.pdf 06/19/2020      471649
Human Genome    Introduction to Genomics and Bioinformatics     Angela Mitchell 03/21/2019      03/21/2021      10000000039.pdf 04/07/2019      76206
DBMI    Biomedical Informatics Research Angela Morris   11/23/2021      11/23/2024      10000000040.pdf 12/13/2021      833637
DBMI    Biomedical Informatics Research Angela Reyes    02/21/2019      02/21/2022      10000000041.pdf 02/25/2019      827543
Human Genome    Introduction to Genomics and Bioinformatics     Angela Sanchez  04/08/2019      04/08/2021      10000000042.pdf 04/09/2019      76264
DBMI    Biomedical Informatics Research Angela Sanders  01/08/2022      01/08/2025      10000000043.pdf 01/20/2022      843363
DBMI    Biomedical Informatics Responsible Conduct of Research  Angela Wright   07/05/2020      07/05/2023      10000000044.pdf 07/09/2020      628640
DBMI    Biomedical Informatics Responsible Conduct of Research  Anna Anderson   02/10/2021      02/10/2024      10000000045.pdf 02/16/2021      631188
Human Genome    Introduction to Genomics and Bioinformatics     Anna Carter     07/03/2018      07/03/2020      10000000046.pdf 07/13/2018      75783
DBMI    Biomedical Informatics Responsible Conduct of Research  Anna Martinez   03/02/2021      03/02/2024      10000000047.pdf 03/16/2021      630059
DBMI    Biomedical Data Only Research   Anna Parker     02/07/2022      02/07/2025      10000000048.pdf 02/24/2022      467865
Human Genome    Introduction to Genomics and Bioinformatics     Anna Sanchez    10/13/2021      10/13/2023      10000000049.pdf 10/14/2021      75984
DBMI    Biomedical Informatics Responsible Conduct of Research  Anthony Chavez  02/12/2019      02/12/2022      10000000050.pdf 03/02/2019      630636