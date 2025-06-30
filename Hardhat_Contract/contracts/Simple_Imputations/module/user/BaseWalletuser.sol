// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./i_BW_user.sol";
import "./r_BW_user.sol";
import "./s_BW_user.sol";
import "./w_BW_user.sol";
abstract contract BaseWalletuser is r_BW_user,w_BW_user
{
    
}