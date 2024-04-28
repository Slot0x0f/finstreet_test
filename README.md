## FinStreet Blockchain Developer Test

**This is a repository with the code for an upgradeable governance contract as specified by the FinStreet Hiring Test**

This repo consists of:

-   **FinGovernor.sol**: The governance contract inheriting the state of the art OZ Governorupgradeable.
-   **FinGovToken.sol**: This is a ERC20Votes token that is used to see the votes an account has during the given time.
-   **FinTimeLock.sol**: This is the timelock contract that will make sure there is some delay before the proposal is executed.
-   **Box.sol**: This is an example contract that can be changed via the proposal (Since the proposal can use arbitrary address and calldata it can be used to call various types of contracts).

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge install
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```
