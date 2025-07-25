# Foundry Fund Me

You will learn:

-   How to push your project to GitHub
-   Write and run amazing tests
-   Advanced deploy scripts, used to deploy on different chains that require different addresses
-   How to use scripts to interact with contracts, so we can easily reproduce our actions
-   How to use a price feed
-   How to use Chisel
-   Smart contract automation
-   How to make our contracts more gas efficient
-   And many more interesting things!

## Setup

There are some advanced tools/standard naming conventions:

-   We use a named error `FundMe__NotOwner();`
-   We use all caps for constants
-   `i_` for immutable variables
-   `s_` for private variables

creating a Foundry project

```Solidity
forge init
// or
forge init --force
```

## Smart Contract testing

you can test your codes using:

```Solidity
forge test
```

### How does `forge test` work?

`forge test` has a lot of options that allow you to configure what is tested, how the results are displayed, where is the test conducted and many more!

Run `forge test --help` to explore the options. I suggest reading [`this page`](https://book.getfoundry.sh/forge/tests) and navigating deeper into the Foundry Book to discover how tests work.

But in short, in our specific case:

1. Forge identified all the files in the test folder, went into the only file available and ran the `setUp` function.
2. After the setup is performed it goes from top to bottom in search of public/external functions that start with `test`.
3. All of them will be called and the conclusion of their execution will be displayed. By that we mean it will run all the `assert` statements it can find and if all evaluate to `true` then the test will pass. If one of the `assert` statements evaluates to `false` the test will fail.

## Finish Setup

In `src` create two files, `FundMe.sol` and `PriceConverter.sol`.

Go on the [Remix Fund Me repo](https://github.com/MRAlirad/fund-me-remix) and copy the contents of both contracts.

Try running `forge compile` or `forge build`. A few errors will pop up. What's the problem?

If you open both the copied smart contracts you will see that up top we `import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";`. This wasn't a problem in Remix because Remix automatically takes care of this problem for you. In Foundry you have to manually install all your dependencies.

`forge install` is the command we are using to install one or multiple dependencies. [Go here](https://book.getfoundry.sh/reference/cli/forge/install?highlight=install#forge-install) to read more about this command.

Call the following:

```Solidity
forge install smartcontractkit/chainlink-brownie-contracts@1.3.0 --no-commit
```

We used `forge install` to ask Forge to install something in our project. What? We specified the path to a GitHub repository, this also could have been a raw URL. What version? Following the path to a GitHub repository you can add an `@` and then you can specify:

-   A branch: master
-   A tag: v1.2.3.4 or 0.6.1 in our case
-   A commit: 8e8128

We end the install command with `--no commit` in order to not create a git commit. More on this option later.

If we open the `lib` folder, we can see the `forge-std` which is installed automatically within the `forge init` setup and `chainlink-brownie-contracts` which we just installed. Look through the former, you'll see a folder called `contracts` then a folder called `src`. Here you can find different versions, and inside them, you can find a plethora of contracts, some of which we are going to use in this course. Here we can find the `AggregatorV3Interface` that we are importing in `FundMe.sol`.

But if you open the `FundMe.sol` you'll see that we are importing `{AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";` not from `/foundry-fund-me/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol`. How does Foundry know `@chainlink` to half of the path?

Open `foundry.toml`. Below the last line of `[profile.default]` paste the following:

```toml
remappings = ['@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/']
```

Now Forge knows to equivalate these. Let's try to compile now by calling `forge compile` or `forge build`.

## Testing Smart Contracts

Testing is a crucial step in your smart contract development journey, as the lack of tests can be a roadblock in the deployment stage or during a smart contract audit.

Inside the `test` folder create a file called `FundMeTest.t.sol`. `.t.` is a naming convention of Foundry.

The writing of a test contract shares the initial steps with the writing of a normal smart contract. We state the `SPDX-License-Identifier`, solidity version and a contract name:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract FundMeTest {

}
```

To be able to run tests using Foundry we need to import the set of smart contracts Foundry comes with that contains a lot of prebuilt functions that make our lives 10x easier.

```solidity
import { Test } from 'forge-std/Test.sol';
```

We also make sure our test contract inherits what we just imported.

```solidity
contract FundMeTest is Test{

}
```

The next logical step in our testing process is deploying the `FundMe` contract. In the future, we will learn how to import our deployment scripts, but for now, let's do the deployments right in our test file.

We do this inside the `setUp` function. This function is always the first to execute whenever we run our tests. Here we will perform all the prerequisite actions that are required before doing the actual testing, things like:

-   Deployments;
-   User addresses;
-   Balances;
-   Approvals;
-   And various other operations depending on what's required to initiate the tested contracts.

But before that, please create another function, called `testDemo`.

Your test contract should look like this:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

contract FundMeTest is Test {

    function setUp() external { }

    function testDemo() public { }

 }
```

Now run `forge test` in your terminal. This command has a lot of options, you can find more about those [here](https://book.getfoundry.sh/reference/cli/forge/test?highlight=forge%20test#forge-test).

Our (empty) test passed! Great!

Ok, but how does it work? What's the order of things?

Please update the contract to the following:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

contract FundMeTest is Test {

    uint256 favNumber = 0;
    bool greatCourse = false;

    function setUp() external {
        favNumber = 1337;
        greatCourse = true;
    }

    function testDemo() public {
        assertEq(favNumber, 1337);
        assertEq(greatCourse, true);
    }

 }
```

Call `forge test` again.

As you can see our test passed. What do we learn from this?

1. We declare some state variables.
2. Next up `setUp()` is called.
3. After that forge runs all the test functions.

Another nice way of testing this and also an important tool for debugging is `console.log`. The `console` library comes packed in the `Test.sol` that we imported, we just need to update the things we import to this:

```solidity
import { Test, console } from 'forge-std/Test.sol';
```

Let's insert some `console.log` calls inside our contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

contract FundMeTest is Test {

    uint256 favNumber = 0;
    bool greatCourse = false;

    function setUp() external {
        favNumber = 1337;
        greatCourse = true;
        console.log("This will get printed first!");
    }

    function testDemo() public {
        assertEq(favNumber, 1337);
        assertEq(greatCourse, true);
        console.log("This will get printed second!");
        console.log("Updraft is changing lives!");
        console.log("You can print multiple things, for example this is a uint256, followed by a bool:", favNumber, greatCourse);
    }
 }
```

`forge test` has an option called verbosity. By controlling this option we decide how verbose should the output of the `forge test` be. The default `forge test` has a verbosity of 1. Here are the verbosity levels, choose according to your needs:

```Solidity
    Verbosity levels:
    - 2: Print logs for all tests
    - 3: Print execution traces for failing tests
    - 4: Print execution traces for all tests, and setup traces for failing tests
    - 5: Print execution and setup traces for all tests
```

Given that we want to see the printed logs, we will call `forge test -vv` (the number of v's indicates the level).

```Solidity
Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testDemo() (gas: 9482)
Logs:
    This will get printed first!
    This will get printed second!
    Updraft is changing lives!
    You can print multiple things, for example this is a uint256, followed by a bool: 1337 true

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 422.20µs (63.30µs CPU time)
```

You can read more about `console.log` [here](https://book.getfoundry.sh/reference/forge-std/console-log?highlight=console.#console-logging).

Let's delete the logs for now, but keep the console import. We could use it later for debugging.

Let's deploy the `FundMe` contract.

For that, we will first need to import it into our test file, then declare it as a state variable and deploy it in the `setUp` function.

### Testing FundMe

Delete `testDemo`. Make a new function called `testMinimumDollarIsFive`. As the name states, we will test if the `MINIMUM_USD` is equal to `5e18`.

```solidity
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
```

Run it with `forge test`.

```Solidity
[⠰] Compiling...
[⠆] Compiling 1 files with 0.8.25
[⠰] Solc 0.8.25 finished in 827.51ms
Compiler run successful!

Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testMinimumDollarIsFive() (gas: 5453)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 487.20µs (43.20µs CPU time)

```

Great job! Let's delete the `favNumber` and `greatCourse` to keep our test file nice and clean.

Try to change the right side of the `assertEq` line to check what a failed test looks like.

## Debug Solidity Tests

Let's test if the owner (which should be us) is recorded properly.

```solidity
function testOwnerIsMsgSender() public {
    assertEq(fundMe.i_owner(), msg.sender);
}
```

Output:

```Solidity
Ran 2 tests for test/FundMe.t.sol:FundMeTest
[PASS] testMinimumDollarIsFive() (gas: 5453)
[FAIL. Reason: assertion failed] testOwnerIsMsgSender() (gas: 22521)
Suite result: FAILED. 1 passed; 1 failed; 0 skipped; finished in 3.85ms (623.00µs CPU time)

Ran 1 test suite in 367.24ms (3.85ms CPU time): 1 tests passed, 1 failed, 0 skipped (2 total tests)

Failing tests:
Encountered 1 failing test in test/FundMe.t.sol:FundMeTest
[FAIL. Reason: assertion failed] testOwnerIsMsgSender() (gas: 22521)
```

So ... why did it fail? Didn't we call the `new FundMe();` to deploy, making us the owner?

Let's add some `console.log`s to see more information about the two elements of the assertion.

```solidity
    function testOwnerIsMsgSender() public {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }
```

Let's run `forge test -vv`:

```Solidity
Ran 2 tests for test/FundMe.t.sol:FundMeTest
[PASS] testMinimumDollarIsFive() (gas: 5453)
[FAIL. Reason: assertion failed] testOwnerIsMsgSender() (gas: 26680)
Logs:
    0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
    0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
    Error: a == b not satisfied [address]
        Left: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        Right: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

Suite result: FAILED. 1 passed; 1 failed; 0 skipped; finished in 975.40µs (449.20µs CPU time)

Ran 1 test suite in 301.60ms (975.40µs CPU time): 1 tests passed, 1 failed, 0 skipped (2 total tests)

Failing tests:
Encountered 1 failing test in test/FundMe.t.sol:FundMeTest
[FAIL. Reason: assertion failed] testOwnerIsMsgSender() (gas: 26680)
```

Ok, so the addresses are different, but why?

Technically we are not the ones that deployed the `FundMe` contract. The `FundMe` contract was deployed by the `setUp` function, which is part of the `FundMeTest` contract. So, even though we are the ones who called `setUp` via `forge test`, the actual testing contract is the deployer of the `FundMe` contract.

To test the above let's tweak the `testOwnerIsMsgSender` function:

```solidity
    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));
    }
```

Run `forge test`. It passes!

## Advanced deploy scripts

When we went straight to testing, we left behind a very important element: deploy scripts. Why is this important you ask? Because we need a certain degree of flexibility that we can't obtain in any other way, let's look through the two files `FundMe.sol` and `PriceConverter.sol`, we can see that both have an address (`0x694AA1769357215DE4FAC081bf1f309aDC325306`) hardcoded for the AggregatorV3Interface. This address is valid, it matches the AggregatorV3 on Sepolia but what if we want to test on Anvil? What if we deploy on mainnet or Arbitrum? What then?

The deploy script is the key to overcome this problem!

Create a new file called `DeployFundMe.s.sol` in `script` folder. Please use the `.s.sol` naming convention.

We start with stating the SPDX and pragma:

```Solidity
//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
```

After that, we need the imports. We are working on a Foundry Script, thus the next logical step is to import `Script.sol`

```Solidity
import {Script} from "forge-std/Script.sol";
```

Another thing that we need for our deploy script to work is (drumroll) to import the contract we want to deploy.

```Solidity
import {FundMe} from "../src/FundMe.sol";
```

We are ready to define the contract. Remember how we did scripts a couple of lessons ago? Try to do it yourself.

```solidity
// SPDX-License_identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external{
        vm.startBroadcast();
        new FundMe();
        vm.stopBroadcast();
    }
}
```

Now let's try it with `forge script DeployFundMe`.

## Forking tests

This course will cover 4 different types of tests:

* **Unit tests**: Focus on isolating and testing individual smart contract functions or functionalities.
* **Integration tests**: Verify how a smart contract interacts with other contracts or external systems.
* **Forking tests**: Forking refers to creating a copy of a blockchain state at a specific point in time. This copy, called a fork, is then used to run tests in a simulated environment.
* **Staging tests**: Execute tests against a deployed smart contract on a staging environment before mainnet deployment.

Coming back to our contracts, the central functionality of our protocol is the `fund` function.

For that to work, we need to be sure that Aggregator V3 runs the current version. We know from previous courses that the version returned needs to be `4`. Let's put it to the test!

Add the following code to your test file:

```solidity
function testPriceFeedVersionIsAccurate() public {
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
}
```

It ... fails. But why? Looking through the code we see this AggregatorV3 address `0x694AA1769357215DE4FAC081bf1f309aDC325306` over and over again. The address is correct, is the Sepolia deployment of the AggregatorV3 contract. But our tests use Anvil for testing purposes, so that doesn't exist.

**Note: Calling** **`forge test`** **over and over again when you are testing is not always efficient, imagine you have tens or hundreds of tests, some of them taking seconds to finish. From now on, when we test specific things let's use the following:**

`forge test --mt testPriceFeedVersionIsAccurate`

Back to our problem, how can we fix this?

Forking is the solution we need. If we run the test on an anvil instance that copies the current Sepolia state, where AggregatorV3 exists at that address, then our test function will not revert anymore. For that, we need a Sepolia RPC URL.


Thus:

1. Create a .env file. (Also make sure that your `.gitignore` file contains the `.env` entry)
2. In the `.env` file create a new entry as follows:

```Solidity
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOURAPIKEYWILLGOHERE
```

1. Run `source .env` in your terminal;
2. Run `forge test --mt testPriceFeedVersionIsAccurate --fork-url $SEPOLIA_RPC_URL`
3. Run `forge test --fork-url $SEPOLIA_RPC_URL` : this will run all the tests

```Solidity
Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testPriceFeedVersionIsAccurate() (gas: 14118)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.29s (536.03ms CPU time)
```

Please keep in mind that forking uses the Alchemy API, it's not a good idea to run all your tests on a fork every single time. But, sometimes as in this case, you can't test without. It's very important that our test have a high **coverage**, to ensure all our code is battle tested.

### Coverage

Foundry provides a way to calculate the coverage. You can do that by calling `forge coverage`. This command displays which parts of your code are covered by tests. Read more about its options [here](https://book.getfoundry.sh/reference/forge/forge-coverage?highlight=coverage#forge-coverage).

```Solidity
forge coverage --fork-url $SEPOLIA_RPC_URL
```

```Solidity
Ran 3 tests for test/FundMe.t.sol:FundMeTest
[PASS] testMinimumDollarIsFive() (gas: 5759)
[PASS] testOwnerIsMsgSender() (gas: 8069)
[PASS] testPriceFeedVersionIsAccurate() (gas: 14539)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 1.91s (551.69ms CPU time)

Ran 1 test suite in 2.89s (1.91s CPU time): 3 tests passed, 0 failed, 0 skipped (3 total tests)
| File                      | % Lines       | % Statements  | % Branches    | % Funcs      |
| ------------------------- | ------------- | ------------- | ------------- | ------------ |
| script/DeployFundMe.s.sol | 0.00% (0/3)   | 0.00% (0/3)   | 100.00% (0/0) | 0.00% (0/1)  |
| src/FundMe.sol            | 21.43% (3/14) | 25.00% (5/20) | 0.00% (0/6)   | 33.33% (2/6) |
| src/PriceConverter.sol    | 0.00% (0/6)   | 0.00% (0/11)  | 100.00% (0/0) | 0.00% (0/2)  |
| Total                     | 13.04% (3/23) | 14.71% (5/34) | 0.00% (0/6)   | 22.22% (2/9) |
```

These are rookie numbers! Maybe 100% is not feasible, but 13% is as good as nothing.

## Refactoring code and test

The way our code is currently structured is not that flexible. Given the hardcoded Sepolia address we cannot deploy to other chains, and if we wish to do so we would have to come and copy-paste another address everywhere throughout the code. In bigger codebases, with multiple addresses / other items to copy-paste for each deployment (in case we deploy on multiple chains) this update activity is extremely prone to error. We can do better.

To fix this we can make our project more modular, which would help improve the maintainability, testing and deployment. This is done by moving the hardcoded changing variables to the constructor, thus regardless of the chain we deploy our contracts to, we provide the chain-specific elements once, in the constructor, and then we are good to go.

Changing code without changing its functionality bears the name of **refactoring**.

Do the following modifications in `FundMe.sol`

1. In the storage variables section create a new variable:

```solidity
AggregatorV3Interface private s_priceFeed;
```

1. We need to add this as an input in our constructor and assign it to the state variable. This is done as follows:

```solidity
constructor(address priceFeed){
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeed);
}
```

1. Inside the `getVersion` function, where AggregatorV3Interface is invoked, replace the hardcoded address with the state variable s\_priceFeed:

```solidity
function getVersion() public view returns (uint256){
    AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
    return priceFeed.version();
}
```

1. In `PriceConverter.sol` modify the `getPrice` function to take an input `function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {` and delete the `AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);` line;
2. In the same library update `getConversionRate` to take a `priceFeed` input and update the first line to pass the required AggregatorV3Interface to the `getPrice` function:

```solidity
function getConversionRate(
    uint256 ethAmount,
    AggregatorV3Interface priceFeed
) internal view returns (uint256) {
    uint256 ethPrice = getPrice(priceFeed);
    uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
    // the actual ETH/USD conversion rate, after adjusting the extra 0s.
    return ethAmountInUsd;
}
```

1. Back in `FundMe.sol` pass the s_priceFeed as input for `getConversionRate` in the `fund` function.

Take a moment and think if we missed updating anything in our project.

Ready? The deploy script is not providing the `priceFeed` as an input when calling `new FundMe();`, also, the `setUp` function in `FundMe.t.sol` is not providing the `priceFeed` as an input when calling `fundMe = new FundMe();`.

For now, let's hardcode the address `0x694AA1769357215DE4FAC081bf1f309aDC325306` in both places.

As you've figured out this isn't ideal either. Every time we want to do something from now on do we have to update in both places? Not good.

Update the `run` function from the `DeployFundMe` script:

```solidity
function run() external returns (FundMe) {
    vm.startBroadcast();
    FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    vm.stopBroadcast();
    return fundMe
}
```

Now when we call run it returns the `FundMe` contract we deployed.

In `FundMe.t.sol`:

1. Let's import the deployment script into the `FundMe.t.sol`.

```solidity
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
```

1. Create a new state variable `DeployFundMe deployFundMe;`;
2. Update the `setUp` function as follows:

```solidity
function setUp() external {
    deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
}
```

Let's call a `forge test --fork-url $SEPOLIA_RPC_URL` to make sure everything compiles.

Looks like the `testOwnerIsMsgSender` fails again. Take a moment and think about why.

When we changed the method of deployment and made it go through the run command of the deployFundMe contract we also changed the owner.

**Note**: `vm.startBroadcast` is special, it uses the address that calls the test contract or the address / private key provided as the sender. You can read more about it here.

To account for the way `vm.startBroadcast` works please perform the following modification in `FundMe.t.sol`:

```solidity
function testOwnerIsMsgSender() public {
    assertEq(fundMe.i_owner(), msg.sender);
}
```

Run `forge test --fork-url $SEPOLIA_RPC_URL` again.

## Deploy a mock priceFeed


It is very important to be able to run our all tests locally. We will do this using a **mock contract**.

Before we dive into the code, let's emphasize why this practice is so beneficial. By creating a local testing environment, you reduce your chances of breaking anything in the refactoring process, as you can test all changes before they go live. No more hardcoding of addresses and no more failures when you try to run a test without a forked chain. As a powerful yet simple tool, a mock contract allows you to simulate the behavior of a real contract without the need to interact with a live blockchain.

Thus, on our local Anvil blockchain we will deploy a contract that mimics the behavior of the Sepolia `priceFeed`.

### Where the magic happens

Please create a new file in your `script` folder called `HelperConfig.s.sol`. Here we'll write the logic necessary for our script to deploy mocks when it detects we are performing tests on our local anvil chain. Also, here we will keep track of all the contract addresses we will use across all the different chains we will interact with.

The start:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

contract HelperConfig {
    // If we are on a local Anvil, we deploy the mocks
    // Else, grab the existing address from the live network
}
```

Copy the following functions inside the contract:

```solidity
struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
}

function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory sepoliaConfig = NetworkConfig({
        priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
}

function getAnvilEthConfig() public pure returns (NetworkConfig memory) {

}
```

We decided to structure the information we need depending on the chain we are testing on. We use a `struct` to hold this information for every chain. You might think that we could have gotten away with a simple `address variable` but that changes if we need to store multiple addresses or even more blockchain-specific information.

For now, we created a `getSepoliaEthConfig` that returns the NetworkConfig struct, which contains the `priceFeed` address.

What do we need to do to integrate this inside the deployment script?

First of all, we need to be aware of the chain we are using. We can do this in the constructor of the HelperConfig contract.

Update the `HelperConfig` as follows:

```solidity
NetworkConfig public activeNetworkConfig;

struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
}

constructor(){
    if (block.chainid == 11155111) {
        activeNetworkConfig = getSepoliaEthConfig();
    } else {
        activeNetworkConfig = getAnvilEthConfig();
    }
}
```

As you can see, we've defined a new state variable, called activeNetworkConfig which will be the struct that gets queried for blockchain-specific information. We will check the `block.chainId` at the constructor level, and depending on that value we select the appropriate config.

The `block.chainId` in Ethereum refers to the unique identifier of the blockchain network in which the current block is being processed. This value is determined by the Ethereum network itself and is typically used by smart contracts to ensure that they are interacting with the intended network. Go on [chainlist.org](https://chainlist.org/) to find out the `ChainID`'s of different blockchains.

Let's update the `DeployFundMe.s.sol` to use our newly created `HelperConfig`.

`import {HelperConfig} from "./HelperConfig.s.sol";`

Add the following before the `vm.startBroadcast` line inside the `run` function:

```solidity
// The next line runs before the vm.startBroadcast() is called
// This will not be deployed because the `real` signed txs are happening
// between the start and stop Broadcast lines.
HelperConfig helperConfig = new HelperConfig();
address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
```

Run the `forge test --fork-url $SEPOLIA_RPC_URL` command to check everything is fine. All tests should pass.

Great, let's keep going.

Now that we've configured it for one chain, Sepolia, we can do the same with any other chain that has a `priceFeed` address available on [Chainlink Price Feed Contract Addresses](https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum\&page=1#overview). Simply copy the `getSepoliaEthConfig` function, rename it and provide the address inside it. Then add a new `block.chainId` check in the constructor that checks the current `block.chainId` against the `chainId` you find on [chainlist.org](https://chainlist.org/). You would also need a new RPC\_URL for the new blockchain you chose, which can be easily obtained from Alchemy.

This type of flexibility elevates your development game to the next level. Being able to easily test your project on different chains just by changing your RPC\_URL is an ability that differentiates you from a lot of solidity devs who fumble around with hardcoded addresses.

## Refactoring the mock smart contract

When we needed the Sepolia `priceFeed` we made sure that our deployments script pointed to it. How can we solve this in Anvil, because the contract that we need doesn't exist there. Simple, we deploy mocks.

Our `getAnvilEthConfig` function in `HelperConfig` must deploy a mock contract. After it deploys it we need it to return the mock address, so our contracts would know where to send their calls.

First of all, we need to make sure we import `Script.sol` in the `HelperConfig.s.sol` contract. Also, `HelperConfig` needs to inherit from `Script`. This will give us access to the `vm.startBroadcast`/`vm.stopBroadcast` functionality. We will use this to deploy our mocks. But ... what is a mock contract?

**A mock contract is a special type of contract designed to simulate the behavior of another contract during testing.**

Update your start of the `HelperConfig.s.sol` file as follows:

```solidity
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
}
```

In order to be able to deploy a mock contract we need ... a mock contract. So, in `test` folder please create a new folder called `mocks`. Inside `mocks` create a new file `MockV3Aggregator.sol`. Rewriting the AggregatorV3 as a mock is not the easiest task out there. Please copy the contents of [this contract](https://github.com/MRAlirad/foundry-fund-me/blob/master/test/mock/MockV3Aggregator.sol) into your newly created file.

We need to import this in our `HelperConfig.s.sol` file and deploy it in the `getAnvilEthConfig` then return the address.

Perform the following changes in `HelperConfig`:

```solidity
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

[...]

// In state variables section
MockV3Aggregator mockPriceFeed;

[...]

function getAnvilEthConfig() public returns (NetworkConfig memory) {
    vm.startBroadcast();
    mockPriceFeed = new MockV3Aggregator(8, 2000e8);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
        priceFeed: address(mockPriceFeed)
    });

    return anvilConfig;
}
```

## How to refactor magic number

Magic numbers refer to literal values directly included in the code without any explanation or context. These numbers can appear anywhere in the code, but they're particularly problematic when used in calculations or comparisons. By using magic numbers you ensure your smart contract suffers from **Reduced Readability**, **Increased Maintenance Difficulty** and **Debugging Challenges**.

Open `HelperConfig.s.sol`, go to the `getAnvilEthConfig` function and delete the `8` corresponding to the decimals and `2000e8` corresponding to the `_initialAnswer` that are used inside the `MockV3Aggregator`'s constructor.

At the top of the `HelperConfig` contract create two new variables:

```solidity
uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;
```

**Note: Constants are always declared in ALL CAPS!**

Now replace the deleted magic numbers with the newly created variables.

```solidity
function getAnvilEthConfig() public returns (NetworkConfig memory) {
    vm.startBroadcast();
    mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
        priceFeed: address(mockPriceFeed)
    });

    return anvilConfig;
}
```

## Refactoring the mock smart contract pt.2

One thing that we should do that would make our `getAnvilEthConfig` more efficient is to check if we already deployed the `mockPriceFeed` before deploying it once more.

Remember how addresses that were declared in state, but weren't attributed a value default to address zero? We can use this to create our check.

Right below the `function getAnvilEthConfig() public returns ...` line add the following:

```solidity
if (activeNetworkConfig.priceFeed != address(0)) {
    return activeNetworkConfig;
}
```

`getAnvilEthConfig` is not necessarily the best name. We are deploying something inside it, which means we are creating a new `mockPriceFeed`. Let's rename the function to `getOrCreateAnvilEthConfig`. Replace the name in the constructor.

Remember how `testPriceFeedVersionIsAccurate` was always failing when we didn't provide the option `--fork-url $SEPOLIA_RPC_URL`? Try running `forge test`. Try running `forge test --fork-url $SEPOLIA_RPC_URL`.

## Foundry tests: Cheatcodes

**Reminder:** Call `forge coverage` in your terminal. We need to bring that total coverage percentage as close to 100% as we can! Not all things require 100% coverage, or maybe achieving 100% coverage is too time expensive, but ... 12-13%? That is a joke, we can do way better than that.

Let's take a moment and look at the `fund` function from `FundMe.sol`. What should it do?

1. `require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD` this means that `fund` should revert if our `msg.value` converted in USDC is lower than the `MINIMUM_USD`;
2. `addressToAmountFunded[msg.sender] += msg.value;` The `addressToAmountFunded` mapping should be updated appropriately to show the funded value;
3. The `funders` array should be updated with `msg.sender`;

To test all these we will employ some of Foundry's main features ... it's `Cheatcodes`. As Foundry states in the Foundry Book: "Cheatcodes give you powerful assertions, the ability to alter the state of the EVM, mock data, and more.". Read more about them [here](https://book.getfoundry.sh/cheatcodes/).

To test point 1 we will use one of the most important cheatcodes: `expectRevert` (read more about it [here](https://book.getfoundry.sh/cheatcodes/expect-revert)).

Open `FundMe.t.sol` and add the following function:

```solidity
function testFundFailsWIthoutEnoughETH() public {
    vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
    fundMe.fund();     // <- We send 0 value
}
```

We are attempting to fund the contract with `0` value, it reverts and our test passes.

We need to write some getters for them, i.e. view functions that we will use to query the state of our smart contract.

Please add the following at the end of `FundMe.sol`:

```solidity
/** Getter Functions */

function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
    return s_addressToAmountFunded[fundingAddress];
}

