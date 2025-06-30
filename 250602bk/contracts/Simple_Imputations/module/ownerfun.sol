// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IERC20.sol";
import "./BaseWalletlogic.sol";
import "./SImS_storage.sol";
contract ownerfun is Ownable,SImS_storage{
    function setsysteminfo(s_systeminfo memory _systeminfo) public onlyOwner{
        systeminfo=_systeminfo;
    }
    


}