// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

interface IImputations{
    function owner() external view returns (address);
    function get_Indiv_impl() external view returns (address);

}