function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
}
```

Add the following test in `FundMe.t.sol`:

```solidity
function testFundUpdatesFundDataStructure() public {
    fundMe.fund{value: 10 ether}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
    assertEq(amountFunded, 10 ether);
}
```

Run `forge test --mt testFundUpdatesFundDataStructure` in your terminal.

It fails! Why does it fail? Let's try it again, but this time put `address(this)` instead of `msg.sender`. Now it passed, but we still don't quite get why.

User management is a very important aspect you need to take care of when writing tests. Imagine you are writing a more complex contract, where you have different user roles, maybe the `owner` has some privileges, different from an `admin` who has different privileges from a `minter`, who, as you've guessed, has different privileges from the `end user`. How can we differentiate all of them in our testing? We need to make sure we can write tests about who can do what.

As always, Foundry can help us with that. Please remember the cheatcodes below, you are going to use them thousands of times.

1. [prank](https://book.getfoundry.sh/cheatcodes/prank)
   "Sets `msg.sender` to the specified address for the next call. “The next call” includes static calls as well, but not calls to the cheat code address."

2. [startPrank](https://book.getfoundry.sh/cheatcodes/start-prank) and [stopPrank](https://book.getfoundry.sh/cheatcodes/stop-prank)
   `startPrank` Sets `msg.sender` for all subsequent calls until `stopPrank` is called. It works a bit like `vm.startBroadcast` and `vm.stopBroadcast` we used to write our deployment script. Everything between the `vm.startPrank` and `vm.stopPrank` is signed by the address you provide inside the ().

but who is the actual user that we are going to use in one of the cheatcodes above? We have another cheatcode for this. To create a new user address we can use the `makeAddr` cheatcode. Read more about it [here](https://book.getfoundry.sh/reference/forge-std/make-addr?highlight=mak#makeaddr).

Add the following line at the start of your `FundMeTest` contract:

```solidity
address alice = makeAddr("alice");
```

Now whenever we need a user to call a function we can use `prank` and `alice` to run our tests.

To further increase the readability of our contract, let's avoid using a magic number for the funded amount. Create a constant variable called `SEND_VALUE` and give it the value of `0.1 ether` (don't be scared by the floating number which technically doesn't work with Solidity - `0.1 ether` means `10 ** 17 ether`).

Back to our test, add the following test in `FundMe.t.sol`:

```solidity
function testFundUpdatesFundDataStructure() public {
    vm.prank(alice);
    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
    assertEq(amountFunded, SEND_VALUE);
}
```

Let's run `forge test --mt testFundUpdatesFundDataStructure` again.

It fails

But why? Let's call `forge test --mt testFundUpdatesFundDataStructure -vvv` to get more information about where and why it fails.

```Solidity
Ran 1 test for test/FundMe.t.sol:FundMeTest
[FAIL. Reason: EvmError: Revert] testFundUpdatesFundDataStructure() (gas: 16879)
Traces:
  [16879] FundMeTest::testFundUpdatesFundDataStructure()
    ├─ [0] VM::prank(alice: [0x328809Bc894f92807417D2dAD6b7C998c1aFdac6])
    │   └─ ← [Return] 
    ├─ [0] FundMe::fund{value: 100000000000000000}()
    │   └─ ← [OutOfFunds] EvmError: OutOfFunds
    └─ ← [Revert] EvmError: Revert

Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 696.30µs (25.10µs CPU time)
```

How can someone fund our FundMe contract when they have 0 balance? They can't.

We need a way to give `alice` some ether to be able to use her address for testing purposes.

Foundry to the rescue! There's always a cheatcode to help you overcome your hurdles.

`deal` allows us to set the ETH balance of a user. Read more about it [here](https://book.getfoundry.sh/cheatcodes/deal).

Add the following line at the end of the setup.

```solidity
vm.deal(alice, STARTING_BALANCE);
```

Declare the `STARTING_BALANCE` as a constant variable up top:

```solidity
uint256 constant STARTING_BALANCE = 10 ether;
```

Let's run `forge test --mt testFundUpdatesFundDataStructure` again.

## Adding more coverage to the tests

Add the following test to your `FundMe.t.sol`:

```solidity
function testAddsFunderToArrayOfFunders() public {
    vm.startPrank(alice);
    fundMe.fund{value: SEND_VALUE}();
    vm.stopPrank();

    address funder = fundMe.getFunder(0);
    assertEq(funder, alice);
}
```

We start with our user `alice` who calls `fundMe.fund` in order to fund the contract. Then we use the `getter` function we created in the previous lesson to query what is registered inside the `funders` array at index `0`. We then use the `assertEq` cheatcode to compare the address we queried against `alice`.

Run the test using `forge test --mt testAddsFunderToArrayOfFunders`.

Each of our tests uses a fresh `setUp`, so if we run all of them and `testFundUpdatesFundDataStrucutre` calls `fund`, that won't be persistent for `testAddsFunderToArrayOfFunders`.

We should test the `withdraw` function. Let's check that only the owner can `withdraw`.

Add the following test to your `FundMe.t.sol`:

```solidity
function testOnlyOwnerCanWithdraw() public {
    vm.prank(alice);
    fundMe.fund{value: SEND_VALUE}();

    vm.expectRevert();
    vm.prank(alice);
    fundMe.withdraw();
}
```

We start with our user `alice` who calls `fundMe.fund` in order to fund the contract. We then use Alice's address to try and withdraw. Given that Alice is not the owner of the contract, it should fail. That's why we are using the `vm.expectRevert` cheatcode.

**REMEMBER:** Whenever you have a situation where two or more `vm` cheatcodes come one after the other keep in mind that these would ignore one another. In other words, when we call `vm.expectRevert();` that won't apply to `vm.prank(alice);`, it will apply to the `withdraw` call instead. The same would have worked if these had been reversed. Cheatcodes affect transactions, not other cheatcodes.

Run the test using `forge test --mt testOnlyOwnerCanWithdraw`.

As you can see, in both `testAddsFunderToArrayOfFunders` and `testOnlyOwnerCanWithdraw` we used `alice` to fund the contract. Copy-pasting the same snippet of code over and over again, if we end up writing hundreds of tests, is not necessarily the best approach. We can see each line of code/block of lines of code as a building block. Multiple tests will share some of these building blocks. We can define these building blocks using modifiers to dramatically increase our efficiency in writing tests.

Add the following modifier to your `FundMe.t.sol`:

```solidity
modifier funded() {
    vm.prank(alice);
    fundMe.fund{value: SEND_VALUE}();
    assert(address(fundMe).balance > 0);
    _;
}
```

We first use the `vm.prank` cheatcode to signal the fact that the next transaction will be called by `alice`. We call `fund` and then we assert that the balance of the `fundMe` contract is higher than 0, if true, it means that Alice's transaction was successful. Every single time we need our contract funded we can use this modifier to do it.

Refactor the previous test as follows:

```solidity
function testOnlyOwnerCanWithdraw() public funded {
    vm.expectRevert();
    fundMe.withdraw();
}
```

Ok, we've tested that a non-owner cannot withdraw. But can the owner withdraw?

To test this we will need a new getter function. Add the following to the `FundMe.sol` file next to the other getter functions:

```solidity
function getOwner() public view returns (address) {
    return i_owner;
}
```

Make sure to make `i_owner` private.

The arrange-act-assert (AAA) methodology is one of the simplest and most universally accepted ways to write tests. As the name suggests, it comprises three parts:

* **Arrange:** Set up the test by initializing variables, and objects and prepping preconditions.
* **Act:** Perform the action to be tested like a function invocation.
* **Assert:** Compare the received output with the expected output.

We will start our test as usual:

```solidity
function testWithdrawFromASingleFunder() public funded {
}
```

Now we are in the first stage of the `AAA` methodology: `Arrange`

We first need to check the initial balance of the owner and the initial balance of the contract.

```solidity
uint256 startingFundMeBalance = address(fundMe).balance;
uint256 startingOwnerBalance = fundMe.getOwner().balance;
```

We have what we need to continue with the `Act` stage.

```solidity
vm.startPrank(fundMe.getOwner());
fundMe.withdraw();
vm.stopPrank();
```

Our action stage is comprised of pranking the owner and then calling `withdraw`.

We have reached our final testing part, the `Assert` stage.

We need to find out the new balances, both for the contract and the owner. We need to check if these match the expected numbers:

```solidity
uint256 endingFundMeBalance = address(fundMe).balance;
uint256 endingOwnerBalance = fundMe.getOwner().balance;
assertEq(endingFundMeBalance, 0);
assertEq(
    startingFundMeBalance + startingOwnerBalance,
    endingOwnerBalance
);
```

The `endingFundMeBalance` should be `0`, because we just withdrew everything from it. The `owner`'s balance should be the `startingFundMeBalance + startingOwnerBalance` because we withdrew the `fundMe` starting balance.

Let's run the test using the following command: `forge test --mt testWithdrawFromASingleFunder`

**Remember to call** **`forge test`** **from time to time to ensure that any changes to the main contract or to testing modifiers or setup didn't break any existing tests. If it did, go back and see how the changes affected the test and modify them to accustom it.**

Ok, we've tested that the owner can indeed `withdraw` when the `fundMe` contract is funded by a single user. Can they `withdraw` when the contract is funded by multiple users?

Put the following test in your `FundMe.t.sol`:

```solidity
function testWithdrawFromMultipleFunders() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        // we get hoax from stdcheats
        // prank + deal
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    assert(address(fundMe).balance == 0);
    assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
}
```

We start by declaring the total number of funders. Then we declare that the `startingFunderIndex` is 1. You see that both these variables are defined as `uint160` and not our usual `uint256`. Down the road, we will use the `startingFunderIndex` as an address. If we look at the definition of an [address](https://docs.soliditylang.org/en/latest/types.html#address) we see that it holds `a 20 byte value` and that `explicit conversions to and from address are allowed for uint160, integer literals, bytes20 and contract types`. Having the index already in `uint160` will save us from casting it when we need to convert it into an address.

We start a `loop`. Inside this `loop` we need to `deal` and `prank` an address and then call `fundMe.fund`. Foundry has a better way: [hoax](https://book.getfoundry.sh/reference/forge-std/hoax?highlight=hoax#hoax). This works like `deal` + `prank`. It pranks the indicated address while providing some specified ether.

`hoax(address(i), SEND_VALUE);`

As we've talked about above, we use the `uint160` index to obtain an address. We start our index from `1` because it's not advised to user `address(0)` in this way. `address(0)` has a special regime and should not be pranked.

The `SEND_VALUE` specified in `hoax` represents the ether value that will be provided to `address(i)`.

Now that we have pranked an address and it has some balance we call `fundeMe.fund`.

After the loop ends we repeat what we did in the `testWithdrawFromASingleFunder`. We record the contract and owner's starting balances. This concludes our `Arrange` stage.

The next logical step is pranking the `owner` and withdrawing. This starts the `Act` stage.

In the `Assert` part of our test, we compare the final situation against what we expected.

`assert(address(fundMe).balance == 0);`

After withdrawal, `fundMe`'s balance should be 0.

`assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);`

The `owner`'s balance should be equal to the sum of `startingOwnerBalance` and the amount the `owner` withdrew (which is the `startingFundMeBalance`).

`assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);`

We compare the product between the total number of funders and `SEND_VALUE` to the total shift in the `owner`'s balance.
We added `1` to the `numberOfFunders` because we used the `funded` modifier which also adds `alice` as one of the funders.

Run the test using `forge test --mt testWithdrawFromMultipleFunders`. Run all tests using `forge test`.

Let's run `forge coverage` and see if our coverage table got better.

## An Introduction to Chisel

`Chisel` is one of the 4 components of Foundry alongside `forge`, `cast` and `anvil`. It's a tool that allows users to quickly test the behavior of Solidity code on a local (anvil) or forked network.

Usually, when you want to test a small Solidity code snippet you go to Remix. But why do that when you have what you need right in the terminal of your Foundry project.

Type `chisel` in your terminal and press Enter.

This opens up a shell that awaits your next command. Call `!help` to find out more about what commands are available.

Basically, you can simply write solidity in the shell then play around and see how it behaves.

For example:

1. Type `uint256 cat = 1`;
2. Type cat;

```Solidity
➜ cat
Type: uint256
├ Hex: 0x0000000000000000000000000000000000000000000000000000000000000001
├ Hex (full word): 0x0000000000000000000000000000000000000000000000000000000000000001
└ Decimal: 1
➜ 
```

1. Type `uint256 dog = 2;`
2. Type `cat + dog`

```Solidity
Type: uint256
├ Hex: 0x0000000000000000000000000000000000000000000000000000000000000003
├ Hex (full word): 0x0000000000000000000000000000000000000000000000000000000000000003
└ Decimal: 3
➜ 
```

1. Type `uint256 frog = 10;`
2. Type `require(frog > cat);` - If nothing happens it means it passed, now try it the other way
3. Type `require(cat > frog);`

```Solidity
➜ require(frog > cat);
➜ require(cat > frog);
Traces:
  [197] 0xBd770416a3345F91E4B34576cb804a576fa48EB1::run()
    └─ ← [Revert] EvmError: Revert

