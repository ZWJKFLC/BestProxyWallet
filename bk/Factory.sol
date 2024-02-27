// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface IERC20{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}
contract Factory {
    address immutable public owner;
    ContractProxy public Proxycontract;
    constructor(address treasury){
        owner=treasury;
        Proxycontract=new ContractProxy(address(new Contractlogic(treasury)));
    }
    function getContractadd(uint256 path)public view returns(address Contractadd){
        unchecked{
            bytes32 salt = keccak256(abi.encodePacked(path));
            bytes memory creationCode="0x3d602d80600a3d3981f3363d3d373d3d3d363d733c563092e25d7b597d97fccf3cc25f5387104a7b5af43d82803e903d91602b57fd5bf3000000000000000000";
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
    function clone(uint256 path) public returns (address instance) {
        address implementation=address(Proxycontract);
        bytes32 salt = keccak256(abi.encodePacked(path));
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37,salt)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    function showcode(uint256 paths)public view returns(bytes memory){
        address n_add = getContractadd(paths);
        return n_add.code;
    }
    function showcodehash(uint256 paths)public view returns(bytes32){
        address n_add = getContractadd(paths);
        return keccak256(n_add.code);
    }
    function showflag(uint256 paths)public view returns(bool){
        address n_add = getContractadd(paths);
        return keccak256(n_add.code) == keccak256(bytes(""));
    }
    function showflag2(uint256 paths)public view returns(bool){
        address n_add = getContractadd(paths);
        return n_add.codehash == 0;
    }
    function imputationeth(uint256[] calldata paths)public {
        unchecked{
            for (uint256 i; i<paths.length; i++) {
                address n_add = getContractadd(paths[i]);
                // while(keccak256(n_add.code) == keccak256(bytes(""))){
                if(n_add.codehash == 0){
                    clone(paths[i]);
                }
                // Contractlogic(payable(n_add)).imputationeth();
                (bool success,) = n_add.call(
                    abi.encodeWithSignature("imputationeth()")
                );
                require(success,"error call");
            }
        }
    }
    function sendeth(uint256 path)public payable {
        address n_add = getContractadd(path);
        (bool success,) = n_add.call{value: msg.value}(abi.encode());
        require(success,"error call");
    }
}
contract Contractlogic{
    address immutable public treasury;
    constructor(address _treasury) {
        treasury=_treasury;
    }
    function imputationtoken(IERC20 token)public{
        token.transfer(treasury,token.balanceOf(address(this)));
    }
    function imputationeth()public{
        payable(treasury).transfer(address(this).balance);
    }
    function all(address add,bytes calldata a,uint256 _gas,uint256 _value)payable public {
        unchecked {
            (bool success,) = add.call{gas: _gas,value: _value}(a);
            require(success,"error call");
        }
    }
    receive() external payable {}
    fallback() external payable {}
}
contract  ContractProxy is Initializable, Proxy, ERC1967Upgrade,Ownable {
    address  immutable public thisaddress=address(this);
    constructor(address _logic) payable {
        _disableInitializers();
        _upgradeTo(_logic);
    }

    function _implementation() internal view virtual override returns (address impl) {
        return ContractProxy(payable(thisaddress)).implementation();
    }
    function implementation() public view returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
    function upgradeTo(address _logic)public onlyOwner {
        _upgradeTo(_logic);
    }
}