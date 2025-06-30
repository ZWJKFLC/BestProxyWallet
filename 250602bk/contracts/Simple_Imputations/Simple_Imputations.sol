// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./module/BaseWalletlogic.sol";
import "./module/SImS_storage.sol";
import "./module/BaseWalletuse.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ISimple_Imputations.sol";
import "./module/ownerfun.sol";

contract Simple_Imputations is BaseWalletuse{
    constructor(address initialOwner){
        transferOwnership(initialOwner);
        Proxycontract=new IsWalletProxy(address(this));
        base_logic = address(new BaseWalletlogic(address(this)));
        setsysteminfo(
            s_systeminfo(
                0.3e16,
                0.2e16,
                IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E)
            )
        );
    }
    receive() external payable {
    }
    fallback() external payable {
    }
    struct basetransinfo{
        address recipient;
        uint value;
    }
    struct tokentransinfo{
        address token;
        basetransinfo[] basetransinfos;
        uint total;
    }
    function pi_tokens(tokentransinfo[] calldata tokentransinfos) public{
        for (uint256 i = 0; i < tokentransinfos.length; i++) {
            pi_token(tokentransinfos[i]);
        }
    }
    function pi_token(tokentransinfo calldata _tokentransinfo) public{
        IERC20(_tokentransinfo.token).transferFrom{gas: 100000}(msg.sender,address(this),_tokentransinfo.total);
        basetransinfo[] calldata n_basetransinfos=_tokentransinfo.basetransinfos;
        for(uint256 i=0;i<n_basetransinfos.length;i++){
            IERC20(_tokentransinfo.token).transfer{gas: 100000}(n_basetransinfos[i].recipient,n_basetransinfos[i].value);
        }
    }
}

