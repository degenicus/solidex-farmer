// SPDX-License-Identifier: MIT

import './abstract/ReaperBaseStrategy.sol';
import './interfaces/ILpDepositor.sol';
import './interfaces/IBaseV1Router01.sol';
import './interfaces/IBaseV1Pair.sol';
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

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
     * {lpToken0} - Token 0 of the LP want token
     * {lpToken1} - Token 1 of the LP want token
     */
    address public constant WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address public constant SOLIDLY = 0x888EF71766ca594DED1F0FA3AE64eD2941740A20;
    address public constant SOLIDEX = 0xD31Fcd1f7Ba190dBc75354046F6024A9b86014d7;
    address public want;
    address public lpToken0;
    address public lpToken1;

    /**
     * @dev Third Party Contracts:
     * {LP_DEPOSITOR} - Solidex contract for depositing LPs and claiming rewards
     * {SOLIDLY_ROUTER} - Solidly router for swapping tokens
     */
    address public constant LP_DEPOSITOR = 0x26E1A0d851CF28E697870e1b7F053B605C8b060F;
    address public constant SOLIDLY_ROUTER = 0xa38cd27185a464914D3046f0AB9d43356B34829D;

    /**
     * @dev Routes we take to swap tokens
     * {solidlyToWftmRoute} - Route we take to get from {SOLIDLY} into {WFTM}.
     * {solidexToWftmRoute} - Route we take to get from {SOLIDEX} into {WFTM}.
     * {wftmToWantRoute} - Route we take to get from {WFTM} into {want}.
     * {wftmToLp0Route} - Route we take to get from {WFTM} into {lpToken0}.
     * {wftmToLp1Route} - Route we take to get from {WFTM} into {lpToken1}.
     */
    address[] public solidlyToWftmRoute;
    address[] public solidexToWftmRoute;
    address[] public wftmToWantRoute;
    address[] public wftmToLp0Route;
    address[] public wftmToLp1Route;

    /**
     * @dev Strategy variables
     * {isStable} - If the LP are stables (uses different swap)
    */
    bool public isStable;

    /**
     * @dev Initializes the strategy. Sets parameters, saves routes, and gives allowances.
     * @notice see documentation for each variable above its respective declaration.
     */
    function initialize(
        address _vault,
        address[] memory _feeRemitters,
        address[] memory _strategists,
        address _want,
        bool _isStable
    ) public initializer {
        __ReaperBaseStrategy_init(_vault, _feeRemitters, _strategists);
        want = _want;
        solidlyToWftmRoute = [SOLIDLY, WFTM];
        solidexToWftmRoute = [SOLIDEX, WFTM];
        
        (lpToken0, lpToken1) = IBaseV1Pair(want).tokens();

        wftmToLp0Route = [WFTM, lpToken0];
        wftmToLp1Route = [WFTM, lpToken1];

        isStable = _isStable;

        _giveAllowances();
    }

    /**
     * @dev Withdraws funds and sents them back to the vault.
     * It withdraws {want} from the Solidly LP Depositor
     * The available {want} minus fees is returned to the vault.
     */
    function withdraw(uint _withdrawAmount) external {
        require(msg.sender == vault, "!vault");

        uint wantBalance = IERC20Upgradeable(want).balanceOf(address(this));

        if (wantBalance < _withdrawAmount) {
            ILpDepositor(LP_DEPOSITOR).withdraw(want, _withdrawAmount - wantBalance);
            wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        }

        if (wantBalance > _withdrawAmount) {
            wantBalance = _withdrawAmount;
        }

        uint withdrawFee = _withdrawAmount * securityFee / PERCENT_DIVISOR;
        IERC20Upgradeable(want).safeTransfer(vault, wantBalance - withdrawFee);
    }

    /**
     * @dev Returns the approx amount of profit from harvesting.
     *      Profit is denominated in WFTM, and takes fees into account.
     */
    function estimateHarvest() external view override returns (uint profit, uint callFeeToUser) {
        address[] memory pools = new address[](1);
        pools[0] = want;
        ILpDepositor.Amounts[] memory pendingRewards = ILpDepositor(LP_DEPOSITOR).pendingRewards(address(this), pools);
        ILpDepositor.Amounts memory pending = pendingRewards[0];

        IBaseV1Router01.route[] memory solidlyRoutes = _getRoutes(SOLIDLY, WFTM);
        uint solidlyWftmAmount = IBaseV1Router01(SOLIDLY_ROUTER).getAmountsOut(pending.solid, solidlyRoutes)[0];

        IBaseV1Router01.route[] memory solidexRoutes = _getRoutes(SOLIDEX, WFTM);
        uint solidexWftmAmount = IBaseV1Router01(SOLIDLY_ROUTER).getAmountsOut(pending.solid, solidexRoutes)[0];

        profit = solidlyWftmAmount + solidexWftmAmount;
        uint wftmFee = (profit * totalFee) / PERCENT_DIVISOR;
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
        _harvestCore();
        uint poolBalance = balanceOfPool();
        if (poolBalance != 0) {
            ILpDepositor(LP_DEPOSITOR).withdraw(want, poolBalance);
        }
        uint wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        IERC20Upgradeable(want).safeTransfer(vault, wantBalance);
    }

    /**
     * @dev Pauses supplied. Withdraws all funds from the LP Depositor, leaving rewards behind.
     */
    function panic() external {
        _onlyStrategistOrOwner();
        ILpDepositor(LP_DEPOSITOR).withdraw(want, balanceOfPool());
        uint wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        IERC20Upgradeable(want).safeTransfer(vault, wantBalance);
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
        uint wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        if (wantBalance != 0) {
            ILpDepositor(LP_DEPOSITOR).deposit(want, wantBalance);
        }
    }

    /**
     * @dev Calculates the total amount of {want} held by the strategy
     * which is the balance of want + the total amount supplied to Solidex.
     */
    function balanceOf() public view override returns (uint) {
        return balanceOfWant() + balanceOfPool();
    }

    /**
     * @dev Calculates the total amount of {want} held in the Solidex LP Depositor
     */
    function balanceOfPool() public view returns (uint) {
        uint poolBalance = ILpDepositor(LP_DEPOSITOR).userBalances(address(this), want);
        return ILpDepositor(LP_DEPOSITOR).userBalances(address(this), want);
    }

    /**
     * @dev Calculates the balance of want held directly by the strategy
     */
    function balanceOfWant() public view returns (uint) {
        uint wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
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
        uint solidlyBalance = IERC20Upgradeable(SOLIDLY).balanceOf(address(this));
        _swapTokens(SOLIDLY, WFTM, solidlyBalance);
        uint solidexBalance = IERC20Upgradeable(SOLIDEX).balanceOf(address(this));
        _swapTokens(SOLIDEX, WFTM, solidexBalance);
    }

    function _swapTokens(address _from, address _to, uint _amount) internal {
        if (_amount != 0) {
            IBaseV1Router01.route[] memory routes = _getRoutes(_from, _to);
            IBaseV1Router01(SOLIDLY_ROUTER).swapExactTokensForTokens(_amount, 0, routes, address(this), block.timestamp);
        }
    }

    function _getRoutes(address _from, address _to) internal view returns(IBaseV1Router01.route[] memory) {
        IBaseV1Router01.route memory route = IBaseV1Router01.route({
            from: _from, 
            to: _to,
            stable: isStable
        });
        IBaseV1Router01.route[] memory routes = new IBaseV1Router01.route[](1);
        routes[0] = route;
        return routes;
    }

    /**
     * @dev Core harvest function.
     * Charges fees based on the amount of WFTM gained from reward
     */
    function _chargeFees() internal {
        uint wftmFee = (IERC20Upgradeable(WFTM).balanceOf(address(this)) * totalFee) / PERCENT_DIVISOR;
        if (wftmFee != 0) {
            uint callFeeToUser = (wftmFee * callFee) / PERCENT_DIVISOR;
            uint treasuryFeeToVault = (wftmFee * treasuryFee) / PERCENT_DIVISOR;
            uint feeToStrategist = (treasuryFeeToVault * strategistFee) / PERCENT_DIVISOR;
            treasuryFeeToVault -= feeToStrategist;

            IERC20Upgradeable(WFTM).safeTransfer(msg.sender, callFeeToUser);
            IERC20Upgradeable(WFTM).safeTransfer(treasury, treasuryFeeToVault);
            IERC20Upgradeable(WFTM).safeTransfer(strategistRemitter, feeToStrategist);
        }
    }

    /** @dev Converts WFTM to both sides of the LP token and builds the liquidity pair */
    function _addLiquidity() internal {
        uint wrappedHalf = IERC20Upgradeable(WFTM).balanceOf(address(this)) / 2;
        if (wrappedHalf == 0) {
            return;
        }

        if (lpToken0 != WFTM) {
            _swapTokens(wftmToLp0Route[0], wftmToLp0Route[1], wrappedHalf);
        }
        if (lpToken1 != WFTM) {
            _swapTokens(wftmToLp1Route[0], wftmToLp1Route[1], wrappedHalf);
        }

        uint lp0Bal = IERC20Upgradeable(lpToken0).balanceOf(address(this));
        uint lp1Bal = IERC20Upgradeable(lpToken1).balanceOf(address(this));

        IBaseV1Router01(SOLIDLY_ROUTER).addLiquidity(lpToken0, lpToken1, false, lp0Bal, lp1Bal, 0, 0, address(this), block.timestamp);
    }

    /**
     * @dev Gives the necessary allowances
     */
    function _giveAllowances() internal {
        uint wantAllowance = type(uint).max - IERC20Upgradeable(want).allowance(address(this), LP_DEPOSITOR);
        IERC20Upgradeable(want).safeIncreaseAllowance(
            LP_DEPOSITOR,
            wantAllowance
        );
        uint solidlyAllowance = type(uint).max - IERC20Upgradeable(SOLIDLY).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(SOLIDLY).safeIncreaseAllowance(
            SOLIDLY_ROUTER,
            solidlyAllowance
        );
        uint solidexAllowance = type(uint).max - IERC20Upgradeable(SOLIDEX).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(SOLIDEX).safeIncreaseAllowance(
            SOLIDLY_ROUTER,
            solidexAllowance
        );
        uint wftmAllowance = type(uint).max - IERC20Upgradeable(WFTM).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(WFTM).safeIncreaseAllowance(
            SOLIDLY_ROUTER,
            wftmAllowance
        );
        uint lp0Allowance = type(uint).max - IERC20Upgradeable(lpToken0).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(lpToken0).safeIncreaseAllowance(
            SOLIDLY_ROUTER,
            lp0Allowance
        );
        uint lp1Allowance = type(uint).max - IERC20Upgradeable(lpToken1).allowance(address(this), SOLIDLY_ROUTER);
        IERC20Upgradeable(lpToken1).safeIncreaseAllowance(
            SOLIDLY_ROUTER,
            lp1Allowance
        );
    }

    /**
     * @dev Removes all allowance that were given
     */
    function _removeAllowances() internal {
        IERC20Upgradeable(want).safeDecreaseAllowance(LP_DEPOSITOR, IERC20Upgradeable(want).allowance(address(this), LP_DEPOSITOR));
        IERC20Upgradeable(SOLIDLY).safeDecreaseAllowance(LP_DEPOSITOR, IERC20Upgradeable(SOLIDLY).allowance(address(this), LP_DEPOSITOR));
        IERC20Upgradeable(SOLIDEX).safeDecreaseAllowance(LP_DEPOSITOR, IERC20Upgradeable(SOLIDEX).allowance(address(this), LP_DEPOSITOR));
        IERC20Upgradeable(WFTM).safeDecreaseAllowance(LP_DEPOSITOR, IERC20Upgradeable(WFTM).allowance(address(this), LP_DEPOSITOR));
        IERC20Upgradeable(lpToken0).safeDecreaseAllowance(SOLIDLY_ROUTER, IERC20Upgradeable(lpToken0).allowance(address(this), SOLIDLY_ROUTER));
        IERC20Upgradeable(lpToken1).safeDecreaseAllowance(SOLIDLY_ROUTER, IERC20Upgradeable(lpToken1).allowance(address(this), SOLIDLY_ROUTER));
    }
}
