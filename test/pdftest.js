const Certificate = artifacts.require("Certificate");
const path ="data\\data\\10000000001";
const data_path = "data\\data\\10000000001\\chunks\\";
let fs = require("fs");
contract('certificate',(accounts)=>{

	it('test insert hash',async function () {
		this.timeout(6000000); 
		const instance = await Certificate.deployed();
		for(var i = 0; i < 1; i++){
			let cert = "data\\data\\" +String(10000000001+i);
			await insertCertification(instance, cert, true);
		}
		//await insertCertification(instance, path, false);

		let certificate = await instance.returnCertificateMetadata(['*','*','*'],true);
		let logStr = await instance.returnLogStr();
		console.log(logStr);
		let result = await instance.getCertificatePDF(['*','*','Alexander Long','*','06/19/2025','*','*'],true)
		//console.log(result);
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
			await instance.insertCertificateChunk(metaArray,data);
			console.log(metaData[i].chunk_file_name+' transmited: '+(i+1)+'/'+metaData.length);
		}
	}
	else{
		for(var i = 0; i < num; i++){
			let data = fs.readFileSync(dataPath+metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			await instance.insertCertificateChunk(metaArray,data);
			console.log(metaData[i].chunk_file_name+'(T)transmited: '+(i+1)+'/'+metaData.length);
		}
	}
}