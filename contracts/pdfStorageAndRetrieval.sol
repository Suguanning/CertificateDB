
// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract pdfStorageAndRetrieval {
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
		//bool notExpired;
	}

	struct Cetification {
		uint256 chunksSumSize;
		mapping(uint16 => bool) chunkExist;
		Metadata metadata;
		bytes pdfData;
	}

	mapping(string => bytes32[]) mapByMetadata;
	mapping(string => mapping(uint => bytes32[]))mapByStrAndTime;
	//TODO: mapping pdf name string to meta hash may improe the searching speed
	mapping(bytes32 => string) metaString;
	//meta hash => cetification
	mapping(bytes32 => Cetification) certificationList;
	//meta hash => isFirstAdd
	mapping(bytes32 => bool) isAddedHash;
	//recordIndex => meta hash
	bytes32[] hashList;
	bytes32[] hashListValid;
	mapping(string => bytes32) latestComplete;
	uint latestDateG;
	uint maxStrLen;
    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
	uint constant internal CHUNKSIZE = 15000;
	event msgLog(string str, uint num);
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
		bytes memory data = _data;
		uint ptr_data;
		uint ptr_pdfData;
		pdfName = getPdfNameFromChunksName(_metaData[5]);
		chunkIndex = getChunksIndexFromChunksName(_metaData[5]);
		pdfSize = string2uint(_metaData[7]);
		string memory metaStr = string.concat(_metaData[0],_metaData[1],_metaData[2]);
		metaStr = string.concat(metaStr,_metaData[3],_metaData[4]);
		metaStr = string.concat(metaStr,pdfName);
		bytes32 metaHash = sha256(bytes(metaStr));
		
		if(isAddedHash[metaHash] == false){
			isAddedHash[metaHash] = true;
			Metadata memory metadata = Metadata(recordIndex, _metaData[0], _metaData[1], _metaData[2], _metaData[3], _metaData[4], pdfName, _metaData[6], pdfSize); 
			certificationList[metaHash].metadata = metadata;
			metaString[metaHash] = connectMetadata(certificationList[metaHash].metadata);
			maxStrLen += bytes(metaString[metaHash]).length;
			certificationList[metaHash].chunksSumSize += _data.length;
			certificationList[metaHash].chunkExist[chunkIndex] = true;

			bytes storage pdfData = certificationList[metaHash].pdfData;
			uint length = _data.length;

			assembly{
				let slot := pdfData.slot
				sstore(slot,add(mul(pdfSize,2),1))
				let ptr := mload(0x40)
				mstore(0x40,add(ptr,0x20))
				mstore(ptr,slot)
				ptr_pdfData := keccak256(ptr,0x20)
				ptr_data := add(data,0x20)
			}
			mem2sto(ptr_pdfData, ptr_data, (chunkIndex-1) * CHUNKSIZE, length);
			updateMap(metadata.certificateType, metadata.courseName, metadata.userName, metaHash);
			recordIndex += 1;
		}
		else{
			if(!certificationList[metaHash].chunkExist[chunkIndex]){
				certificationList[metaHash].chunkExist[chunkIndex] = true;
				certificationList[metaHash].chunksSumSize += _data.length;

				bytes storage pdfData = certificationList[metaHash].pdfData;
				uint length = _data.length;

				assembly{
					let slot := pdfData.slot
					let ptr := mload(0x40)
					mstore(0x40,add(ptr,0x20))	
					mstore(ptr,slot)
					ptr_pdfData := keccak256(ptr,0x20)
					ptr_data := add(data,0x20)
				}
				mem2sto(ptr_pdfData, ptr_data, (chunkIndex-1) * CHUNKSIZE, length);
			}
		}
	}

	function returnCertificateMetadata(string[] calldata _requirements, bool _notExpired) external view returns(bytes memory){
		string memory reqStr = string.concat(_requirements[0],_requirements[1],_requirements[2]);
		string memory result = new string(maxStrLen);
		uint resPtr;
		assembly{
			resPtr := result
		}
		bytes32[]  memory metaHash;
		uint offset = 0;
		bool isfound = false;
		if(_notExpired){
			uint yearNow;
			uint monthNow;
			uint dayNow;
			(yearNow, monthNow, dayNow) = _daysToDate(block.timestamp);
			uint dateNow = yearNow*100 + monthNow;
			uint len;
			if(strCompare(_requirements[2],'*')){
				len = mapByStrAndTime[reqStr][dateNow].length;
				bytes32[] memory tempList = new bytes32[](len);
				uint cnt = 0;
				
				for(uint i = 0; i<len ;i++){
					if(isValid(mapByStrAndTime[reqStr][dateNow][i])){
						tempList[cnt] = mapByStrAndTime[reqStr][dateNow][i];
						cnt++;
						isfound = true;
					}
				}					
					//tempList加到result
				for(uint i = 0; i<cnt; i++){
					offset = addStr2Result(resPtr,tempList[i],offset);
				}

				for(uint date = dateNow; date <= latestDateG; date = dateAdd(date)){
					bytes32[] memory list =  mapByStrAndTime[reqStr][date];
					for(uint i = 0; i < list.length; i++){
						offset = addStr2Result(resPtr,list[i],offset);
						isfound = true;
					}
					
				}
			}
			else{
				metaHash = mapByMetadata[reqStr];
				for(uint i = 0; i < metaHash.length ; i++){
					if(isValid(metaHash[i])){
						offset = addStr2Result(resPtr,metaHash[i],offset);		
						isfound = true;			
					}
				}
			}
		}
		else{
			if(strCompare(reqStr,"***")){
				metaHash = hashList;
			}
			else{
				metaHash = mapByMetadata[reqStr];
			}

			for(uint i = 0; i < metaHash.length; i++){
				//加到result
				offset = addStr2Result(resPtr,metaHash[i],offset);
				isfound = true;
			}
		}

		if(isfound){
			if(offset == 0){
				return bytes("No certificates matched that query.\n");
			}
			//TODO: 修改result的长度位
			assembly{
				mstore(result,offset)
			}
			return bytes(result);
		}
		else{
			return bytes("No certificates matched that query.\n");
		}

	}

	function getCertificatePDF( string[] calldata _requirements, bool _notExpired) external view returns(bytes memory){
		// string memory certificateType = _requirements[0];
		// string memory courseName = _requirements[1];
		// string memory userName = _requirements[2];
		string memory completionDate = _requirements[3];
		string memory expirationDate = _requirements[4];
		string memory fileName = _requirements[5];
		string memory uploadDate = _requirements[6];
		bytes32 result;
		string memory reqStr;

		reqStr = string.concat(_requirements[0],_requirements[1],_requirements[2]);
		result = latestComplete[reqStr];
		if(result == bytes32(0)){
			//no matched
			return bytes('No certificates matched that query.\n');
		}

		if(!strCompare(expirationDate,"*")){
			if(!dateCompare(certificationList[result].metadata.expirationDate,expirationDate)){
				result = searchPdf(_requirements,_notExpired);
				if(result != bytes32(0)){
					return ouputPDFdataByMetahash(result);
				}else{
					return bytes('No certificates matched that query.\n');
				}
			}
		}

		if(!strCompare(uploadDate,"*")){
			if(!dateCompare(certificationList[result].metadata.uploadDate, uploadDate)){
				result = searchPdf(_requirements,_notExpired);
				if(result != bytes32(0)){
					return ouputPDFdataByMetahash(result);
				}else{
					return bytes('No certificates matched that query.\n');
				}
			}
		}
		if(!strCompare(completionDate,"*")){
			if(!dateCompare(certificationList[result].metadata.completionDate,completionDate)){
				return bytes('No certificates matched that query.\n');
			}
		}

		if(_notExpired){
			if(!isValid(result)){
				result = searchPdf(_requirements,_notExpired);
				if(result != bytes32(0)){
					return ouputPDFdataByMetahash(result);
				}else{
					return bytes('No certificates matched that query.\n');
				}
			}
		}

		if(!strCompare(fileName,"*")){
			if(!strCompare(certificationList[result].metadata.pdfName,fileName)){
				result = searchPdf(_requirements,_notExpired);
				if(result != bytes32(0)){
					return ouputPDFdataByMetahash(result);
				}else{
					return bytes('No certificates matched that query.\n');
				}
			}
		}
		return ouputPDFdataByMetahash(result);
	}

    //==============================================================================
    // PRIVATE FUNCTIONS
    //==============================================================================

	function addStr2Result(uint _resPtr, bytes32 _metaHash, uint _offset) internal view returns(uint) {
		uint ptr;
		uint ptr2;
		uint offset = _offset;
		string memory temp = metaString[_metaHash];
		assembly{
			ptr := add(_resPtr,0x20)
			ptr2 := add(temp,0x20) 
		}
		memcpy(ptr+offset,ptr2,bytes(temp).length);
		offset += bytes(temp).length;
		return offset;
	}

	function searchPdf( string[] calldata _requirements, bool _notExpired) internal view returns(bytes32){
		string memory reqStr = string.concat(_requirements[0],_requirements[1],_requirements[2]);
		string memory completionDate = _requirements[3];
		string memory expirationDate = _requirements[4];
		string memory fileName = _requirements[5];
		string memory uploadDate = _requirements[6];
		bytes32[] memory tempList;
		if(strCompare(reqStr,'***')){
			tempList = hashList;
		}else{
			tempList = mapByMetadata[reqStr];
		}
		
		string memory latestDate = "01/01/1970";
		bytes32 result;
		bool isFound = false;
		if(tempList.length == 0){
			return bytes32(0);
		}
		else{
			for(uint i = 0; i<tempList.length; i++){
				bytes32 temp = tempList[i];
				if(_notExpired){
					if(!isValid(temp)){
						continue;
					}
				}
				if(!strCompare(completionDate,"*")){
					if(!dateCompare(certificationList[temp].metadata.completionDate,completionDate)){
						continue;
					}
				}
				if(!strCompare(expirationDate,"*")){
					if(!dateCompare(certificationList[temp].metadata.expirationDate,expirationDate)){
						continue;
					}
				}
				if(!strCompare(uploadDate,"*")){
					if(!dateCompare(certificationList[temp].metadata.uploadDate,uploadDate)){
						continue;
					}
				}
				if(!strCompare(fileName,"*")){
					if(!strCompare(certificationList[temp].metadata.pdfName,fileName)){
						continue;
					}
				}
				if(_notExpired){
					if(!isValid(temp)){
						continue;
					}
				}
				if(dateCompare(certificationList[temp].metadata.completionDate, latestDate)){
					result = temp;
					latestDate = certificationList[temp].metadata.completionDate;
					isFound = true;
				}
			}
			if(isFound){
				return result;
			}
			else{
				return bytes32(0);
			}
		}
	}

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
    * @return bool true: _date1 is later than _date2 or _date1 is equal to _date2, false: _date1 is earlier than _date2
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

	function isValid(bytes32 _metaHash) internal view returns(bool){
		Metadata memory _metadata = certificationList[_metaHash].metadata;
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
		//certificationList[_metaHash].metadata.notExpired = false;
		return false;
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
    * export specific pdf data according to _metaHash
    * @param _metaHash The hash of the certification you want to export.
    * @return Returns the pdf data sequence.
    */
	function ouputPDFdataByMetahash(bytes32 _metaHash) internal view returns(bytes memory){
		//require(certificationList[_metaHash].metadata.pdfSize == certificationList[_metaHash].chunksSumSize, "FILE DAMAGED");
		return certificationList[_metaHash].pdfData;
	}

    //==============================================================================

	/**
    * copy data form storage to memory
    * @param _ptr_dest the memory pointer
	* @param _ptr_src the storage pointer
    */
    function sto2mem(uint _ptr_dest, uint _ptr_src, uint _length)internal view {
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
    * copy data form memory to storage
    * @param _ptr_dest the storage pointer
	* @param _ptr_src the memory pointer
	* @param _offset the storage pointer offset (byte)
    */
    function mem2sto(uint _ptr_dest, uint _ptr_src, uint _offset, uint _length)internal {
           
		uint ptr_src =_ptr_src;
		uint length =_length;
		uint offset = _offset;
		uint ptr_dest =_ptr_dest;

        if(offset != 0){
            uint slot_offset = offset/0x20;
		    uint bytes_offset = offset % 0x20;
		    uint bit_offset = bytes_offset * 8;
            ptr_dest =_ptr_dest + slot_offset;
            assembly{
                let stoTemp := sload(ptr_dest)
                let memTemp := mload(_ptr_src)
                //memTemp := shr(bit_offset, memTemp)
				memTemp := div(memTemp,exp(2,bit_offset))
				let mask := not(div(not(0),exp(2,bit_offset)))
                //stoTemp := and(stoTemp, not(shr(bit_offset,not(0))))
				stoTemp := and(stoTemp, mask)
                stoTemp := or(stoTemp, memTemp)
                sstore(ptr_dest, stoTemp)
            }
            if(length >= 32 - bytes_offset){
                length -= (32 - bytes_offset);
            }
            else{
                length = 0;
                return;
            }
            ptr_src += (32 - bytes_offset); 
            ptr_dest += 1;
        }

        for(;length>=0x20;length-=0x20){
            assembly{
                sstore(ptr_dest, mload(ptr_src))
                ptr_src := add(ptr_src, 0x20)
                ptr_dest := add(ptr_dest, 0x01)
            }
        }
        assembly{
            let mask := sub(exp(256,  sub(32, length)), 1)
            let a := and(mload(ptr_src), not(mask))
            let b := and(sload(ptr_dest), mask)
            sstore(ptr_dest, or(a, b))
        }
    }

	function memcpy(uint ptr_dest, uint ptr_src, uint length)internal pure {
        for(;length>=0x20;length-=0x20){
            assembly{
                mstore(ptr_dest, mload(ptr_src))
                ptr_src := add(ptr_src, 0x20)
                ptr_dest := add(ptr_dest, 0x20)
            }
        }
        assembly{
            let mask := sub(exp(256,  sub(32, length)), 1)
            let a := and(mload(ptr_src), not(mask))
            let b := and(mload(ptr_dest), mask)
            mstore(ptr_dest, or(a, b))
        }
    }
    //==============================================================================

	/**
    * memory allocation
    * @param size size of memory that you want to apply for
	* @return ptr the memory pointer
    */
	function calloc(uint size)internal  pure returns(uint ptr){
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

}