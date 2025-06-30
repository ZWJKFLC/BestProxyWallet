// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "../../interfaces/Itotal.sol";
import "../ImS_storage.sol";
import "../../utils/Imputation_utils.sol";
import "./r_BW_user.sol";
import "../walletbase/BaseWalletlogic.sol";

abstract contract w_BW_user is ImS_storage,r_BW_user{
    function clone(address treasury,bytes32 path) public returns (address instance) {
        address implementation=address(Proxycontract);
        bytes32 salt = keccak256(abi.encodePacked(treasury,path));
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37,salt)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    function set_Indiv_impl(address _impl)public{
        Indiv_logic[msg.sender]=_impl;
    }
    function imputationtoken(
        address treasury,bytes32[] memory  paths,IERC20 token
    )public {
        if (address(token)==address(0)) {
            imputationeth(treasury,paths);
        } else {
            unchecked{
                for (uint256 i; i<paths.length; i++) {
                    address n_add = getwalletadd(treasury,paths[i]);
                    if(!isContract(n_add)){
                        clone(treasury,paths[i]);
                    }
                    BaseWalletlogic(payable(n_add)).imputationtoken(token);
                }
                token.transfer(owner(),token.balanceOf(address(this))*systeminfo.totalfee);
                token.transfer(treasury,token.balanceOf(address(this)));
            }
        }
    }
    function imputationeth(address treasury,bytes32[] memory  paths
    )public {
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getwalletadd(treasury,paths[i]);
                if(!isContract(n_add)){
                    clone(treasury,paths[i]);
                }
                BaseWalletlogic(payable(n_add)).imputationeth();
            }
            payable(owner()).transfer(address(this).balance*systeminfo.totalfee);
            payable(treasury).transfer(address(this).balance);
        }
    }
    function imputationall(s_imputationinfo memory imputationinfo)
    public{
        s_tokentask[] memory tasks=imputationinfo.tokentasks;
        unchecked{
            for (uint256 i = 0; i < tasks.length; i++) {
                imputationtoken(imputationinfo.treasury,tasks[i].paths,IERC20(tasks[i].token));
            }
        }
    }
    function imputationall(
        bytes32[] calldata paths,
        address add,bytes calldata a,uint256 _gas,uint256 _value
    )public {
        address sender = msg.sender;
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getwalletadd(sender,paths[i]);
               if(!isContract(n_add)){
                    clone(sender,paths[i]);
                }
                BaseWalletlogic(payable(n_add)).all( add,  a, _gas, _value);
            }
        }
    }
    function _imputationtokenandswap(
        address treasury,
        bytes32[] calldata paths,
        IERC20 token
    ) private {
        uint256 gas_start = gasleft();
        if (address(token)==address(0)) {
            unchecked{
                for (uint256 i; i<paths.length; i++) {
                    address n_add = getwalletadd(treasury,paths[i]);
                    if(!isContract(n_add)){
                        clone(treasury,paths[i]);
                    }
                    BaseWalletlogic(payable(n_add)).imputationeth();
                }
                payable(treasury).transfer(address(this).balance*(1e18-systeminfo.totalfee)/1e18);
            }
        } else {
            unchecked{
                for (uint256 i; i<paths.length; i++) {
                    address n_add = getwalletadd(treasury,paths[i]);
                    if(!isContract(n_add)){
                        clone(treasury,paths[i]);
                    }
                    BaseWalletlogic(payable(n_add)).imputationtoken(token);
                }
                address[] memory path=new address[](2);
                path[0]=address(token);
                path[1]=systeminfo.router.WETH();
                systeminfo.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    token.balanceOf(address(this))*systeminfo.totalfee/1e18,
                    token.balanceOf(address(this))*systeminfo.totalfee/1e18*95/100,
                    path,
                    address(this),
                    99999999999
                );
                token.transfer(treasury,token.balanceOf(address(this)));
            }
        }
        uint256 spend=(gas_start-gasleft()+0x7000)*tx.gasprice;
        require(spend<=address(this).balance*systeminfo.checkfee/1e18,"not enough gasfee");
    }
    
    function imputationtokenandswap(
        address treasury,
        bytes32[] calldata paths,
        IERC20 token
    ) public {
        _imputationtokenandswap(treasury,paths,token);
        payable(treasury).transfer(address(this).balance);
    }
}