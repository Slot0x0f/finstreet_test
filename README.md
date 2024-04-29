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
$ forge clean
$ forge test
```

### Format

```shell
$ forge fmt
```

 **Contracts deployed to Base Chain at:**

Fingovtoken : 0x91Ce6fEC501fc5e2dA8Ed6cB85603906ea4cd21F

FinTimeLock: 0xd0A5fc1905D65775D43daACC99CFeaCe6b824c8c

FinGovernor: 0x50c40C1C3e2265995601da446CD2b7Cf05146c66

 **Document explaining the requirements fulfilled:**

https://docs.google.com/document/d/1GVSRDjbJYef9n-GmzjL9PBdBDPqRDXyxeMkNY_L7lM4/edit?usp=sharing