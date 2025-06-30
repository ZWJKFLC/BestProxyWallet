// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "./SImS_storage.sol";
import "../interfaces/ISimple_Imputations.sol";
import "../interfaces/IERC20.sol";
import "./BaseWalletlogic.sol";
import "../utils/Imputation_utils.sol";
import "./ownerfun.sol";
contract BaseWalletuse is SImS_storage, ISimple_Imputations,Imputation_utils{

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
    function imputationeth(address treasury,bytes32[] memory  paths)public {
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
    struct task{
        bytes32 path;
        IERC20 token;
    }
    function imputationall(s_imputationinfo memory imputationinfo)public{
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
    
    function ownerfun_imputationtokenandswap(
        address treasury,
        bytes32[] calldata paths,
        IERC20 token
    ) public onlyOwner{
        _imputationtokenandswap(treasury,paths,token);
        payable(owner()).transfer(address(this).balance);
    }
    function getgasfee(
        address treasury,
        bytes32[] calldata paths,
        IERC20 token
    )  public view returns(uint256 gasfee) {
        uint256 totalbalance;
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getwalletadd(treasury,paths[i]);
                totalbalance += token.balanceOf(n_add);
            }
            address[] memory path=new address[](2);
            path[0]=address(token);
            path[1]=systeminfo.router.WETH();
            uint[] memory amounts=systeminfo.router.getAmountsOut(
                totalbalance*systeminfo.checkfee/1e18,
                path
            );
            return amounts[0];
        }
    }
}