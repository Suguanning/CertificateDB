var Web3 = require("web3");
//连接到Ganache
var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'));

var fs = require("fs");
const { resourceUsage } = require("process");
const { time, timeStamp, timeLog } = require("console");
var data = fs.readFileSync("../build/contracts/Certificate.json", "utf-8");

//创建合约对象
//完整数据 0x1865A14DFd48EDb0b5f550C8009a3bBc6d424DDF
//不完整数据 0xD7aEc88077Db73Ca019dc068420dd8bDeB86C364

var contract = new web3.eth.Contract(JSON.parse(data).abi,'0x1865A14DFd48EDb0b5f550C8009a3bBc6d424DDF');


// contract.methods.store(200).send({from:'0x51BF497D8B47C5754220be9256F0Cb9E2Cd688B8'}).then(console.log);
async function test(){
	console.log("code begin");
	await contract.methods.returnCertificateMetadata(['*','*','*'],false).call().then(output);
	//await contract.methods.getCertificatePDF(['DBMI','*','*','*','*','*','*'],false).call().then(ouputPdf);
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
	console.log("data recived successful, data size: "+data.length);
	let temp = data.slice(2);
	var bytesArray = [];
	for(var i = 0; i<(temp.length/2); i++){
		bytesArray.push(Number('0x'+temp[2*i]+temp[2*i+1]));
	}
	console.log("saving as pdf");
	let buffer = Buffer.from(bytesArray);
	fs.writeFile('./pdfs/test.pdf',buffer,function(error){
		if (error) { 
			console.error("write error: " + error.message); 
		} else { 
			//console.log("Successful Write" ); 
		} 
	});
	console.log("pdf saved");
}

test();