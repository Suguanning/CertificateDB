var Web3 = require("web3");
var fs = require("fs");
var web3 = new Web3(new Web3.providers.HttpProvider('http://172.30.104.156:8545'));
var data = fs.readFileSync("../build/contracts/Certificate.json", "utf-8");
//合约地址
var contractAddr  = '0xe8042d32149b0ce8029048Cc5fB07b7dC7084ab4';
var defaultAddr
var contract = new web3.eth.Contract(JSON.parse(data).abi,contractAddr,{});


/*
合约调用方法：
await contract.methods.insertCertificateChunk(metaData,data)..send(sendObj)
await contract.methods.returnCertificateMetadata(['*','*','*'],notExpire).call().then(output);
await contract.methods.getCertificatePDF(['*','*','*','*','*','*','*'],notExpire).call().then(outputPdf);
//path:凭证文件夹路径 isWhole：是否完整发送一个文件 num:发送多少个块
insertCertification(path, isWhole,  num)
*/

/*
时间测试方法：
let then = Date.now();
...运行代码...
let now = Date().now();
let diff = now - then; //diff为单位为毫秒的时间差
*/
/*
输出用console.log
*/
async function test(){

//一些需要初始化的东西
	await web3.eth.getAccounts().then(setDefaultAcc);
	var sendObj = {from:defaultAddr, gasPrice:'268435455',gas:268435455};
//测试代码写这里
	insertCertification(sendObj,"../data/10000000002",true,1);
	//await contract.methods.returnCertificateMetadata(['*','*','*'],false).call().then(output);
	//await contract.methods.getCertificatePDF(['DBMI','*','*','*','*','*','*'],false).call().then(outputPdf);

}
function setDefaultAcc(account){
	defaultAddr = account[0];
	console.log("初始化成功账户地址："+defaultAddr);
}
//将返回数据转换成字符串
function output(result){ 
	let str = result.slice(2);
	var temp = '';
	for(var i = 0; i<(str.length/2); i++){
		temp = temp+(String.fromCharCode(Number('0x'+str[2*i]+str[2*i+1])));
	}
	console.log(temp);
}
//将返回数据保存成pdf
function outputPdf(data){
	console.log(data.slice(0,100));
	console.log("data recived successful, data size: "+data.length);
	let temp = data.slice(2);
	var bytesArray = [];
	for(var i = 0; i<(temp.length/2); i++){
		bytesArray.push(Number('0x'+temp[2*i]+temp[2*i+1]));
	}
	console.log("saving as pdf");
	console.log(bytesArray);
	let buffer = Buffer.from(bytesArray);
	fs.writeFile('./pdfs/test.pdf',buffer,function(error){
		if (error) { 
			console.error("write error: " + error.message); 
		} else { 
			//console.log("Successful Write" ); 
		} 
	});
	fs.writeFile('./pdfs/test.o',buffer,function(error){
		if (error) { 
			console.error("write error: " + error.message); 
		} else { 
			//console.log("Successful Write" ); 
		} 
	});
	console.log("pdf saved");
}

async function insertCertification(sendObj, path, isWhole,  num){
	let metaPath = path + '\\meta.json';
	var dataPath = path + '\\chunks\\';
	let metaData = fs.readFileSync(metaPath);
	metaData = JSON.parse(metaData);
	if(isWhole){
		let then = Date.now();
		for(var i = metaData.length-1; i != -1; i--){
			let data = fs.readFileSync(dataPath + metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			let then = Date.now();
			await contract.methods.insertCertificateChunk(metaArray,data).send(sendObj)
			let now = Date.now();
			console.log(metaData[i].chunk_file_name+' transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' ms');
		}
		let now = Date.now();
		console.log(metaData[0].file_name + "inserted, size: "+metaData[0].file_size+" takes "+timeCmp(then,now)+ "ms");
		let sec = timeCmp(then,now)/1000;
		let speed = parseInt(metaData[0].file_size)/sec;
	}
	else{
		for(var i = 0; i < num; i++){
			let data = fs.readFileSync(dataPath+metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			let then = Date.now();
			await contract.methods.insertCertificateChunk(metaArray,data).send(sendObj)
			let now = Date.now();
			console.log(metaData[i].chunk_file_name+'(T)transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' ms');
		}
	}
}
function timeCmp (_then, _now) {
	// let then = date.format(_then, "HH:mm:ss");
	// let now = date.format(_now, "HH:mm:ss");
	// secdif = parseInt(now.slice(6,8)) - parseInt(then.slice(6,8));
	// mindif = parseInt(now.slice(3,5)) - parseInt(then.slice(3,5));
	// hourdif = parseInt(now.slice(0,2)) - parseInt(then.slice(0,2));
	return _now - _then;//secdif + mindif*60 + hourdif*3600;
  }
test();