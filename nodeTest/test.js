var Web3 = require("web3");
let date = require("silly-datetime");
//连接到Ganache
//var web3 = new Web3(new Web3.providers.HttpProvider('http://172.30.104.156:8545'));
var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));
const xlsx = require('node-xlsx');
var fs = require("fs");
const { resourceUsage } = require("process");
const { time, timeStamp, timeLog, log } = require("console");
const { parse } = require("path");
var data = fs.readFileSync("../build/contracts/Certificate.json", "utf-8");

//创建合约对象
//完整数据 0x1865A14DFd48EDb0b5f550C8009a3bBc6d424DDF
//不完整数据 0xD7aEc88077Db73Ca019dc068420dd8bDeB86C364
// 0xbDf75194C401659cc21868C3dF4b594027b0ac5A takes 91.169 s
var contract = new web3.eth.Contract(JSON.parse(data).abi,'0xb0edEEa71eCe64A6AE7EF8834A20255Dc48665B8');

var testTimes = 1;
var notExpire = false;
// contract.methods.store(200).send({from:'0x51BF498B47C5754220be9256F0Cb9E2Cd688B8'}).then(console.log);
async function test3(){
	let then = Date.now();
	await contract.methods.returnCertificateMetadata(['*','*','*'],notExpire).call().then(output);
	let now = Date.now();
	console.log("takes " + (now - then)/1000+ " s");
	//sum += ((now - then)/1000);
}
var timeList = [];
async function test(){
	console.log("code begin");
	console.log("case 1")
	var sum = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['*','*','*'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 2")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['*','*','Anthony Parker'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 3")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['*','Biomedical Informatics Responsible Conduct of Research','*'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 4")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['DBMI','*','*'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 5")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['DBMI','Biomedical Informatics Responsible Conduct of Research','*'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 6")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['*','Biomedical Informatics Responsible Conduct of Research','Anthony Parker'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);
	console.log("case 7")
	sum  = 0;
	for(var i = 0; i<testTimes;i++){
		let then = Date.now();
		await contract.methods.returnCertificateMetadata(['DBMI','*','Anthony Parker'],notExpire).call().then(output);
		let now = Date.now();
		console.log("takes " + (now - then)/1000+ " s");
		sum += ((now - then)/1000);
	}
	sum = sum/testTimes;
	timeList.push(sum);

	let xlsxObj = [
		{
			name: 'firstSheet',
			data: 
			[timeList]
			,
		},
	]
	fs.writeFileSync(('./dataOutput/'+date.format(new Date(), 'MMDD_HH_mm_ss')+'.xlsx'),xlsx.build(xlsxObj),"binary");
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
+
function timeCmp (then, now) {
	secdif = parseInt(now.slice(6,8)) - parseInt(then.slice(6,8));
	mindif = parseInt(now.slice(3,5)) - parseInt(then.slice(3,5));
	hourdif = parseInt(now.slice(0,2)) - parseInt(then.slice(0,2));
	return secdif + mindif*60 + hourdif*3600;
  }
test();
//ouputPdf("0x255044462d312e340a2520637265617465642062792050696c6c6f7720392e302e3120504446206472697665720a342030")
async function test2(){
	var transaction = await web3.eth.getTransaction('0x00ea1c4b12c143c71f3f69dae7477794bb681c0ffa52414d2ca73e6351b17fb1');
	console.log(transaction);
}
//test2();