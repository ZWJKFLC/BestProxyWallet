// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

interface i_BW_user{
    function getwalletadd(address treasury,bytes32 path)
    external view 
    returns(address walletadd);

}