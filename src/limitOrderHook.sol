// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseHook} from "v4-periphery/BaseHook.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";

import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TickMath} from "v4-core/libraries/TickMath.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract TakeProfitsHook is BaseHook, ERC1155 {
	using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint256;

	// Errors
	error InvalidOrder();
	error NothingToClaim();
	error NotEnoughToClaim();

    //mapping to keep track of orders
    mapping(PoolId poolId => mapping(int24 tickToSellAt => mapping(bool zeroForOne => uint256 inputAmount))) public pendingOrders;
    mapping(uint256 positionId => uint256 claimsSupply) public claimTokensSupply;
	
	// Constructor
    constructor(
        IPoolManager _manager,
        string memory _uri
    ) BaseHook(_manager) ERC1155(_uri) {}

	// BaseHook Functions
    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: true,
                beforeAddLiquidity: false,
                afterAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false
            });
    }

	function afterInitialize(
        address,
        PoolKey calldata key,
        uint160,
        int24 tick,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
		// TODO
        return this.afterInitialize.selector;
    }

	function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
		// TODO
        return this.afterSwap.selector;
    }

    function getLowerUseableTick(int24 tick, int24 tickspacing) private pure returns (int24) {
        int24 intervals = tick / tickspacing;
        if(tick < 0 && tick % tickspacing != 0) {
            intervals --;
        }
        return intervals * tickspacing;
    }

    function getPositionID(PoolKey calldata key, int24 tick, bool zeroForOne) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(key.toId(), tick, zeroForOne))); //ERC 1155 TOKENID basically a mapping for pending orders
    }
}