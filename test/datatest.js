const Certificate = artifacts.require("Certificate");
const path ="data\\10000000001\\meta.json";
const path1 ="data\\10000000002\\meta.json";
const path2 ="data\\10000000004\\meta.json";
const data_path = "data\\10000000001\\chunks\\10000000001.pdf.chunk1"
const data_path0 = "data\\10000000001\\chunks\\"
const data_path1 = "data\\10000000002\\chunks\\"
const data_path2 = "data\\10000000004\\chunks\\"
let fs = require("fs");
contract('certificate',(accounts)=>{
	// it('add a cetificate',async () => {
	// 	const instance = await CertificateDB.deployed();
	// 	const content = fs.readFileSync(path);
	// 	let meta = JSON.parse(content);
	// 	console.log(meta[0]);
	// 	instance.addNewCertificate('1',1,meta[0].certificate_user_name,meta[0].certificate_user_name,);
	// })
	// it('test insert',async ()=>{
	// 	const instance = await Certificate.deployed();

	// 	const content = fs.readFileSync(path);
	// 	//const data = fs.readFileSync(data_path);
	// 	let meta = JSON.parse(content);
	// 	for(i = 0; i< meta.length; i++){
	// 		let data = fs.readFileSync(data_path0+meta[i].chunk_file_name);
	// 		//console.log(i+'data size:'+data.length);
	// 		let meta0 = meta[i];
	// 		let metaArray = Object.values(meta0);
	// 		metaArray[5] = metaArray[8];
	// 		metaArray.pop();
	// 		//await instance.insertCertificateChunk(metaArray,0x01);		
	// 	}
	// 	//let inputMeta = [meta0.certificate_type,meta0.certificate_course_name,meta0,certificate_user_name,meta0.certificate_completion_date]
	// 	//await instance.insertCertificateChunk(metaArray,data);
	// 	//await console.log(result);
	// })
	it('test insert hash',async ()=>{
		const instance = await Certificate.deployed();
		let content = fs.readFileSync(path);
		//const data = fs.readFileSync(data_path);
		let meta = JSON.parse(content);
		for(i = 0; i< 1; i++){
			let data = fs.readFileSync(data_path0+meta[i].chunk_file_name);
			let meta0 = meta[i];
			let metaArray = Object.values(meta0);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			await instance.insertCertificateChunk(metaArray,0x01);
		}
		content = fs.readFileSync(path1);
		//const data = fs.readFileSync(data_path);
		meta = JSON.parse(content);
		for(i = 0; i< 1; i++){
			let data = fs.readFileSync(data_path1+meta[i].chunk_file_name);
			let meta0 = meta[i];
			let metaArray = Object.values(meta0);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			await instance.insertCertificateChunk(metaArray,0x01);
		}
		content = fs.readFileSync(path2);
		//const data = fs.readFileSync(data_path);
		meta = JSON.parse(content);
		for(i = 0; i< 1; i++){
			let data = fs.readFileSync(data_path2+meta[i].chunk_file_name);
			let meta0 = meta[i];
			let metaArray = Object.values(meta0);
			metaArray[5] = metaArray[8];
			metaArray.pop();
			await instance.insertCertificateChunk(metaArray,0x01);
		}
		let result = await instance.returnCertificateMetadata(['DBMI','*','*'],true);
		let logStr = await instance.returnLogStr();
		console.log(logStr);
		//let inputMeta = [meta0.certificate_type,meta0.certificate_course_name,meta0,certificate_user_name,meta0.certificate_completion_date]
		//await instance.insertCertificateChunk(metaArray,data);
		//await console.log(result);
	})
})