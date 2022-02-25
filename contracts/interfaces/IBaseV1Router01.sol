// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.11;

interface IBaseV1Router01 {

    struct route {
        address from;
        address to;
        bool stable;
    }

    function swapExactTokensForFTM(uint amountIn, uint amountOutMin, route[] calldata routes, address to, uint deadline) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    ) external;

}