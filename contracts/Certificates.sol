//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract Certificate {
	uint256 public recordIndex = 0;
	struct Metadata{
		uint256 recordID;
		string certificateType;
		string courseName;
		string userName;
		string completionDate;
		string expirationDate;
		string pdfName;
		string uploadDate;
		uint pdfSize;
		bool notExpired;
	}

	struct Cetification {
		Metadata metadata;
		//chunk index => bytes array
		mapping(uint16 => bytes) chunksData;
		mapping(uint16 => bool) chunkExist;
		uint16[] indexBuffer;
		uint[] sizeBuffer;
		bytes[] chunkBuffer;
		//bytes pdfData;
		uint256 chunksSumSize;
	}

	mapping(string => bytes32[]) mapByCertificateType;
	mapping(string => bytes32[]) mapByCourseName;
	mapping(string => bytes32[]) mapByUserName;

	//TODO: mapping pdf name string to meta hash may improe the searching speed

	//meta hash => cetification
	mapping(bytes32 => Cetification) certificationList;
	//meta hash => isFirstAdd
	mapping(bytes32 => bool) isAddedHash;
	//recordIndex => meta hash
	bytes32[] hashList;

	string public logString = 'log:';

    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
	uint constant internal CHUNKSIZE = 15000;
	event msgLog(string str);
	event dataLog(bytes b);
	event arrayLog(uint16[] array);
	event chunkAdded(string chunkName, uint index);
	event fileRetriving(string userName);
	event fileLostIndex(uint16 index);
	//==============================================================================
    // PUBLIC FUNCTIONS
    //==============================================================================

	function insertCertificateChunk(string[] calldata _metaData, bytes calldata _data) external{

		// string memory certificateType = _metaData[0];
		// string memory courseName = _metaData[1];
		// string memory userName = _metaData[2];
		// string memory completionDate = _metaData[3];
		// string memory expirationDate = _metaData[4];
		// string memory chunkFileName = _metaData[5];
		// string memory uploadDate = _metaData[6];
		// string memory fileSize = _metaData[7];
		string memory pdfName;
		uint  pdfSize;
		uint16 chunkIndex = 1;

		pdfName = getPdfNameFromChunksName(_metaData[5]);
		chunkIndex = getChunksIndexFromChunksName(_metaData[5]);
		pdfSize = string2uint(_metaData[7]);

		string memory metaStr = string.concat(_metaData[0],_metaData[1],_metaData[2]);
		metaStr = string.concat(metaStr,_metaData[3],_metaData[4]);
		metaStr = string.concat(metaStr,pdfName);
		bytes32 metaHash = sha256(bytes(metaStr));
		
		if(isAddedHash[metaHash] == false){
			isAddedHash[metaHash] = true;
			Metadata memory metadata = Metadata(recordIndex, _metaData[0], _metaData[1], _metaData[2], _metaData[3], _metaData[4], pdfName, _metaData[6], pdfSize, true); 
			certificationList[metaHash].metadata = metadata;

			certificationList[metaHash].indexBuffer.push(chunkIndex);
			certificationList[metaHash].sizeBuffer.push(_data.length);
			certificationList[metaHash].chunksSumSize += _data.length;
			certificationList[metaHash].chunkExist[chunkIndex] = true;
			certificationList[metaHash].chunkBuffer.push(_data);


			mapByCertificateType[_metaData[0]].push(metaHash);
			mapByCourseName[_metaData[1]].push(metaHash);
			mapByUserName[_metaData[2]].push(metaHash);
			hashList.push(metaHash);
			recordIndex += 1;
			//////emit chunkAdded(pdfName, chunkIndex);
		}
		else{
			if(!certificationList[metaHash].chunkExist[chunkIndex]){
				certificationList[metaHash].chunkExist[chunkIndex] = true;
				certificationList[metaHash].chunksSumSize += _data.length;
				certificationList[metaHash].chunkBuffer.push(_data);
				certificationList[metaHash].indexBuffer.push(chunkIndex);
				certificationList[metaHash].sizeBuffer.push(_data.length);
				//////emit chunkAdded(pdfName, chunkIndex);
			}
		}
	}

	function returnCertificateMetadata(string[] calldata _requirements, bool _notExpired) external returns(bytes memory){
		string memory certificateTypeR = _requirements[0];
		string memory courseNameR = _requirements[1];
		string memory userNameR = _requirements[2];
		string memory certificateType;
		string memory courseName;
		bytes32[] memory fileArray;
		bytes32[] memory correctFile;
		string memory result;
		uint cnt = 0;

		if(!strCompare(userNameR,'*')){
			fileArray = mapByUserName[userNameR];
			bytes32[] memory temp = new bytes32[](fileArray.length);
			for(uint i = 0; i < fileArray.length; i++){
				
				certificateType = certificationList[fileArray[i]].metadata.certificateType;
				courseName = certificationList[fileArray[i]].metadata.courseName;
				if(!strCompare(courseNameR,courseName) && !strCompare(courseNameR,'*')){
					continue;
				}
				if(!strCompare(certificateTypeR,certificateType) && !strCompare(certificateTypeR,'*')){
					continue;
				}
				if( _notExpired && !isValid(fileArray[i])){
					continue;
				}
				temp[cnt] = fileArray[i];
				cnt++;
			}
			correctFile = temp;
		}
		else if(!strCompare(courseNameR,'*')){
			fileArray = mapByCourseName[courseNameR];
			bytes32[] memory temp = new bytes32[](fileArray.length);
			for(uint i = 0; i < fileArray.length; i++){
				certificateType = certificationList[fileArray[i]].metadata.certificateType;
				if(!strCompare(certificateTypeR,certificateType)&& !strCompare(certificateTypeR,'*')){
					continue;
				}

				if( _notExpired && !isValid(fileArray[i])){
					continue;
				}
				temp[cnt] = fileArray[i];
				cnt++;
			}
			correctFile = temp;
		}
		else if(!strCompare(certificateTypeR,'*')){
			fileArray = mapByCertificateType[certificateTypeR];
			bytes32[] memory temp = new bytes32[](fileArray.length);
			if(_notExpired){
				for(uint i = 0; i < fileArray.length; i++){
					if(!isValid(fileArray[i])){
						continue;
					}
					temp[cnt] = fileArray[i];
					cnt++;
				}
				correctFile = temp;
			}
			else{
				correctFile = fileArray;
				cnt = fileArray.length;
			}
		}
		else{
			if(_notExpired){
				bytes32[] memory temp = new bytes32[](recordIndex);
				for(uint i = 0; i < recordIndex; i++){
					if(!isValid(hashList[i])){
						continue;
					}
					temp[cnt] = hashList[i];
					cnt++;
				}
				correctFile = temp;
			}else{
				correctFile = hashList;
				cnt = recordIndex;
			}
		}

		if(cnt == 0){
			logString = 'No certificates matched that query.\n';
			return bytes('No certificates matched that query.\n');
		}
		else{
			for(uint i = 0; i < cnt; i++){
				result = concat(result, outputMetadataByMetahash(correctFile[i]));
			}
			logString = result;
			return bytes(result);
		}
	}

