// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./SImS_storage.sol";
import "../interfaces/ISimple_Imputations.sol";
import "../interfaces/IERC20.sol";
import "./BaseWalletlogic.sol";
import "../utils/Imputation_utils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract BaseWalletuse is SImS_storage, ISimple_Imputations,Imputation_utils,Ownable{
    constructor(address initialOwner){
        transferOwnership(initialOwner);
    }
    function getethbalance(address treasury,uint256 path)public view returns(uint256 balance){
        address sub_add = getwalletadd(treasury,path);
        return sub_add.balance;
    }
    function gettokenbalance(address treasury,uint256 path,IERC20 token)public view returns(uint256 balance){
        address sub_add = getwalletadd(treasury,path);
        return token.balanceOf(sub_add);
    }
    function getwalletadd(address treasury,uint256 path)public view returns(address walletadd){
        unchecked{
            bytes32 salt = keccak256(abi.encodePacked(treasury,path));
            bytes memory creationCode="";
            address implementation=address(Proxycontract);
            creationCode=abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                implementation,
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            );
            return address(uint160(uint(keccak256(abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    salt,
                    keccak256(creationCode)
                )))));
        }
    }
    function set_Indiv_impl(address _impl)public{
        Indiv_logic[msg.sender]=_impl;
    }
    function get_Indiv_impl()public view returns(address impl){
        if (Indiv_logic[temp_caller]!=address(0)) {
            return Indiv_logic[temp_caller];
        } else {
            return base_logic;
        }
    }
    function clone(address treasury,uint256 path) private returns (address instance) {
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
    function imputationtoken(address treasury,uint256[] calldata paths,IERC20 token)public {
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getwalletadd(treasury,paths[i]);
                if(!isContract(n_add)){
                    clone(treasury,paths[i]);
                }
                BaseWalletlogic(payable(n_add)).imputationtoken(token);
            }
            token.transfer(owner(),token.balanceOf(address(this))*3/1000);
            token.transfer(treasury,token.balanceOf(address(this)));
        }
    }
    function imputationeth(address treasury,uint256[] calldata paths)public {
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getwalletadd(treasury,paths[i]);
                if(!isContract(n_add)){
                    clone(treasury,paths[i]);
                }
                BaseWalletlogic(payable(n_add)).imputationeth();
            }
            payable(owner()).transfer(address(this).balance*3/1000);
            payable(treasury).transfer(address(this).balance);
        }
    }
    function imputationall(
        uint256[] calldata paths,
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
}