⚒️ Chisel Error: Failed to execute REPL contract!
➜ 
```

It reverts!

Press `Ctrl + C` twice to exit and return to your normal terminal.

To find more about other Chisel functionality, please click [here](https://book.getfoundry.sh/reference/chisel/).

## Calculate Withdraw gas costs

Gas refers to a unit that measures the computational effort required to execute a specific operation on the network. You can think of it as a fee you pay to miners or validators for processing your transaction and storing the data on the blockchain.

An important aspect of smart contract development is making your code efficient to minimize the gas you/other users spend when calling functions. This can have a serious impact on user retention for your protocol. Imagine you have to exchange 0.1 ETH for 300 USDC, but you have to pay 30 USDC in gas fees. No one wants to pay that. It's your duty as a developer to minimize gas consumption.

Now that you understand the importance of minimizing gas consumption, how do we find out how much gas things cost?

Let's take a closer look at `testWithdrawFromASingleFunder` test.

Run the following command in your terminal:

`forge snapshot --mt testWithdrawFromASingleFunder`

You'll see that a new file appeared in your project root folder: `.gas-snapshot`. When you open it you'll find the following:

`FundMeTest:testWithdrawFromASingleFunder() (gas: 84824)`

This means that calling that test function consumes `84824` gas. How do we find out what this means in \$?

Etherscan provides a super nice tool that we can use: <https://etherscan.io/gastracker>. Here, at the moment I'm writing this lesson, it says that the gas price is around `7 gwei`. If we multiply the two it gives us a total price of `593,768 gwei`. Ok, at least that's an amount we can work with. Now we will use the handy [Alchemy converter](https://www.alchemy.com/gwei-calculator) to find out that `593,768 gwei = 0.000593768 ETH` and `1 ETH = 2.975,59 USD` according to [Coinmarketcap](https://coinmarketcap.com/) meaning that our transaction would cost `1.77 USD` on Ethereum mainnet. Let's see if we can lower this.

**Note: The gas price and ETH price illustrated above correspond to the date and time this lesson was written, these vary, please use the links presented above to find out the current gas and ETH price**

Looking closer at the `testWithdrawFromASingleFunder` one can observe that we found out the initial balances, then we called a transaction and then we asserted that `startingFundMeBalance + startingOwnerBalance` matches the expected balance, but inside that test we called `withdraw` which should have cost gas. Why didn't the gas we paid affect our balances? Simple, for testing purposes the Anvil gas price is defaulted to `0` (different from what we talked about above in the case of Ethereum mainnet where the gas price was around `7 gwei`), so it wouldn't interfere with our testing.

Let's change that and force the `withdraw` transaction to have a gas price.

At the top of your `FundMeTest` contract define the following variable:

```solidity
uint256 constant GAS_PRICE = 1;
```

and refactor the `testWithdrawFromASingleFunder` function as follows:

```solidity
function testWithdrawFromASingleFunder() public funded {
    // Arrange
    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.txGasPrice(GAS_PRICE);
    uint256 gasStart = gasleft();

    // Act
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    uint256 gasEnd = gasleft();
    uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
    console.log("Withdraw consumed: %d gas", gasUsed);

    // Assert
    uint256 endingFundMeBalance = address(fundMe).balance;
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    assertEq(endingFundMeBalance, 0);
    assertEq(
        startingFundMeBalance + startingOwnerBalance,
        endingOwnerBalance
    );
}
```

We changed the following:

1. We used a new cheatcode called `vm.txGasPrice`, this sets up the transaction gas price for the next transaction. Read more about it [here](https://book.getfoundry.sh/cheatcodes/tx-gas-price).
2. We used `gasleft()` to find out how much gas we had before and after we called the transaction. Then we subtracted them to find out how much the `withdraw` transaction consumed. `gasleft()` is a built-in Solidity function that returns the amount of gas remaining in the current Ethereum transaction.
3. Then we logged the consumed gas. Read more about [Console Logging here](https://book.getfoundry.sh/reference/forge-std/console-log)

Let's run the test:

`forge test --mt testWithdrawFromASingleFunder -vv`

```Solidity
[⠰] Compiling...
[⠔] Compiling 26 files with Solc 0.8.19
[⠘] Solc 0.8.19 finished in 1.06s
Compiler run successful!

Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testWithdrawFromASingleFunder() (gas: 87869)
Logs:
  Withdraw consummed: 10628 gas

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.67ms (2.06ms CPU time)
```

## Storage Optimization - Introduction

**Storage** is the specific area within the blockchain where data associated with a smart contract is permanently saved. These are the variables that we defined at the top of our contract, before going into functions, also called **state variables** or **global variables**.

Imagine yourself being in a giant locker room, and in each locker, you have a space of 32 bytes. Each locker (storage space) is numbered/labeled and its number/label acts as the key, in the key-value pair, thus using this number/label we can access what's stored in the locker. Think of state variables as the labels you give to these lockers, allowing you to easily retrieve the information you've stored. But remember, space on this shelf isn't unlimited, and every time you add or remove something, it comes at a computational cost. From the previous lessons, we learned that this computational cost bears the name of `gas`.

So, being a tidy developer, you'll want to use your storage efficiently, potentially packing smaller data types together or using mappings (fancy ways of labeling sections of the locker) to keep things orderly and cost-effective.

The following info is a bit more advanced, but please take your time and learn it. As we emphasized in the previous lesson, the amount of gas people pay for in interacting with your protocol can be an important element for their retention, regardless of the type of web3 protocol you'll build.

***No one likes paying huge transaction costs.***

### Layout of State Variables in Storage

The [Solidity documentation](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html) is extremely good for understanding this subject.

The important aspects are the following:

* Each storage has 32 bytes;
* The slots numbering starts from 0;
* Data is stored contiguously starting with the first variable placed in the first slot;
* Dynamically-sized arrays and mappings are treated differently (we'll discuss them below);
* The size of each variable, in bytes, is given by its type;
* If possible, multiple variables < 32 bytes are packed together;
* If not possible, a new slot will be started;
* Immutable and Constant variables are baked right into the bytecode of the contract, thus they don't use storage slots.

Now this seems like a lot, but let's go through some examples: (Try to think about how the storage looks before reading the description)

```solidit
uint256 var1 = 1337;
uint256 var2 = 9000;
uint64 var3 = 0;
```

How are these stored?

In `slot 0` we have `var1`, in `slot 1` we have `var2`, and in `slot 3` we have `var 3`. Because `var 3` only used 8 bytes, we have 24 bytes left in that slot. Let's try another one:

```solidity
uint64 var1 = 1337;
uint128 var2 = 9000;
bool var3 = true;
bool var4 = false;
uint64 var5 = 10000;
address user1 = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
uint128 var6 = 9999;
uint8 var7 = 3;
uint128 var8 = 20000000;
```

How are these stored?

Let's structure them better this time:

`slot 0`

* var1 8 bytes (8 total)
* var2 16 bytes (24 total)
* var3 1 byte (25 total)
* var4 1 byte (26 total)
* var5 has 8 bytes, it would generate a total of 34 bytes, but we have only 32 so we start the next slot

`slot 1`

* var5 8 bytes (8 total)
* user1 20 bytes (28 total)
* var6 has 8 bytes, it would generate a total of 36 bytes, we have a max of 32 so we start the next slot

`slot2`

* var6 16 byes (16 total)
* var7 1 byte (17 total)
* var8 has 16 bytes, it would generate a total of 33 bytes, but as always we have only 32, we start the next slot

`slot3`

* var8 16 bytes (16 total)

Can you spot the inefficiency? `slot 0` has 6 empty bytes, `slot 1` has 4 empty bytes, `slot 2` has 15 empty bytes, `slot 3` has 16 empty bytes. Can you come up with a way to minimize the number of slots?

What would happen if we move `var7` between `var4` and `var5`, so we fit its 1 byte into `slot 0`, thus reducing the total of `slot2` to 16 bytes, leaving enough room for `var8` to fit in. You get the gist.

The total bytes of storage is 87. We divide that by 32 and we find out that we need at least 2.71 slots ... which means 3 slots. We cannot reduce the number of slots any further.

Mappings and Dynamic Arrays can't be stored in between the state variables as we did above. That's because we don't quite know how many elements they would have. Without knowing that we can't mitigate the risk of overwriting another storage variable. The elements of mappings and dynamic arrays are stored in a different place that's computed using the Keccak-256 hash. Please read more about this [here](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#mappings-and-dynamic-arrays).

### Back to FundMe

Make sure that you have the following getter in `FundMe.sol`:

```solidity
function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
}
```

Please add the following function in your `FundMe.t.sol`:

```solidity
function testPrintStorageData() public {
    for (uint256 i = 0; i < 3; i++) {
        bytes32 value = vm.load(address(fundMe), bytes32(i));
        console.log("Value at location", i, ":");
        console.logBytes32(value);
    }
    console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
}
```

In the test above we used a new cheatcode: `vm.load`. Its sole purpose is to load the value found in the provided storage slot of the provided address. Read more about it [here](https://book.getfoundry.sh/cheatcodes/load).

Run the test above by calling this in your terminal:

`forge test --mt testPrintStorageData -vv`

```Solidity
Ran 1 test for test/FundMe.t.sol:FundMeTest
[PASS] testPrintStorageData() (gas: 19138)
Logs:
    Value at location 0 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    Value at location 1 :
    0x0000000000000000000000000000000000000000000000000000000000000000
    Value at location 2 :
    0x00000000000000000000000090193c961a926261b756d1e5bb255e67ff9498a1
    PriceFeed address: 0x90193C961A926261B756D1E5bb255e67ff9498A1

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 771.50µs (141.90µs CPU time)
```

Let's interpret the data above:

* In `slot 0` we have a bytes32(0) stored (or 32 zeroes). This happened because the first slot is assigned to the `s_addressToAmountFunded` mapping.
* In `slot 1` we have a bytes32(0) stored. This happened because the second slot is assigned to the `s_funders` dynamic array.
* In `slot 2` we have `0x00000000000000000000000090193c961a926261b756d1e5bb255e67ff9498a1` stored. This is composed of 12 pairs of zeroes (12 x 00) corresponding to the first 12 bytes and `90193c961a926261b756d1e5bb255e67ff9498a1`. If you look on the next line you will see that is the `priceFeed` address.

This is one of the methods of checking the storage of a smart contract.

Another popular method is using `forge inspect`. This is used to obtain information about a smart contract. Read more about it [here](https://book.getfoundry.sh/reference/forge/forge-inspect).

Call the following command in your terminal:

`forge inspect FundMe storageLayout`

If we scroll to the top we will find a section called `storage`. Here you can find the `label`, the `type` and the `slot` it corresponds to. It's simpler than using `vm.load` but `vm.load` is more versatile, as in you can run tests against what you expect to be stored vs what is stored.

Another method of checking a smart contract's storage is by using `cast storage`. For this one, we need a bit of setup.

Open a new terminal, and type `anvil` to start a new `anvil` instance.

Deploy the `fundMe` contract using the following script:

`forge script DeployFundMe --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast`

The rpc url used is the standard `anvil` rpc. The private key used is the first of the 10 private keys `anvil` provides.

In the `Return` section just printed in the terminal, we find the address of the newly deployed `fundMe`. In my case, this is `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`.

Call the following command in your terminal:

`cast storage 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 2`

This prints what's stored in slot number 2 of the `fundMe` contract. This checks with our previous methods of finding what's in slot number 2 (even if the address is different between methods).

**Very important note: the word** **`private`** **has multiple meanings in the** **[Merriam Webster dictionary](https://www.merriam-webster.com/dictionary/private). Always remember that the keyword** **`private`** **attached to a variable/function means that the variable/function has restricted access from other parties apart from the main contract.**

**THIS DOESN'T MEAN THE VARIABLE IS A SECRET!!!**

**Everything on the blockchain is public. Any smart contract's storage can be accessed in one of the 3 ways we showed in this lesson. Do not share sensitive information or store passwords inside smart contracts, we can all read them.**

Storage is one of the harder Solidity subjects. Mastering it is one of the key prerequisites in writing gas-efficient and tidy smart contracts.

Congratz for getting to this point! Up next we will optimize the `withdraw` function.

## Optimise the withdraw function gas costs

In the previous lesson, we talked about storage. But why is storage management important?
Simple, reading and writing from storage is a very expensive operation.

Let's explore this subject more.

Open a new terminal, and type `anvil` to start a new `anvil` instance.

Deploy the `fundMe` contract using the following script:

```bash
forge script DeployFundMe --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast`
```

