const Certificate = artifacts.require("Certificate");
const path ="data\\10000000001";
const data_path = "data\\10000000001\\chunks\\";
let fs = require("fs");
let date = require("silly-datetime");
const xlsx = require("node-xlsx");
var timeList = [];
var speedList = [];
contract('certificate',(accounts)=>{

	it('test insert hash',async function () {

		this.timeout(6000000); 
		const instance = await Certificate.deployed();
		for(var i = 0; i < 50; i++){
			let cert = "data\\" +String(10000000001+i);
			//let cert = "data\\" +String(10000000001);
			await insertCertification(instance, cert, true,1);
		}
		//let certificate = await instance.returnCertificateMetadata(['*','*','*'],false);
		//let logStr = await instance.returnLogStr();
		//console.log(logStr);
		console.log(instance.address);
		let xlsxObj = [
			{
				name: 'time per chunk',
				data: timeList
				,
			},
			{
				name: 'upload speed',
				data: speedList
				,
			},
		]
		fs.writeFileSync(('./test/doc/'+date.format(new Date(), 'MMDD_HH_mm_ss')+'.xlsx'),xlsx.build(xlsxObj),"binary");
		var result;
		var nameBuff = ['Alexander Jimenez','Alexander Martin','Alexander Long','Alexander Nguyen','Alexander Ortiz','Alexander Scott','Alexander Taylor','Alexander Wright','Amanda Evans']
		if(false){
			for(var i = 0; i<nameBuff.length ;i++){
				let then = Date.now();
				result =await instance.getCertificatePDF(['*','*',nameBuff[i],'*','*','*','*'],false)
				let now = Date.now();
				console.log('Got'+ nameBuff[i]+' pdf takes '+timeCmp(then,now)+'ms');
				//console.log(result);
			}
		}
	})
})

async function insertCertification(instance, path, isWhole,  num){
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
			await instance.insertCertificateChunk(metaArray,data);
			let now = Date.now();
			console.log(metaData[i].chunk_file_name+' transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' ms');
			let temp = timeCmp(then, now);
			timeList.push([temp]);
		}
		let now = Date.now();
		console.log(metaData[0].file_name + "inserted, size: "+metaData[0].file_size+" takes "+timeCmp(then,now)+ "ms");
		let sec = timeCmp(then,now)/1000;
		let speed = parseInt(metaData[0].file_size)/sec;
		speedList.push([speed])
	}
	else{
		for(var i = 0; i < num; i++){
			let data = fs.readFileSync(dataPath+metaData[i].chunk_file_name)
			let meta = metaData[i];
			let metaArray = Object.values(meta);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			let then = Date.now();
			await instance.insertCertificateChunk(metaArray,data);
			let now = Date.now();
			console.log(metaData[i].chunk_file_name+'(T)transmited: '+(i+1)+'/'+metaData.length+' --- '+timeCmp(then, now)+' ms');
			let temp = timeCmp(then, now);
			timeList.push([temp]);
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