//TODO: date range search
	uint16[] mapPrior = [2,1,0];
	uint16[] normalPrior = [5,2,1,3,4,6,0];
	function getCertificatePDF( string[] calldata _requirements, bool _notExpired) external returns(bytes memory){
		// string memory certificateType = _requirements[0];
		// string memory courseName = _requirements[1];
		// string memory userName = _requirements[2];
		// string memory completionDate = _requirements[3];
		// string memory expirationDate = _requirements[4];
		// string memory FileName = _requirements[5];
		// string memory uploadDate = _requirements[6];
		uint16[] memory searchVector = new uint16[](7);
		uint16 cnt = 0;
		bytes32[] memory fileArray;
		
		searchVector[0] = 100;
		cnt = 1;
		for(uint i = 0; i < mapPrior.length; i++){
			if(!strCompare(_requirements[mapPrior[i]], '*')){
				searchVector[0] = mapPrior[i];
				cnt = 1;
				break;
			}
		}

		for(uint i = 0; i < normalPrior.length; i++){
			if(!strCompare(_requirements[normalPrior[i]], '*')){
				if(normalPrior[i] != searchVector[0]){
					searchVector[cnt] = normalPrior[i];
					cnt++;
				}
			}
		}

		if(searchVector[0] == 100){
			//fileArray = hashList;
			revert("CONDITION ERRO");
		}
		else{
			if(searchVector[0] == 0){
				fileArray = mapByCertificateType[_requirements[0]];
				//////emit msgLog(string.concat('map by: ',_requirements[0]));
			}
			else if(searchVector[0] == 1){
				fileArray = mapByCourseName[_requirements[1]];
				//////emit msgLog(string.concat('map by: ',_requirements[1]));
			}
			else if(searchVector[0] == 2){
				fileArray = mapByUserName[_requirements[2]];
				//////emit msgLog(string.concat('map by: ',_requirements[2]));
			}
			else{
				revert("CONDITION ERRO2");
			}
		}
		//////emit msgLog(string.concat('search size: ',uint2string(fileArray.length)));
		string memory dateTemp = '01/01/1970';
		bytes32 matchedHash;
		bool isFound = false;
		for(uint i = 0; i< fileArray.length; i++){
			string[] memory metadata = new string[](7);
			bool isMatch = true;
			metadata[0] = certificationList[fileArray[i]].metadata.certificateType;
			metadata[1] = certificationList[fileArray[i]].metadata.courseName;
			metadata[2] = certificationList[fileArray[i]].metadata.userName;
			metadata[3] = certificationList[fileArray[i]].metadata.completionDate;
			metadata[4] = certificationList[fileArray[i]].metadata.expirationDate;
			metadata[5] = certificationList[fileArray[i]].metadata.pdfName;
			metadata[6] = certificationList[fileArray[i]].metadata.uploadDate;
			for(uint j = 0; j < (searchVector.length - 1); j++){
				if(!strCompare(metadata[searchVector[j]], _requirements[searchVector[j]])&&!strCompare('*', _requirements[searchVector[j]])){
					isMatch = false;
					//////emit msgLog(string.concat('matching fail: ',metadata[searchVector[j]],_requirements[searchVector[j]]));
					break;
				}
			}
			if(isMatch){
				//////emit msgLog(string.concat('matched case found, index:',uint2string(i)));
				if(_notExpired){
					if(isValid(fileArray[i])){
						if(!dateCompare(dateTemp, metadata[3])){
							isFound = true;
							matchedHash = fileArray[i];
							dateTemp = metadata[3];
						}
					}else{
						//////emit msgLog(string.concat('file outdate, user name: ',metadata[2]));
					}
				}
				else{
					if(!dateCompare(dateTemp, metadata[3])){
						isFound = true;
						matchedHash = fileArray[i];
						dateTemp = metadata[3];
					}
				}
			}
		}
		if(isFound){
			return ouputPDFdataByMetahash(matchedHash);
		}
		else{
			//////emit msgLog(string.concat('No certificates matched that query,\n map by: ',uint2string(searchVector[0])));
			//revert('CERTIFICATION NOT FOUND');
			bytes memory by = 'No certificates matched that query,\n';
			return by;
		}
	}

    //==============================================================================
    // PRIVATE FUNCTIONS
    //==============================================================================

	/**
    * a function to check if the str1 is equal to str2;
    * @param str1 the string you want to compare.
	* @param str2 the string you want to compare.
    * @return bool 
    */
	 
	function strCompare(string memory str1, string memory str2) internal pure returns(bool){
		return sha256(bytes(str1)) == sha256(bytes(str2));
	}

    //==============================================================================

	/**
    * a function to check if the date1 is later than date2;
    * @param _date1 date string you want to compare.
	* @param _date2 date string you want to compare.
    * @return bool true: _date1 is later than _date2, false: _date1 is earlier than _date2
    */
	 
	function dateCompare(string memory _date1, string memory _date2) internal pure returns(bool){
		uint year2;
		uint month2;
		uint day2;
		uint year;
		uint month;
		uint day;
		(year2, month2, day2) = date2uint(_date2);
		(year, month, day) = date2uint(_date1);
		if(year > year2){
			return true;
		}
		else if(year == year2){
			if(month > month2){
				return true;
			}
			else if(month == month2){
				if(day >= day2){
					return true;
				}
			}
		}
		return false;
	}
    //==============================================================================

	/**
    * get the pdf name index from the chunk name;
    * @param _chunksName The chunk name.
    * @return string the pdf name string.
    */
	function getPdfNameFromChunksName(string calldata _chunksName) internal pure returns(string memory) {
		return _chunksName[0:15];
	}

    //==============================================================================

	/**
    * get the chunk's index from the chunk name;
    * @param _chunksName The chunk name.
    * @return uint16 the chunk index in uint16.
    */

	function getChunksIndexFromChunksName(string calldata _chunksName) internal pure returns(uint16) {
		uint len = bytes(_chunksName).length;
		uint tempNum = string2uint(_chunksName[21:len]);
		return uint16(tempNum);
	}

    //==============================================================================

	/**
    * a function to convert string to uint;
    * @param _str The string you want to convert.
    * @return uint the uint after convertion.
    */

	function string2uint(string memory _str) internal pure returns(uint) {
		bytes memory tempBytes = bytes(_str);
		uint len = tempBytes.length;
		uint tempNum = 0;
		for(uint i = 0; i < len; i++){
			require(uint8(tempBytes[i])>=48 && uint8(tempBytes[i]) <= 57,'string2uint erro');
			tempNum = tempNum + uint(uint8(tempBytes[i])-48)*(10**(len-i-1));
		}
		return tempNum;
	}

    //==============================================================================

	/**
    * a function to convert uint to string;
    * @param _num The uint you want to convert.
    * @return string the string after convertion.
    */

	function uint2string(uint _num) internal pure returns(string memory){
        bytes memory reversed = new bytes(100);
        uint i = 0;
		if(_num == 0){
			return '0';
		}
        while (_num != 0) {
            uint remainder = _num % 10;
            _num = _num / 10;

            reversed[i++] = bytes1(48 + uint8(remainder % 10));
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);  // memory isn't implicitly convertible to storage
        return str;
	}
	
    //==============================================================================

	/**
    * a function to check if a certification is expired and update it's status;
    * @param _metaHash The hash of the certification you want to check.
    * @return bool true: valid, false: expired.
    */

	function isValid(bytes32 _metaHash) internal returns(bool){
	Metadata memory _metadata = certificationList[_metaHash].metadata;
		if(_metadata.notExpired){
			uint yearNow;
			uint monthNow;
			uint dayNow;
			uint year;
			uint month;
			uint day;
			(yearNow, monthNow, dayNow) = _daysToDate(block.timestamp);
			(year, month, day) = date2uint(_metadata.expirationDate);
			if(year > yearNow){
				return true;
			}
			else if(year == yearNow){
				if(month > monthNow){
					return true;
				}
				else if(month == monthNow){
					if(day >= dayNow){
						return true;
					}
				}
			}
			certificationList[_metaHash].metadata.notExpired = false;
			return false;
		}
		else{
			return false;
		}
	}

    //==============================================================================

	/**
    * a function to convert date string to year, month and day;
    * @param _date The string of the date you want to convert.
    * @return year year in uint.
	* @return month month in uint.
	* @return day day in uint.
    */

	function date2uint(string memory _date) internal pure returns(uint year, uint month, uint day){

		bytes memory tempBytes = bytes(_date);

		for(uint i = 0 ;i<2;i++){
			month = month + uint(uint8(tempBytes[i])-48)*(10**(2-i-1));
		}
		for(uint i = 3 ;i<5;i++){
			day = day + uint(uint8(tempBytes[i])-48)*(10**(5-i-1));
		}
		for(uint i = 6 ;i<10;i++){
			year = year + uint(uint8(tempBytes[i])-48)*(10**(10-i-1));
		}
		//return (year - 1970)*31556736 + (month - 1)*2629743
	}
	
    //==============================================================================

	/**
    * a function to convert Unix timestamp to year, month and day;
    * @param _timestamp The timestamp you want to convert.
    * @return year year in uint.
	* @return month month in uint.
	* @return day day in uint.
    */

    function _daysToDate(uint _timestamp) internal pure returns (uint year, uint month, uint day) {
        uint _days = uint(_timestamp) / SECONDS_PER_DAY;
        uint L = _days + 68569 + OFFSET19700101;
        uint N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * year / 4 + 31;
        month = 80 * L / 2447;
        day = L - 2447 * month / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;
    }

    //==============================================================================

	/**
    * export specific metadata according to _metaHash
    * @param _metaHash The hash of the certification you want to export.
    * @return Returns the metadata string.
    */

	function outputMetadataByMetahash(bytes32 _metaHash) internal view returns(string memory) {
		string memory result;
		result = certificationList[_metaHash].metadata.certificateType;
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.courseName);
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.userName);
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.completionDate);
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.expirationDate);
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.pdfName);
		result = concat(result,'\t');
		result = concat(result,certificationList[_metaHash].metadata.uploadDate);
		result = concat(result,'\t');
		result = concat(result,uint2string(certificationList[_metaHash].metadata.pdfSize));
		result = concat(result,'\n');
		return result;
	}

    //==============================================================================

	/**
    * export specific pdf data according to _metaHash
    * @param _metaHash The hash of the certification you want to export.
    * @return Returns the pdf data sequence.
    */

	function ouputPDFdataByMetahash(bytes32 _metaHash) internal returns(bytes memory){
		require(certificationList[_metaHash].metadata.pdfSize == certificationList[_metaHash].chunksSumSize, "FILE DAMAGED");
		uint256 attachedSize = 0;
		uint result_p;
		uint data_p;
		uint buffer_p;
		uint slot_p;
		Cetification storage cert = certificationList[_metaHash];
		uint16[] memory indexBuffer = cert.indexBuffer;
		uint[] memory sizeBuffer = cert.sizeBuffer;
		bytes[] storage chunkBuffer = certificationList[_metaHash].chunkBuffer;
		bytes storage chunk;
		bytes memory data; //= new bytes(cert.metadata.pdfSize);
		result_p = calloc(cert.metadata.pdfSize);
		assembly{
			data_p := add(result_p, 0x20)
			slot_p := mload(0x40)
			mstore(0x40, add(slot_p,0x20))
		}
		for(uint i = 0; i < indexBuffer.length; i++){
			chunk = chunkBuffer[i];
			assembly{ 
				mstore(slot_p, chunk.slot)
				buffer_p := keccak256(slot_p, 0x20)
			}
			uint16 index = indexBuffer[i];
			sto2mem(data_p + attachedSize, buffer_p, sizeBuffer[i]);
			attachedSize += sizeBuffer[i];
		}
		assembly{
			data := result_p
		}
		return data;
	}

	uint16 testNum = 1;
	function setTestNum(uint16 _testNum) public {
		testNum = _testNum;
	}

    //==============================================================================

	/**
    * copy data form storage to memory
    * @param _ptr_dest the memory pointer
	* @param _ptr_src the storage pointer
    */
    function sto2mem(uint _ptr_dest, uint _ptr_src, uint _length)internal {
            uint ptr_dest =_ptr_dest;
            uint ptr_src =_ptr_src;
            uint length =_length;
        for(;length>=0x20;length-=0x20){
            assembly{
                mstore(ptr_dest, sload(ptr_src))
                ptr_src := add(ptr_src, 0x01)
                ptr_dest := add(ptr_dest, 0x20)
            }
        }
        assembly{
            let mask := sub(exp(256,  sub(32, length)), 1)
            let a := and(sload(ptr_src), not(mask))
            let b := and(mload(ptr_dest), mask)
            mstore(ptr_dest, or(a, b))
        }
    }

    //==============================================================================

	/**
    * memory allocation
    * @param size size of memory that you want to apply for
	* @return Returns the memory pointer
    */
	function calloc(uint size)internal  returns(uint ptr){
        assembly{
            ptr := mload(0x40)
            mstore(ptr,  size)
            mstore(0x40, add(ptr, add(size, 0x20)))
        }
        return ptr;         
    }
    //==============================================================================

	/**
    * Private helper function to concatenate two strings
    * @param a The first string to concatenate. Will be the first part of the final string.
    * @param b The second string to concatenate. Will be appended to the first string to produce the final result.
    * @return Returns the concatenation of the two strings passed as parameters, with the second string (b) appended to the first string (a).
    */

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(bytes(a), bytes(b)));
    }
	function returnLogStr() public view returns(string memory){
		return logString;
	}
}