// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.11;

interface ILpDepositor {

    struct Amounts {
        uint256 solid;
        uint256 sex;
    }

    function deposit(address pool, uint256 amount) external;

    function withdraw(address pool, uint256 amount) external;

    function userBalances(address user, address pool) external view returns(uint256);

    function getReward(address[] calldata pools) external;

    function pendingRewards(
        address account,
        address[] calldata pools
    )
        external
        view
        returns (Amounts[] memory pending);

}