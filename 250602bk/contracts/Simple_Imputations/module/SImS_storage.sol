// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./IsWalletProxy.sol";
import "../interfaces/ISWAP.sol";
contract SImS_storage{
    IsWalletProxy public Proxycontract;
    address public base_logic;
    mapping(address=>address) public Indiv_logic;
    address temp_caller = address(1);

    struct s_systeminfo{
        uint256 totalfee;
        uint256 checkfee;
        IUniswapV2Router router;
    }
    s_systeminfo public systeminfo;
}