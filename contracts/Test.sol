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
    string public sa = '13';
    string public sb = '123123';
    string public sd = 'Sure, in that case we need to read a short array (i.e., up to 31 bytes of data and ';

    function test() public{
        //bytes memory temp = [0x01,2,3];
        //emit msgLog('leng: ',temp.length);
        string memory str;
        //string memory temp = sb;
        uint ptr_a;
        uint ptr_b;
        uint ptr_d;
        // uint ptr_c;
        string memory c;
        uint data;
        string memory temp = new string(bytes(sd).length);
        assembly{
            //let value := sload(keccak256(sd.slot, div(sub(sload(sd.slot), 1), 2)))
            let ptr := mload(0x40)
            mstore(ptr,sd.slot)
            mstore(0x40,add(ptr, 0x20))

            ptr_a := keccak256(ptr,0x20)
            ptr_b := add(temp,0x20)

            mstore(temp,256)
        }
        sto2mem(ptr_b,ptr_a,bytes(sd).length);
        //sto2mem(ptr_b+0x20,ptr_a+1,32);
        emit msgLog(temp,data);
        emit msgLog('length:',2*bytes(sd).length+1);
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
}