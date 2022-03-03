// SPDX-License-Identifier: MIT

import './abstract/ReaperBaseStrategy.sol';
import './interfaces/ILpDepositor.sol';
import './interfaces/IBaseV1Router01.sol';
import './interfaces/IBaseV1Pair.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IBooMirrorWorld.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

pragma solidity 0.8.11;

/**
 * @dev This strategy will farm LPs on Solidex and autocompound rewards
 */
contract ReaperAutoCompoundSolidexFarmer is ReaperBaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @dev Tokens Used:
     * {WFTM} - Required for liquidity routing when doing swaps. Also used to charge fees on yield.
     * {SOLIDLY} - One of the reward tokens
     * {SOLIDEX} - One of the reward tokens
     * {want} - The vault token the strategy is maximizing
     * {boo} - Token 0 of the LP want token
     * {lpToken1} - Token 1 of the LP want token
     */
    address public constant WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address public constant SOLIDLY = 0x888EF71766ca594DED1F0FA3AE64eD2941740A20;
    address public constant SOLIDEX = 0xD31Fcd1f7Ba190dBc75354046F6024A9b86014d7;
    address public want;
    address public boo = 0x841FAD6EAe12c286d1Fd18d1d525DFfA75C7EFFE;
    address public xBoo = 0xa48d959AE2E88f1dAA7D5F611E01908106dE7598;

    /**
     * @dev Third Party Contracts:
     * {LP_DEPOSITOR} - Solidex contract for depositing LPs and claiming rewards
     * {SOLIDLY_ROUTER} - Solidly router for swapping tokens
     * {SPOOKY_ROUTER} - Spooky router for swapping tokens
     */
    address public constant LP_DEPOSITOR = 0x26E1A0d851CF28E697870e1b7F053B605C8b060F;
    address public constant SOLIDLY_ROUTER = 0xa38cd27185a464914D3046f0AB9d43356B34829D;
    address public constant SPOOKY_ROUTER = 0xF491e7B69E4244ad4002BC14e878a34207E38c29;

    /**
     * @dev Helpers
     * {lpTokenToRouter} - get the router to use to swap wftm to lpToken
     *                  False: Swap half for boo,
     *                          other half for lpToken1
     *                  True: Swap all for one lpToken,
     *                          then swap half of this lpToken for the other
     * {swapPath} - Path to use for current swap
     */
    mapping(address => address) lpTokenToRouter;
    address[] public swapPath;

    /**
     * @dev Initializes the strategy. Sets parameters, saves routes, and gives allowances.
     * @notice see documentation for each variable above its respective declaration.
     */
    function initialize(
        address _vault,
        address[] memory _feeRemitters,
        address[] memory _strategists,
        address _want
    ) public initializer {
        __ReaperBaseStrategy_init(_vault, _feeRemitters, _strategists);
        want = _want;
        (address lpToken0, address lpToken1) = IBaseV1Pair(want).tokens();
        require(lpToken0 == boo && lpToken1 == xBoo, "Wrong pair");
        lpTokenToRouter[boo] = SPOOKY_ROUTER;
        _giveAllowances();
    }

    function setLpTokenToRouter(address _lpToken, address _router) external {
        _onlyStrategistOrOwner();
        require(_router == SPOOKY_ROUTER || _router == SOLIDLY_ROUTER, "unknown router");
        lpTokenToRouter[_lpToken] = _router;
    }

    /**
     * @dev Withdraws funds and sents them back to the vault.
     * It withdraws {want} from the Solidly LP Depositor
     * The available {want} minus fees is returned to the vault.
     */
    function withdraw(uint256 _withdrawAmount) external {
        require(msg.sender == vault, '!vault');

        uint256 wantBalance = IERC20Upgradeable(want).balanceOf(address(this));

        if (wantBalance < _withdrawAmount) {
            ILpDepositor(LP_DEPOSITOR).withdraw(want, _withdrawAmount - wantBalance);
            wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        }

        if (wantBalance > _withdrawAmount) {
            wantBalance = _withdrawAmount;
        }

        uint256 withdrawFee = (_withdrawAmount * securityFee) / PERCENT_DIVISOR;
        IERC20Upgradeable(want).safeTransfer(vault, wantBalance - withdrawFee);
    }

    /**
     * @dev Returns the approx amount of profit from harvesting.
     *      Profit is denominated in WFTM, and takes fees into account.
     */
    function estimateHarvest() external view override returns (uint256 profit, uint256 callFeeToUser) {
        address[] memory pools = new address[](1);
        pools[0] = want;
        ILpDepositor.Amounts[] memory pendingRewards = ILpDepositor(LP_DEPOSITOR).pendingRewards(address(this), pools);
        ILpDepositor.Amounts memory pending = pendingRewards[0];

        IBaseV1Router01 router = IBaseV1Router01(SOLIDLY_ROUTER);
        (uint256 fromSolid, ) = router.getAmountOut(pending.solid, SOLIDLY, WFTM);
        profit += fromSolid;

        (uint256 fromSex, ) = router.getAmountOut(pending.sex, SOLIDEX, WFTM);
        profit += fromSex;

        uint256 wftmFee = (profit * totalFee) / PERCENT_DIVISOR;
        callFeeToUser = (wftmFee * callFee) / PERCENT_DIVISOR;
        profit -= wftmFee;
    }

    /**
     * @dev Function to retire the strategy. Claims all rewards and withdraws
     *      all principal from external contracts, and sends everything back to
     *      the vault. Can only be called by strategist or owner.
     *
     * Note: this is not an emergency withdraw function. For that, see panic().
     */
    function retireStrat() external {
        _onlyStrategistOrOwner();

        _claimRewards();
        _swapRewardsToWftm();
        _addLiquidity();

        uint256 poolBalance = balanceOfPool();
        if (poolBalance != 0) {
            ILpDepositor(LP_DEPOSITOR).withdraw(want, poolBalance);
        }
        uint256 wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        IERC20Upgradeable(want).safeTransfer(vault, wantBalance);
    }

    /**
     * @dev Pauses supplied. Withdraws all funds from the LP Depositor, leaving rewards behind.
     */
    function panic() external {
        _onlyStrategistOrOwner();
        ILpDepositor(LP_DEPOSITOR).withdraw(want, balanceOfPool());
        pause();
    }

    /**
     * @dev Unpauses the strat.
     */
    function unpause() external {
        _onlyStrategistOrOwner();
        _unpause();
        _giveAllowances();
        deposit();
    }

    /**
     * @dev Pauses the strat.
     */
    function pause() public {
        _onlyStrategistOrOwner();
        _pause();
        _removeAllowances();
    }

    /**
     * @dev Function that puts the funds to work.
     * It gets called whenever someone supplied in the strategy's vault contract.
     * It supplies {want} to farm {SOLIDLY} and {SOLIDEX}
     */
    function deposit() public whenNotPaused {
        uint256 wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        if (wantBalance != 0) {
            ILpDepositor(LP_DEPOSITOR).deposit(want, wantBalance);
        }
    }

    /**
     * @dev Calculates the total amount of {want} held by the strategy
     * which is the balance of want + the total amount supplied to Solidex.
     */
    function balanceOf() public view override returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    /**
     * @dev Calculates the total amount of {want} held in the Solidex LP Depositor
     */
    function balanceOfPool() public view returns (uint256) {
        return ILpDepositor(LP_DEPOSITOR).userBalances(address(this), want);
    }

    /**
     * @dev Calculates the balance of want held directly by the strategy
     */
    function balanceOfWant() public view returns (uint256) {
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    /**
     * @dev Core function of the strat, in charge of collecting and re-investing rewards.
     * 1. Claims {SOLIDLY} and {SOLIDEX} from the MasterChef.
     * 2. Swaps rewards to {WFTM}.
     * 3. Claims fees for the harvest caller and treasury.
     * 4. Swaps the {WFTM} token for {want}
     * 5. Deposits.
     */
    function _harvestCore() internal override {
        _claimRewards();
        _swapRewardsToWftm();
        _chargeFees();
        _addLiquidity();
        deposit();
    }

    /**
     * @dev Core harvest function.
     * Get rewards from the MasterChef
     */
    function _claimRewards() internal {
        address[] memory pools = new address[](1);
        pools[0] = want;
        ILpDepositor(LP_DEPOSITOR).getReward(pools);
    }

    /**
     * @dev Core harvest function.
     * Swaps {SOLIDLY} and {SOLIDEX} to {WFTM}
     */
    function _swapRewardsToWftm() internal {
        uint256 solidlyBalance = IERC20Upgradeable(SOLIDLY).balanceOf(address(this));
        _swapTokens(SOLIDLY, WFTM, solidlyBalance, SOLIDLY_ROUTER);
        uint256 solidexBalance = IERC20Upgradeable(SOLIDEX).balanceOf(address(this));
        _swapTokens(SOLIDEX, WFTM, solidexBalance, SOLIDLY_ROUTER);
    }

    function _swapTokens(
        address _from,
        address _to,
        uint256 _amount,
        address routerAddress
    ) internal {
        if (_amount != 0) {
            if (routerAddress == SOLIDLY_ROUTER) {
                IBaseV1Router01 router = IBaseV1Router01(routerAddress);
                (, bool stable) = router.getAmountOut(_amount, _from, _to);
                router.swapExactTokensForTokensSimple(_amount, 0, _from, _to, stable, address(this), block.timestamp);
            } else {
                IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
                swapPath = [_from, _to];
                router.swapExactTokensForTokens(_amount, 0, swapPath, address(this), block.timestamp);
            }
        }
    }

    /**
     * @dev Core harvest function.
     * Charges fees based on the amount of WFTM gained from reward
     */
    function _chargeFees() internal {
        uint256 wftmFee = (IERC20Upgradeable(WFTM).balanceOf(address(this)) * totalFee) / PERCENT_DIVISOR;
        if (wftmFee != 0) {
            uint256 callFeeToUser = (wftmFee * callFee) / PERCENT_DIVISOR;
            uint256 treasuryFeeToVault = (wftmFee * treasuryFee) / PERCENT_DIVISOR;
            uint256 feeToStrategist = (treasuryFeeToVault * strategistFee) / PERCENT_DIVISOR;
            treasuryFeeToVault -= feeToStrategist;

            IERC20Upgradeable(WFTM).safeTransfer(msg.sender, callFeeToUser);
            IERC20Upgradeable(WFTM).safeTransfer(treasury, treasuryFeeToVault);
            IERC20Upgradeable(WFTM).safeTransfer(strategistRemitter, feeToStrategist);
        }
    }

    /** @dev Converts WFTM to both sides of the LP token and builds the liquidity pair */
    function _addLiquidity() internal {

        uint256 wrappedBal = IERC20Upgradeable(WFTM).balanceOf(address(this));
        if(wrappedBal == 0) {
            return;
        }

        _swapTokens(WFTM, boo, wrappedBal, lpTokenToRouter[boo]);

        uint256 booHalf = IERC20Upgradeable(boo).balanceOf(address(this)) / 2;

        IBooMirrorWorld(xBoo).enter(booHalf);


        uint256 lp0Bal = IERC20Upgradeable(boo).balanceOf(address(this));
        uint256 lp1Bal = IERC20Upgradeable(xBoo).balanceOf(address(this));

        IBaseV1Router01(SOLIDLY_ROUTER).addLiquidity(
            boo,
            xBoo,
            IBaseV1Pair(want).stable(),
            lp0Bal,
            lp1Bal,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Gives the necessary allowances
     */
    function _giveAllowances() internal {
        uint256 wantAllowance = type(uint256).max - IERC20Upgradeable(want).allowance(address(this), LP_DEPOSITOR);
        IERC20Upgradeable(want).safeIncreaseAllowance(LP_DEPOSITOR, wantAllowance);
        uint256 solidlyAllowance = type(uint256).max -
            IERC20Upgradeable(SOLIDLY).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(SOLIDLY).safeIncreaseAllowance(SOLIDLY_ROUTER, solidlyAllowance);
        uint256 solidexAllowance = type(uint256).max -
            IERC20Upgradeable(SOLIDEX).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(SOLIDEX).safeIncreaseAllowance(SOLIDLY_ROUTER, solidexAllowance);
        uint256 wftmAllowance = type(uint256).max - IERC20Upgradeable(WFTM).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(WFTM).safeIncreaseAllowance(SOLIDLY_ROUTER, wftmAllowance);
        IERC20Upgradeable(WFTM).safeIncreaseAllowance(SPOOKY_ROUTER, wftmAllowance);
        uint256 booAllowance = type(uint256).max - IERC20Upgradeable(boo).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(boo).safeIncreaseAllowance(SOLIDLY_ROUTER, booAllowance);
        IERC20Upgradeable(boo).safeIncreaseAllowance(xBoo, booAllowance);
        uint256 xBooAllowance = type(uint256).max - IERC20Upgradeable(xBoo).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(xBoo).safeIncreaseAllowance(SOLIDLY_ROUTER, xBooAllowance);
    }

    /**
     * @dev Removes all allowance that were given
     */
    function _removeAllowances() internal {
        IERC20Upgradeable(want).safeDecreaseAllowance(
            LP_DEPOSITOR,
            IERC20Upgradeable(want).allowance(address(this), LP_DEPOSITOR)
        );
        IERC20Upgradeable(SOLIDLY).safeDecreaseAllowance(
            SOLIDLY_ROUTER,
            IERC20Upgradeable(SOLIDLY).allowance(address(this), SOLIDLY_ROUTER)
        );
        IERC20Upgradeable(SOLIDEX).safeDecreaseAllowance(
            SOLIDLY_ROUTER,
            IERC20Upgradeable(SOLIDEX).allowance(address(this), SOLIDLY_ROUTER)
        );
        IERC20Upgradeable(WFTM).safeDecreaseAllowance(
            SOLIDLY_ROUTER,
            IERC20Upgradeable(WFTM).allowance(address(this), SOLIDLY_ROUTER)
        );
        IERC20Upgradeable(boo).safeDecreaseAllowance(
            SOLIDLY_ROUTER,
            IERC20Upgradeable(boo).allowance(address(this), SOLIDLY_ROUTER)
        );
        IERC20Upgradeable(boo).safeDecreaseAllowance(
            xBoo,
            IERC20Upgradeable(boo).allowance(address(this), SOLIDLY_ROUTER)
        );
        IERC20Upgradeable(xBoo).safeDecreaseAllowance(
            SOLIDLY_ROUTER,
            IERC20Upgradeable(xBoo).allowance(address(this), SOLIDLY_ROUTER)
        );
    }
}
