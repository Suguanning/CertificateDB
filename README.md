# CertificateDB

# 部分文件说明
## ./contract/...
##### 官方所附带的参考文献提供的代码
    ./contract/CertificateDB.sol
    
##### 本工程所编写的程序(核心代码)
    ./contract/pdfStorageAndRetrieval.sol
    
##### 用于练习的合约
    ./contract/Test.sol
## ./test/...

##### 用于调试练习合约的测试脚本
    ./test/arraytest.js
    
##### 测试脚本
    ./test/datatest.js
    ./test/pdftest.js
    
## ./nodeTest/...
##### 用nodejs编写的测试脚本
    ./nodeTest/test.js
##### 用nodejs编写的测试脚本框架，封装好了上传，查询，下载的函数
    ./nodeTest/testFramework.js

# 使用方法
工程目录下新建data文件夹，将官方提供的数据集下载解压到data目录下
## 启动Ganache
    ganache -g 1 -l 268435455 --miner.callGasLimit 268435455
## 部署合约
    truffle migrate
## 在测试脚本框架中编写代码调用封装好的函数
    按照需求编写./nodeTest/testFramework.js
    修改contractAddr合约地址为当前部署的合约地址
## 移动到目录下并执行脚本
    cd nodeTest
    node testFramework.js
