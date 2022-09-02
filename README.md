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
    ganache -g 1 -l 50000000000 --miner.callGasLimit 50000000000