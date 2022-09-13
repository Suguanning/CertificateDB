//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract Test{
   // bytes public testArray;
    //bytes public testArray2;
    event bytesLog(bytes content);
    event msgLog(string str,uint num);
    function memcpy(uint ptr_dest, uint ptr_src, uint length)internal {
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

    function myMemcpy(uint ptr_dest, uint ptr_src, uint length)internal {
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

    function memcat(uint ptr_l, uint ptr_r)internal  returns(uint){
        uint len_l;
        uint len_r;
        uint length;
        assembly{
            len_l := mload(ptr_l)
            len_r := mload(ptr_r)
            ptr_l := add(ptr_l, 0x20)
            ptr_r := add(ptr_r, 0x20)
            length := add(len_r, len_l)
        }
        uint rt = calloc(length);
        uint ptr = rt + 32;
        memcpy(ptr, ptr_l, len_l);
        ptr += len_l;
        memcpy(ptr, ptr_r, len_r);
        assembly{
            length := mload(rt)
        }
        return rt;
    }
    function calloc(uint size)internal  returns(uint ptr){
        assembly{
            ptr := mload(0x40)
            mstore(ptr,  size)
            mstore(0x40, add(ptr, add(size, 0x20)))
        }
        return ptr;
    }
    function concat(string memory r, string memory l)public  returns(string memory){
        uint ptr_r;
        uint ptr_l;
        assembly{
            ptr_r := r
            ptr_l := l
        }
        uint ptr = memcat(ptr_r, ptr_l);
        uint len;
        assembly{
            len := mload(ptr)
        }
        string memory rt;
        assembly{
            rt := ptr
        }
        return rt;
    }
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
                memTemp := shr(bit_offset, memTemp)
                stoTemp := and(stoTemp, not(shr(bit_offset,not(0))))
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
    string public sa = '13';
    string public sb = '123123';
    string public sd = 'Sure, in that case we need to read a short array (i.e., up to 31 bytes of data and ';
    string[] public testStr = ['123','1234','12345','1234','12345','1234','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n','12345','1234','12345','1234','12345','1234','12345\n'];

    function test() public{
        //bytes memory temp = [0x01,2,3];
        //emit msgLog('leng: ',temp.length);
        uint ptr_des;
        uint ptr_org;
        string memory str;
       
        for(uint i = 0; i<testStr.length;i++){
             string memory temp = testStr[i];
            assembly{
                let len := mload(str)
                ptr_des := add(add(str,0x20),len)
                let len2 := mload(temp)
                len  := add(len,len2)
                mstore(str,len)
                ptr_org := add(temp,0x20)
            }
            memcpy(ptr_des, ptr_org,bytes(temp).length);
            //str = string.concat(str,testStr[i]);
        }
        emit msgLog(str ,bytes(str).length);
    }
    function test2() public{
        //bytes memory temp = [0x01,2,3];
        //emit msgLog('leng: ',temp.length);
        uint ptr_des;
        uint ptr_org;
        string memory str;
       
        for(uint i = 0; i<testStr.length;i++){
            str = string.concat(str,testStr[i]);
        }
        emit msgLog(str ,bytes(str).length);
    }

    bytes[] arrayList;
    function test1() public{
        string memory str1 = '123333333333333333333333333333333333333333333333333333333333333333333';
        arrayList.push(bytes(str1));
        arrayList.push(bytes(str1));
        arrayList.push(bytes(str1));
        for(uint i = 0; i< arrayList.length; i++){
            bytes memory temp = arrayList[i];
            assembly{
                mstore(temp, 2)
            }
            emit bytesLog(temp);
        }

    }

    address[] public objList;
    function creatObj() public{
        Object obj = Object();
        obj.addCnt();
        objList.push(obj); 
    }
}

contract Object{
    uint cnt;
    event msgLog(string str,uint num);
    function addCnt() public{
        cnt++;
    }
    function getCnt() public returns(uint){
        emit msgLog("the cnt is :",cnt);
        return cnt;
    }
}