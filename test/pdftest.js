const Certificate = artifacts.require("Certificate");
const path ="data\\10000000001";
const data_path = "data\\10000000001\\chunks\\";
let fs = require("fs");
let date = require("silly-datetime");
contract('certificate',(accounts)=>{

	it('test insert hash',async function () {

		this.timeout(6000000); 
		const instance = await Certificate.deployed();
		for(var i = 0; i < 1; i++){
			let cert = "data\\" +String(10000000001+i);
			await insertCertification(instance, cert, true,15);
		}
		//await insertCertification(instance, path, false);

		let certificate = await instance.returnCertificateMetadata(['*','*','*'],true);
		let logStr = await instance.returnLogStr();
		console.log(logStr);
		var result;
		 for(var i = 1; i<2 ;i++){
		 	instance.setTestNum(i+14);
		 	let then = Date();
			result =await instance.getCertificatePDF(['DBMI','*','*','*','*','*','*'],false)
			let now = Date();
			console.log('Got '+i+' pdf takes '+timeCmp(then,now)+'s');
			console.log(result);
			// result =await instance.getBuffer();
			// console.log(result);
		}
	})
})

async function insertCertification(instance, path, isWhole,  num){
	let metaPath = path + '\\meta.json';
	var dataPath = path + '\\chunks\\';
	let metaData = fs.readFileSync(metaPath);
	metaData = JSON.parse(metaData);
	if(isWhole){
		for(var i = 0; i < metaData.length; i++){
			let data = fs.readFileSync(dataPath + metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			let then = Date();
			await instance.insertCertificateChunk(metaArray,data);
			let now = Date();
			console.log(metaData[i].chunk_file_name+' transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' s');
		}
	}
	else{
		for(var i = 0; i < num; i++){
			let data = fs.readFileSync(dataPath+metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			let then = Date();
			await instance.insertCertificateChunk(metaArray,data);
			let now = Date();
			console.log(metaData[i].chunk_file_name+'(T)transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' s');
		}
	}
}

function timeCmp (_then, _now) {
	let then = date.format(_then, "HH:mm:ss");
	let now = date.format(_now, "HH:mm:ss");
	secdif = parseInt(now.slice(6,8)) - parseInt(then.slice(6,8));
	mindif = parseInt(now.slice(3,5)) - parseInt(then.slice(3,5));
	hourdif = parseInt(now.slice(0,2)) - parseInt(then.slice(0,2));
	return secdif + mindif*60 + hourdif*3600;
  }