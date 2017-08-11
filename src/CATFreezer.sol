pragma solidity ^0.4.11;
import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/SafeMath.sol";

contract CATFreezer {
	using SafeMath for uint256;

	// Addresses and contracts
	address public CATContract;
	address public postFreezeDevCATDestination;

	// Freezer Data
	uint256 public firstAllocation;
	uint256 public secondAllocation;
	uint256 public firstThawDate;
	uint256 public secondThawDate;
	bool public firstUnlocked;

	function CATFreezer(
		address _CATContract,
		address _postFreezeDevCATDestination
	) {
		CATContract = _CATContract;
		postFreezeDevCATDestination = _postFreezeDevCATDestination;

		firstThawDate = now + 365 days;  // One year from now
		secondThawDate = now + 2 * 365 days;  // Two years from now
		
		firstUnlocked = false;
	}

	function unlockFirst() external {
		if (firstUnlocked) throw;
		if (msg.sender != postFreezeDevCATDestination) throw;
		if (now < firstThawDate) throw;
		
		firstUnlocked = true;
		
		uint256 totalBalance = StandardToken(CATContract).balanceOf(this);

		// Allocations are each 50% of developer tokens
		firstAllocation = totalBalance.div(2);
		secondAllocation = totalBalance.sub(firstAllocation);
		
		uint256 tokens = firstAllocation;
		firstAllocation = 0;

		StandardToken(CATContract).transfer(msg.sender, tokens);
	}

	function unlockSecond() external {
		if (!firstUnlocked) throw;
		if (msg.sender != postFreezeDevCATDestination) throw;
		if (now < secondThawDate) throw;
		
		uint256 tokens = secondAllocation;
		secondAllocation = 0;

		StandardToken(CATContract).transfer(msg.sender, tokens);
	}

	function changeCATDestinationAddress(address _newAddress) external {
		if (msg.sender != postFreezeDevCATDestination) throw;
		postFreezeDevCATDestination = _newAddress;
	}
}
