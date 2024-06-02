import { ethers } from "ethers";

// Provider setup for Avalanche C-Chain
const providerURL = "https://api.avax.network/ext/bc/C/rpc";
const provider = new ethers.providers.StaticJsonRpcProvider(providerURL, {
  chainId: 43114,
  name: "avax",
});

// Your wallet setup
const privateKey =
  "211a03eec5a142dfad3d328f67c1fd69dc501630ff61f45b1ff46a7eae4964bd"; // Replace with your actual private key
const signer = new ethers.Wallet(privateKey, provider);

// Smart Contract setup
const contractAddress = "0xBe0186532A7Cec82B51B8E15bBa9f33120bCAedb";
const contractABI = [
  "function swapTokensForUSDC(address tokenIn, uint256 amountIn, uint256 amountOutMin) external",
];

// Contract instance
const tokenSwapContract = new ethers.Contract(
  contractAddress,
  contractABI,
  signer
);

// Address of the token you want to swap (example: WAVAX)
const tokenInAddress = "0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7";

async function swapTokens(amountIn, amountOutMin) {
  try {
    const swapTx = await tokenSwapContract.swapTokensForUSDC(
      tokenInAddress,
      amountIn,
      amountOutMin
    );
    const swapReceipt = await swapTx.wait();
    console.log(
      "Swap executed with transaction hash:",
      swapReceipt.transactionHash
    );
  } catch (error) {
    console.error("Error during the token swap:", error);
  }
}

async function main() {
  const amountIn = ethers.utils.parseUnits("0.1", 18); // Amount of the tokenIn you want to swap
  const amountOutMin = ethers.utils.parseUnits("0", 6); // Minimum amount of USDC you want to receive
  await swapTokens(amountIn, amountOutMin);
}

main().catch(console.error);
