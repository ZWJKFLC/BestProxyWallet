// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "../../interfaces/Itotal.sol";

contract pi_transfer{
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