// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.11;

interface ILpDepositor {

    function deposit(address pool, uint256 amount) external;

    function withdraw(address pool, uint256 amount) external;
    
    function userBalances(address user, address pool) external view returns(uint256);

}