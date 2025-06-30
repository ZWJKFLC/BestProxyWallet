// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./Proxy.sol";
import "../interfaces/ISimple_Imputations.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "hardhat/console.sol";
// Variant proxy contract, which allows the smallest proxy contract to use this proxy contract to call the logical contract
contract  IsWalletProxy is Proxy{
    address immutable public imputations;
    address  immutable public thisaddress=address(this);
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    constructor(address _imputations) payable {
        imputations = _imputations;
    }
    function _implementation() internal view virtual override returns (address impl) {
        return ISimple_Imputations(imputations).get_Indiv_impl();
        // return IsWalletProxy(payable(thisaddress)).implementation();
        // return ERC1967Upgrade._getImplementation();
    }
    function implementation() public view returns (address impl) {
        // return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
        return _implementation();
    }
}