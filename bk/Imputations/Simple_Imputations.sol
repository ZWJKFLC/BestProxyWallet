// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./module/BaseWalletlogic.sol";
import "./module/SImS_storage.sol";
import "./module/BaseWalletuse.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ISimple_Imputations.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Simple_Imputations is BaseWalletuse{
    constructor(){
        Proxycontract=new IsWalletProxy(address(new IsWalletProxy(address(this))));
        base_logic = address(new BaseWalletlogic(address(this)));
    }
    modifier temp_caller_constraint() {
        temp_caller=msg.sender;
        _;
        temp_caller = address(1);//save gas
    }
}