Copy the `fundMe` contract address.

Run the following command:
(replace the address here with the address of your newly deployed `fundMe` contract)

```bash
cast code 0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9`
```

Ok, the output looks like an extremely big chunk of random numbers and letters. Perfect!

Something to the extent of `0x608060405260043610610...736f6c63430008130033`. Copy the entire thing and put it in [here](https://etherscan.io/opcode-tool). Thus we obtain the `Decoded Bytecode` which is a list of Opcodes.

```Solidity
[1] PUSH1 0x80
[3] PUSH1 0x40
[4] MSTORE
[6] PUSH1 0x04
[7] CALLDATASIZE
[8] LT
[11] PUSH2 0x008a
[12] JUMPI
[14] PUSH1 0x00
[15] CALLDATALOAD
[17] PUSH1 0xe0
[18] SHR
[19] DUP1
[24] PUSH4 0x893d20e8
[25] GT
[28] PUSH2 0x0059
[...]
```

These look readable! But what are we reading?

Opcodes (short for operation codes) are the fundamental instructions that the EVM understands and executes. These opcodes are essentially the building blocks that power smart contract functionality. You can read about each opcode [here](https://www.evm.codes/).

In that table alongside the description, you will find the bytecode number of each opcode, the name of the opcode, the minimum gas it consumes and the input/output. Please be mindful of the gas each opcode costs. Scroll down the list until you get to the 51-55 opcode range.

As you can see an MLOAD/MSTORE has a minimum gas cost of 3 and a SLOAD/SSTORE has a minimum gas of 100 ... that's over 33x. And keep in mind these are minimums. The difference is usually bigger. This is why we need to be careful with saving variables in storage, every time we access or modify them we will be forced to pay way more gas.

Let's take a closer look at the `withdraw` function.

We start with a `for` loop, that is initializing a variable called `funderIndex` in memory and compares it with `s_funders.length` on every loop iteration. As you know `s_funders` is the private array that holds all the funder's addresses, currently located in the state variables zone. If we have 1000 funders, we will end up reading the length of the `s_funders` array 1000 times, paying the SLOAD costs 1000 times. This is extremely inefficient.

Let's rewrite the function. Add the following to your `FundMe.sol`:

```solidity
function cheaperWithdraw() public onlyOwner {
    uint256 fundersLength = s_funders.length;
    for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
        address funder = s_funders[funderIndex];
        s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);

    (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "Call failed");
}
```

First, let's cache the `s_funders` length. This means we create a new variable, inside the function (to be read as in memory) so if we read it 1000 times we don't end up paying a ridiculous amount of gas.

Then let's integrate this into the for loop.

The next step is getting the funder's address from storage. Sadly we can't avoid this one. After this we zero the recorded amount in the `s_addressToAmountFunded` mapping, also we can't avoid this. We then reset the `s_funders` array, and send the ETH. Both these operations cannot be avoided.

Let's find out how much we saved. Open `FundMe.t.sol`.

Let's copy the `testWithdrawFromMultipleFunders` function and replace the `withdraw` function with `cheaperWithdraw`.

```solidity
function testWithdrawFromMultipleFundersCheaper() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        // we get hoax from stdcheats
        // prank + deal
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.cheaperWithdraw();
    vm.stopPrank();

    assert(address(fundMe).balance == 0);
    assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
}
```

Now let's call `forge snapshot`. If we open `.gas-snapshot` we will find the following at the end:

```Solidity
FundMeTest:testWithdrawFromMultipleFunders() (gas: 535148)
FundMeTest:testWithdrawFromMultipleFundersCheaper() (gas: 534219)
```

As you can see, we saved up 929 gas just by caching one variable.

One of the reasons we easily identified this optimization was the use of `s_` in the `s_funders` array declaration. The ability to know, at any time, what comes from storage and what is in memory facilitates this type of optimization. That's why we recommend using the `s_` and `i_` and all upper case for constants, to always know what comes from where. Familiarize yourself with the style guide available [here](https://docs.soliditylang.org/en/v0.8.4/style-guide.html).

## Create Integration Tests

To seamlessly interact with our contract, we need to create a programmatic for using it's functions.

Please create a new file called `Interactions.s.sol` in the `script` folder.

In this file, we will create two scripts, one for funding and one for withdrawing.

Each contract will contain one script, and for it to work each needs to inherit from the Script contract. Each contract will have a `run` function which shall be called by `forge script` when we run it.

In order to properly interact with our `fundMe` contract we would want to interact only with the most recent deployment we made. This task is easily achieved using the `foundry-devops` library. Please install it using the following command:

```bash
forge install Cyfrin/foundry-devops --no-commit
```

Ok, now with that out of the way, let's work on our scripts.

Put the following code in `Interactions.s.sol`:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
```

