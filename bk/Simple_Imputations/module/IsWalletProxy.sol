// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./Proxy.sol";
import "../interfaces/ISimple_Imputations.sol";
// Variant proxy contract, which allows the smallest proxy contract to use this proxy contract to call the logical contract
contract  IsWalletProxy is Proxy{
    address immutable public imputations;
    constructor(address _imputations) payable {
        imputations = _imputations;
    }
    function _implementation() internal view virtual override returns (address impl) {
        return ISimple_Imputations(imputations).get_Indiv_impl();
        // return ERC1967Upgrade._getImplementation();
    }
    function implementation() public view returns (address impl) {
        return _implementation();
    }
}