// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "../ImS_storage.sol";
import "../../utils/Imputation_utils.sol";
import "./s_BW_user.sol";
contract r_BW_user is Imputation_utils,ImS_storage,s_BW_user{
    function getwalletadd(address treasury,bytes32 path)public view returns(address walletadd){
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
    // 按国库=》子账号=》查询全币种余额
    function get_total_balances(
        address treasury,bytes32[] calldata paths,address[] calldata token
    )public view returns(
        s_tokeninfo[] memory treasuryinfos,//国库地址相关信息
        s_tokeninfo[] memory tokeninfos,//token的信息
        s_subinfo[] memory subinfos,//全子账号各token余额
        s_imputationinfo memory imputationinfo//归集使用的入参
    ){
        unchecked {
            imputationinfo.treasury=treasury;
            imputationinfo.tokentasks=new s_tokentask[](token.length);
            tokeninfos=new s_tokeninfo[](token.length);
            treasuryinfos=new s_tokeninfo[](token.length);
            for (uint256 i = 0; i < token.length; i++) {
                string memory symbol="eth";
                uint256 decimals=18;
                uint256 balances=treasury.balance;
                if (token[i]!=address(0)) {
                    symbol=IERC20(token[i]).symbol();
                    decimals=IERC20(token[i]).decimals();
                    balances=IERC20(token[i]).balanceOf(treasury);
                }
                tokeninfos[i]=s_tokeninfo(
                    token[i],
                    symbol,
                    decimals,
                    0,
                    0
                );
                treasuryinfos[i]=s_tokeninfo(
                    token[i],
                    symbol,
                    decimals,
                    balances,
                    0
                );
                imputationinfo.tokentasks[i].token=token[i];
            }
            subinfos=new s_subinfo[](paths.length);
            for (uint256 i = 0; i < paths.length; i++) {
                subinfos[i].tokensinfo=new s_tokeninfo[](token.length);
                for (uint256 j = 0; j < token.length; j++) {
                    s_accountinfo memory accountinfo=gettokenbalance(treasury,paths[i],token[j]);
                    subinfos[i].path=paths[i];
                    subinfos[i].account=accountinfo.account;
                    subinfos[i].tokensinfo[j]=s_tokeninfo(
                        tokeninfos[j].token,
                        tokeninfos[j].name,
                        tokeninfos[j].decimals,
                        accountinfo.balance,
                        0
                    );
                    if (accountinfo.balance!=0) {
                        tokeninfos[j].total+=accountinfo.balance;
                        tokeninfos[j].number++;
                    }
                }
            }
            for (uint256 i = 0; i < token.length; i++) {
                imputationinfo.tokentasks[i].paths=new bytes32[](tokeninfos[i].number);
            }
            for (uint256 j = 0; j < subinfos.length; j++) {
                for (uint256 k = 0; k < subinfos[j].tokensinfo.length; k++) {
                    if (subinfos[j].tokensinfo[k].total!=0) {
                        imputationinfo.tokentasks[k].paths[
                            (--tokeninfos[k].number)
                        ]=subinfos[j].path;
                    }
                }
            }
        }
    }
    // 按国库=》币种=》子账号余额
    function gettokensbalances(
        address treasury,s_getbalanceinput[] calldata getbalanceinputs
    )public view returns(
        s_token_accountinfo[] memory token_accountinfos
    ){
        token_accountinfos=new s_token_accountinfo[](getbalanceinputs.length);
        for (uint256 i = 0; i < getbalanceinputs.length; i++) {
            s_getbalanceinput memory n_getbalanceinput=getbalanceinputs[i];
            token_accountinfos[i]=gettokenbalances(treasury,n_getbalanceinput);
        }
    }
    function gettokenbalances(address treasury,s_getbalanceinput memory getbalanceinput)public view returns(s_token_accountinfo memory token_accountinfo){
        address token =getbalanceinput.token;
        bytes32[] memory paths = getbalanceinput.paths;
        s_accountinfo[] memory accountinfos=new s_accountinfo[](getbalanceinput.paths.length);
        uint256 total;
        for (uint256 i = 0; i < paths.length; i++) {
            accountinfos[i]=gettokenbalance(treasury,paths[i],token);
            total+=accountinfos[i].balance;
        }
        token_accountinfo=s_token_accountinfo(
            accountinfos,total
        );
    }
    function gettokenbalance(address treasury,bytes32 path,address token)public view returns(s_accountinfo memory accountinfo){
        address sub_add = getwalletadd(treasury,path);
        uint256 balance;
        if (token==address(0)) {
            balance=sub_add.balance;
        } else {
            balance=IERC20(token).balanceOf(sub_add);
        }
        accountinfo=s_accountinfo(
            path,token,sub_add,balance
        );
    }
    function get_Indiv_impl()public view returns(address impl){
        if (Indiv_logic[temp_caller]!=address(0)) {
            return Indiv_logic[temp_caller];
        } else {
            return base_logic;
        }
    }
    
}