// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "../../interfaces/Itotal.sol";
import "../ImS_storage.sol";

contract ownerfun is ImS_storage{
    function setsysteminfo(s_systeminfo memory _systeminfo) public onlyOwner{
        systeminfo=_systeminfo;
    }
}