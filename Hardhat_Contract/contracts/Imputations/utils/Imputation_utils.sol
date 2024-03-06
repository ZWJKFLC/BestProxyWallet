// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Imputation_utils{
    function isContract(address addr)public view returns(bool){
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}