var Web3 = require("web3");
let date = require("silly-datetime");
//连接到Ganache
var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));

var fs = require("fs");
const { resourceUsage } = require("process");
const { time, timeStamp, timeLog, log } = require("console");
const { parse } = require("path");
var data = fs.readFileSync("../build/contracts/Certificate.json", "utf-8");

//创建合约对象
//完整数据 0x1865A14DFd48EDb0b5f550C8009a3bBc6d424DDF
//不完整数据 0xD7aEc88077Db73Ca019dc068420dd8bDeB86C364

var contract = new web3.eth.Contract(JSON.parse(data).abi,'0xafd4936fa8748d2fb51a6b0c86436698e80af423');


// contract.methods.store(200).send({from:'0x51BF497D8B47C5754220be9256F0Cb9E2Cd688B8'}).then(console.log);
async function test(){
	console.log("code begin");
	await contract.methods.returnCertificateMetadata(['*','*','*'],false).call().then(output);
	// for(var i = 1; i < 58; i++){
	 //	await contract.methods.setTestNum(1).call();
	// 	let then = date.format(Date(),'HH:mm:ss');
	await contract.methods.getCertificatePDF(['DBMI','*','*','*','*','*','*'],false).call().then(ouputPdf);
	// 	let now = date.format(Date(),'HH:mm:ss');
	// 	console.log('got '+i+' chunks takes '+timeCmp(then, now)+' seconds');
	// }


}	

function output(result){ 
	let str = result.slice(2);
	var temp = '';
	for(var i = 0; i<(str.length/2); i++){
		temp = temp+(String.fromCharCode(Number('0x'+str[2*i]+str[2*i+1])));
	}
	console.log(temp);
}

function ouputPdf(data){
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

function dataTest(data){
	console.log(data.slice(0,100))
}

function timeCmp (then, now) {
	secdif = parseInt(now.slice(6,8)) - parseInt(then.slice(6,8));
	mindif = parseInt(now.slice(3,5)) - parseInt(then.slice(3,5));
	hourdif = parseInt(now.slice(0,2)) - parseInt(then.slice(0,2));
	return secdif + mindif*60 + hourdif*3600;
  }
test();
//ouputPdf("0x255044462d312e340a2520637265617465642062792050696c6c6f7720392e302e3120504446206472697665720a342030")