We've created a new function called `fundFundMe` which takes an address corresponding to the most recently deployed `FundMe` contract. Inside we start and stop a broadcast which sends a transaction calling the `fund` function from the `FundMe` contract. We've imported `console` to be able to log the amount that we funded as a confirmation. Inside the `run` function, we call `get_most_recent_deployment` from the DevOpsTools to get the address of the most recently deployed `FundMe` contract. We then use the newly acquired address as input for the `fundFundMe` function.

The same thing is done for `WithdrawFundMe`.

We could run this using the standard `forge script script/Interactions.s.sol:FundFundMe --rpc-url xyz --private-key etc ...` command, but writing that over and over again is not cool. We could test how this behaves using integration tests.

Integration tests are crucial for verifying how your smart contract interacts with other contracts, external APIs, or decentralized oracles that provide data feeds. These tests help ensure your contract can properly receive and process data, send transactions to other contracts, and function as intended within the wider ecosystem.

Before starting with the integration tests let's organize our tests into folders. Let's separate unit tests from integration tests by creating separate folders inside the `test` folder.

Create two new folders called `integration` and `unit` inside the `test` folder. Move `FundMe.t.sol` inside the `unit` folder. Make sure to update `FundMe.t.sol` to accommodate this change.

Run a quick `forge test` to ensure that everything builds and all tests pass.

