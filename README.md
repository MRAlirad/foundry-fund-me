# Foundry Fund Me

Welcome to the Fund Me section of this Foundry course! To get started, you can visit the [Github repository](https://github.com/Cyfrin/foundry-fund-me-cu) associated with this section. By the end of this course, you'll be able to push your first codebase to Github 🎉.

> 💡 **TIP**:br
> Being active on a version control system like Github or [Radicle](https://radicle.xyz/) is essential for participating in the web3 ecosystem 👥.

In this section, we'll refer to the `FundMe` contract we built in the previous section. Additionally, we will explore storage using the [`FunWithStorage`](https://github.com/Cyfrin/foundry-fund-me-cu/blob/main/src/exampleContracts/FunWithStorage.sol) contract and interact with it using `cast`.

We'll also learn professional deployment techniques on different chains with Foundry **[scripts](https://github.com/Cyfrin/foundry-fund-me-cu/blob/main/script/DeployFundMe.s.sol)**. They will enable us to interact with contracts through **reproducible actions** instead of typing commands manually each time.

Furthermore, we'll cover making contracts more gas-efficient, some debugging techniques, and setting up a professional development environment.
Lastly, we'll implement a lot of **tests** to ensure the reliability and security of our smart contracts.

## Setup

Welcome the second section of `Foundry Fundamentals`. Here we'll cover `Fund Me`, a simple funding contract.

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

Until now, we talked a lot about storage and state, but we didn't delve into what they really mean. We will learn what all these means!

We used this project before when we used Remix.

### Fund Me

Going through the [repo](https://github.com/Cyfrin/foundry-fund-me-f23) we can see that our contract is in the `src` folder. Let's open `FundMe.sol`.

As you can see we are employing some advanced tools/standard naming conventions:

-   We use a named error `FundMe__NotOwner();`
-   We use all caps for constants
-   `i_` for immutable variables
-   `s_` for private variables

Let's clone this project locally. Open your VS Code, and make sure you are in the `foundry-f23` folder, if not use `cd` to navigate to it.

If we run the `ls` command in the terminal, we'll see that the only thing present in the `foundry-f23` folder is the `foundry-simple-storage-f23` folder that we used in the previous section.

Run the following command in your terminal:

```Solidity
mkdir foundry-fund-me-f23
cd foundry-fund-me-f23
code .
```

The first line creates a new folder called `foundry-fund-me-f23`. The second line changed the directory into the newly created folder. The last line opens up a new VS Code instance using the newly created folder.

Now we can apply the knowledge we acquired in the previous section to create a fresh Foundry project.

**Do you remember how?**

If you do, please proceed in creating a Foundry project on your own. If not peek down below.

No worries, we all forget stuff, please run the following command:

```Solidity
forge init
```

or

```Solidity
forge init --force
```

Foundry will populate the project with the `Counter` files, the script, the main contract and the test.

Before deleting it, let's look a bit through these.

## Smart Contract testing

Continuing from the previous lesson, the `forge init` populated our project with the `Counter` files.

#### Counter.sol

It's a simple smart contract that stores a number. You have a function to `setNumber` where you specify a `newNumber` which is a `uint256`, and store it, and you have a function to `increment` the number.

**Note:** `number++` is equivalent to `number = number + 1`.

#### Counter.s.sol

Just a placeholder, it doesn't do anything

#### Counter.t.sol

This is the interesting part. We haven't talked that much about carrying tests using Foundry. This is an essential step for any project. The `test` folder will become our new home throughout this course.

Please run the following command in your terminal:

```Solidity
forge test
```

After the contracts are compiled you will see an output related to tests:

-   How many tests were found;
-   In which file;
-   Did they pass or not?;
-   Summary;

### How does `forge test` work?

`forge test` has a lot of options that allow you to configure what is tested, how the results are displayed, where is the test conducted and many more!

Run `forge test --help` to explore the options. I suggest reading [this page](https://book.getfoundry.sh/forge/tests) and navigating deeper into the Foundry Book to discover how tests work.

But in short, in our specific case:

1. Forge identified all the files in the test folder, went into the only file available and ran the `setUp` function.
2. After the setup is performed it goes from top to bottom in search of public/external functions that start with `test`.
3. All of them will be called and the conclusion of their execution will be displayed. By that we mean it will run all the `assert` statements it can find and if all evaluate to `true` then the test will pass. If one of the `assert` statements evaluates to `false` the test will fail.
