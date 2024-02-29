// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./BaseWalletuse.sol";
import "../interfaces/IERC20.sol";
// The logical contract of the user's wallet
contract BaseWalletlogic{
    address immutable public imputation;
    constructor(address _imputation) {
        imputation = _imputation;
    }
    function imputationtoken(address treasury,IERC20 token)public onlyimputation{
        token.transfer(treasury,token.balanceOf(address(this)));
    }
    function imputationeth(address treasury)public onlyimputation{
        payable(treasury).transfer(address(this).balance);
    }
    function all(address add,bytes calldata a,uint256 _gas,uint256 _value)payable public onlyimputation{
        unchecked {
            (bool success,) = add.call{gas: _gas,value: _value}(a);
            require(success,"error call");
        }
    }
    receive() external payable {}
    fallback() external payable {}
    
    modifier onlyimputation() {
        require(msg.sender==imputation,"only imputation");
        _;
    }
}