Inside the `integration` folder create a new file called `FundMeTestIntegration.t.sol`.

Paste the following code inside it:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address alice = makeAddr("alice");


    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
```

You will see that the first half, including the `setUp` is similar to what we did in `FundMe.t.sol`. The test `testUserCanFundAndOwnerWithdraw` has a similar structure to `testWithdrawFromASingleFunder` from `FundMe.t.sol`. We record the starting balances, we use `alice` to fund the contract then the `WithdrawFundMe` script to call `withdraw`. The next step is recording the ending balances and running the same assertions we did in `FundMe.t.sol`.

Run the integration test using the following command:

`forge test --mt testUserCanFundAndOwnerWithdraw -vv`

```Solidity
Ran 1 test for test/integration/InteractionsTest.t.sol:InteractionsTest
[PASS] testUserCanFundAndOwnerWithdraw() (gas: 330965)
Logs:
  Withdraw FundMe balance!

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 7.78ms (1.01ms CPU time)

Ran 1 test suite in 427.38ms (7.78ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

Pfew! I know this was a lot. You are a true champion for reaching this point!

**Note 1:** Depending on when you go through this lesson there is a small chance that `foundry-devops` library has a problem that prevents you from building. The reason this happening is `vm.keyExists` used at `foundry-devops/src/DevOpsTools.sol:119` is deprecated. Please replace `vm.keyExists` with `vm.keyExistsJson` in the place indicated. Next, we need to make sure that the `Vm.sol` contract in your forge-std library contains the `vm.keyExistsJson`. If you can't find it in your `Vm.sol` then please run the following command in your terminal: `forge update --force`. If you still can't `forge build` the project the please come ask questions in the Updraft section of Cyfrin's discord.

**Note 2:**

Inside the video lesson, Patrick touched on the subject of `ffi`. We didn't present it at length in the body of this lesson because `foundry-devops` doesn't need it anymore. But in short:

Forge FFI, which stands for Foreign Function Interface, is a cheatcode within the Forge testing framework for Solidity. It allows you to execute arbitrary shell commands directly from your Solidity test code.

* FFI enables you to call external programs or scripts from within your Solidity tests.
* You provide the command or script name along with any arguments as an array of strings.
* The Forge testing framework then executes the command in the underlying system environment and captures the output.

Read more about it [here](https://book.getfoundry.sh/cheatcodes/ffi?highlight=ffi#ffi).

A word of caution: FFI bypasses the normal security checks and limitations of Solidity. By running external commands, you introduce potential security risks if not used carefully. Malicious code within the commands you execute could compromise your setup. Whenever you clone repos or download other projects please make sure they don't have `ffi = true` in their `foundry.toml` file. If they do, we advise you not to run anything before you thoroughly examine where `ffi` is used and what commands is it calling. Stay safe!

## Automate your smart contracts actions - Makefile

If you think a bit about your experience with the whole `FundMe` project by now, how many times have you written a `forge script NameOfScript --rpc-url xyz --private-key 0xPrivateKey ...`. There's got to be an easier way to run scripts and other commands.

The answer for all your troubles is a `Makefile`!

A `Makefile` is a special file used in conjunction with the `make` command in Unix-based systems and some other environments. It provides instructions for automating the process of building software projects.

The main advantages of using a `Makefile` are:

* Automates tasks related to building and deploying your smart contracts.
* Integrates with Foundry commands like `forge build`, `forge test` and `forge script`.
* Can manage dependencies between different smart contract files.
* Streamlines the development workflow by reducing repetitive manual commands.
* Allows you to automatically grab the `.env` contents.

In the root folder of your project create a new file called `Makefile`.

After creating the file run `make` in your terminal.

If you have `make` installed then you should receive the following message:

`make: *** No targets.  Stop`

If you don't get this message you need to install `make`. This is a perfect time to ask your favorite AI to help, but if you still don't manage it please come on the Updraft section of Cyfrin discord and ask the lovely people there.

Let's start our `Makefile` with `-include .env` on the first line. This way we don't have to call `source .env` every time we want to access something from it.

Soo... how do we actually write a shortcut?

Let's write one for `forge build`.

In your `Makefile` write the following line:

`build:; forge build`

Run `make build` in your terminal.

```Solidity
make build
forge build
[⠔] Compiling...
No files changed, compilation skipped
```

And it works! We've written our first shortcut. Arguably not the best of shortcuts, we've saved 1 letter, but still, it's a start.

**Small note**: The `:;` between `build` and `forge build` is used to indicate that the command will be given on the same line. Change the `build` shortcut as follows:

```Solidity
build:
	forge build
```

Run it again.

Let's write a more complex shortcut. Add the following shortcut to your `Makefile`:

```Solidity
deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
```

Now this is a mouthful. But you already know what we did above, we used `forge script` to deploy `fundMe` on Sepolia, using the private key and rpc-url we provided in the `.env`, we used `--broadcast` for the transaction to be broadcasted, and then we `verify` the contract on etherscan. The only difference compared to what we did before is encapsulating `.env` variables between round brackets. This is how Makefile knows these come from the `.env`.

The `--verify` option `verifies all the contracts found in the receipts of a script, if any`. We could use the `--verifier` option to select another verifier, but we don't need that because the default option is `etherscan`. So the only thing we need is an etherscan API key. To get one go to [Etherscan.io](https://etherscan.io/register) and make an account. After that, log in, go to `OTHERS > API Keys` add a new project and copy the API Key Token.

Open your `.env` file and add the following line:

`ETHERSCAN_API_KEY=THEAPIKEYYOUCOPIEDFROMETHERSCANGOESHERE`

Make sure your `.env` holds all the things it needs to run the shortcut above. Again, we do not use private keys associated with accounts that hold real money. Stay safe!

The moment of truth:

`make deploy-sepolia`

```Solidity
ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.004665908735630779 ETH (577031 gas * avg 8.086062509 gwei)
##
Start verification for (1) contracts
Start verifying contract `0x2BC3f6eB5C38532F70DD59AC6A0610453bc16e9f` deployed on sepolia

Submitting verification for [src/FundMe.sol:FundMe] 0x2BC3f6eB5C38532F70DD59AC6A0610453bc16e9f.

Submitting verification for [src/FundMe.sol:FundMe] 0x2BC3f6eB5C38532F70DD59AC6A0610453bc16e9f.

Submitting verification for [src/FundMe.sol:FundMe] 0x2BC3f6eB5C38532F70DD59AC6A0610453bc16e9f.

Submitting verification for [src/FundMe.sol:FundMe] 0x2BC3f6eB5C38532F70DD59AC6A0610453bc16e9f.
Submitted contract for verification:
        Response: `OK`
        GUID: `cjgaycqnrssgths7jakwgbexwjzpa5tirhymzvhkrxitznnvzx`
        URL: https://sepolia.etherscan.io/address/0x2bc3f6eb5c38532f70dd59ac6a0610453bc16e9f
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!
```

The contract is deployed on Sepolia and we verified it on [Etherscan](https://sepolia.etherscan.io/address/0x2bc3f6eb5c38532f70dd59ac6a0610453bc16e9f).

Amazing work!

This is just an introductory lesson on how to write Makefiles. Properly organizing your scripts and then transforming them into shortcuts that save you from typing 3 lines of code in the terminal is an ART!

Let's pass through some examples. Go copy the [Makefile available in the Fund Me repo](https://github.com/Cyfrin/foundry-fund-me-f23/blob/main/Makefile).

Treat this `Makefile` as a framework for your projects.

Open the file and go through it.

The `.PHONY:` tells make that all the `all test clean deploy fund help install snapshot format anvil` are not folders. Following that we declare the `DEFAULT_ANIVL_KEY` and a custom help message.

Run make help to print it in your terminal.

There are a lot of useful shortcuts related to dependencies, formatting, deployment etc.

For example, run the following commands:

`make anvil`

Open a new terminal.

`make deploy`

And you just deployed a fresh `FundMe` contract on a fresh `anvil` blockchain. Super fast and super cool!

We could do the same for Sepolia by running `make deploy ARGS="--network sepolia"`.

## Zksync Devops

There are notable differences between the EVM and ZKsync Era VM, as detailed in the [ZKsync documentation](https://docs.zksync.io/build/developer-reference/ethereum-differences/evm-instructions). In this lesson, we will explore some DevOps tools designed to help run tests and functions on both VMs.

### `foundry-devops` Tools

In the `FundMeTest.t.sol` file, certain tests that run on Vanilla Foundry may not work on ZKsync Foundry, and vice versa. To address these differences, we will explore two packages from the [foundry-devops](https://github.com/Cyfrin/foundry-devops) repository: `ZkSyncChainChecker` and `FoundryZkSyncChecker`. This lesson will cover how to use these packages effectively.

```js
import { ZkSyncChainChecker } from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import { FoundryZkSyncChecker } from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";
```

### Setting Up ZkSyncDevOps

The file [`test/unit/ZkSyncDevOps.t.sol`](https://github.com/Cyfrin/foundry-fund-me-cu/blob/main/test/unit/ZkSyncDevOps.t.sol) is a minimal test file that shows how tests may fail on the ZKsync VM but pass on an EVM, or vice versa. You can follow these steps to set it up:

1. Copy the content from the GitHub repo into your project's `test/unit` directory, and create a new file named `ZkSyncDevOps.t.sol`.

2. Install any missing dependencies using the command:

```bash
forge install cyfrin/foundry-devops@0.2.2 --no-commit
```

3. Reset your modules with:

```bash
rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
```

or

```bash
make rm
```

4. Update your `.gitignore` file by adding `.DS_store` and `zkout/`.

### VM environments modifiers

You can switch environments between `fundryup` and `fundryup-zksync` to observe different behaviors of the `ZkSyncDevOps.t.sol` tests. For instance, the following command

```bash
forge test --mt testZkSyncChainFails -vvv
```

will pass in both Foundry environments. However, if you remove the `skipZkSync` modifier, the test will fail on ZKsync because the content of the function is not supported on this chain.

For more details on these modifiers, refer to the [foundry-devops repo](https://github.com/Cyfrin/foundry-devops?tab=readme-ov-file#usage---zksync-checker). The `skipzksync` modifier skips tests on the ZKsync chain, while `onlyzksync` runs tests only on a ZKsync-based chain.

### Foundry version modifiers

Some tests may fail depending on the Foundry version. The `FoundryZkSyncChecker` package assists in executing functions based on the Foundry version. The `onlyFoundryZkSync` modifier allows tests to run only if `foundryup--zksync` is active, while `onlyVanillaFoundry` works only if `foundryup` is active.

> 🗒️ **Note**:br
> Ensure `ffi = true` is enabled in the `foundry.toml` file.

## Recap


* We learned more about how to set up a Foundry project
* We learned how to organize our files into folders, following the convention
* We learned how to refactor smart contracts to make them modular and chain-agnostic
* We learned how to write scripts that act as interaction commands
* We learned more about using mocks
* We did a bunch of unit tests, we even did an integration test
* We learned a bit about Makefiles
* We learned how to create a GitHub repository and push our code in it
* We also learned how to clone a GitHub repository
