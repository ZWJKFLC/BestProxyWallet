// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
interface IERC20{
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}