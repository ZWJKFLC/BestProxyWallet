// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "../../interfaces/Itotal.sol";
abstract contract s_BW_user {
    struct s_tokentask{
        address token;
        bytes32[] paths;
    }
    struct s_imputationinfo{
        address treasury;
        s_tokentask[] tokentasks;
    }
    struct s_tokeninfo{
        address token;
        string name;
        uint256 decimals;
        uint256 total;
        uint256 number;
    }
    struct s_subinfo{
        bytes32 path;
        address account;
        s_tokeninfo[] tokensinfo;
    }
    
    struct s_getbalanceinput{
        address token;
        bytes32[] paths;
    }
    struct s_accountinfo{
        bytes32 path;
        address token;
        address account;
        uint256 balance;
    }
    struct s_token_accountinfo{
        s_accountinfo[] accountinfos;
        uint256 total;
    }
    struct task{
        bytes32 path;
        IERC20 token;
    }
}