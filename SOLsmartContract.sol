// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

contract TokenSwap {
    // Hardcoded addresses for the Avalanche network
    address private constant ROUTER_ADDRESS = 0xbb00FF08d01D300023C629E8fFfFcb65A5a578cE;
    address private constant USDC_ADDRESS = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;
    address private constant TREASURY_WALLET = 0x01b9a3D2A5980138D06C79a58bE8b1918fE0cB3e;

    IUniswapRouter private immutable uniswapRouter = IUniswapRouter(ROUTER_ADDRESS);
    IERC20 private immutable usdc = IERC20(USDC_ADDRESS);

    uint256 private constant FEE_BASIS = 1000; // 0.1% fee

    function swapTokensForUSDC(address tokenIn, uint256 amountIn, uint256 amountOutMin) external {
        IERC20 token = IERC20(tokenIn);
        token.transferFrom(msg.sender, address(this), amountIn);
        token.approve(ROUTER_ADDRESS, amountIn);

        uint256 fee = amountIn / FEE_BASIS;
        uint256 amountInAdjusted = amountIn - fee;
        token.transfer(TREASURY_WALLET, fee);

        IUniswapRouter.ExactInputSingleParams memory params = IUniswapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: USDC_ADDRESS,
            fee: 500, // Assuming a fee tier of 0.05%
            recipient: 0x288c8f4970194fd5cc534735a1ff0060939aC60A,
            amountIn: amountInAdjusted,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        uint256 usdcBalanceBefore = usdc.balanceOf(address(this));
        uniswapRouter.exactInputSingle(params);
        uint256 usdcBalanceAfter = usdc.balanceOf(address(this));
        uint256 usdcAmountReceived = usdcBalanceAfter - usdcBalanceBefore;
        
        usdc.transfer(msg.sender, usdcAmountReceived);
    }
}

