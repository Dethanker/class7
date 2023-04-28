
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Factory.sol



// https://github.com/makefriendwithtime/stafi-contract/blob/main/contracts/Factory.sol

pragma solidity >=0.8.2 <0.9.0;


interface IGovernance{
    function initialize(
        uint256 _authorAmount,
        uint _blockHeight,
        address _owner
    ) external;
    function setStkTokenAddr(address _stkTokenAddr) external;
    function setRetTokenAddr(address _retTokenAddr) external;
    function setRewardAddr(address _rewardAddr) external;
    function setSearchAddr(address _searchAddr) external;
    function stkTokenAddr() external view returns (address);
    function retTokenAddr() external view returns (address);
    function rewardAddr() external view returns (address);
    function searchAddr() external view returns (address);
}

interface IPool{
    function initialize (
        address _governAddr,
        address _owner,
        string memory name_,
        string memory symbol_,
        address _faucetModelAddr
    ) external;
    function faucetModelAddr() external view returns (address);
}

interface IAirdrop{
    function initialize (
        address _governAddr,
        string memory name_,
        string memory symbol_,
        address _account,
        uint _amount,
        address _owner
    ) external;
}

interface IReward{
    function initialize (address _governAddr, address _owner) external;
}

interface ISearch{
    function initialize (
        address _governAddr,
        address _poolAddr,
        address _rewardAddr,
        address _airdropAddr
    ) external;
}

contract Factory is Ownable{
    mapping(uint => address) private daoAddrs;
    uint public len = 0;
    //governance模板地址
    address  public governModelAddr;
    //pool模板地址
    address  public poolModelAddr;
    //airdrop模板地址
    address  public airdropModelAddr;
    //reward模板地址
    address  public rewardModelAddr;
    //faucet模板地址
    address public faucetModelAddr;
    //search模板地址
    address public searchModelAddr;

    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function createDAO(
        uint256 _authorAmount, //100000000000000000000
        uint _blockHeight,//1200 部署时根据实际网络调整
        string memory _stkName,//stkToken票据所有权
        string memory _stkSymbol,//stkToken
        string memory _retName,//retToken票据使用权
        string memory _retSymbol,//retToken
        uint _retAmount//10000000000000000000000
    ) public onlyOwner(){
        require(governModelAddr != address(0)
        && poolModelAddr != address(0)
        && airdropModelAddr != address(0)
        && rewardModelAddr != address(0)
        && faucetModelAddr != address(0)
            && searchModelAddr != address(0),'ModelAddress not seted!');
        IGovernance Igovern = IGovernance(createClone(governModelAddr));
        Igovern.initialize(_authorAmount,_blockHeight,msg.sender);

        IPool Ipool = IPool(createClone(poolModelAddr));
        Ipool.initialize(address(Igovern),msg.sender,_stkName,_stkSymbol,faucetModelAddr);

        //设置Government的stkToken地址
        Igovern.setStkTokenAddr(address(Ipool));

        IAirdrop Iairdrop = IAirdrop(createClone(airdropModelAddr));
        Iairdrop.initialize(address(Igovern),_retName,_retSymbol,msg.sender,_retAmount,msg.sender);

        //设置Government的retToken地址
        Igovern.setRetTokenAddr(address(Iairdrop));

        IReward Ireward = IReward(createClone(rewardModelAddr));
        Ireward.initialize(address(Igovern),msg.sender);

        //设置Government的奖励地址
        Igovern.setRewardAddr(address(Ireward));

        ISearch Isearch = ISearch(createClone(searchModelAddr));
        Isearch.initialize(address(Igovern),address(Ipool),address(Ireward),address(Iairdrop));

        //设置Government的查询地址
        Igovern.setSearchAddr(address(Isearch));

        daoAddrs[len] = address(Igovern);
        len += 1;
    }

    function setGovernModelAddr(address _modelAddr) public onlyOwner(){
        governModelAddr = _modelAddr;
    }

    function setPoolModelAddr(address _modelAddr) public onlyOwner(){
        poolModelAddr = _modelAddr;
    }

    function setAirdropModelAddr(address _modelAddr) public onlyOwner(){
        airdropModelAddr = _modelAddr;
    }

    function setRewardModelAddr(address _modelAddr) public onlyOwner(){
        rewardModelAddr = _modelAddr;
    }

    function setFaucetModelAddr(address _modelAddr) public onlyOwner(){
        faucetModelAddr = _modelAddr;
    }

    function setSearchModelAddr(address _modelAddr) public onlyOwner(){
        searchModelAddr = _modelAddr;
    }

    function getDaoAddrs(uint _index) public view returns(address[] memory){
        address[] memory addrs = new address[](6);
        if(daoAddrs[_index] != address(0)){
            IGovernance Igovern = IGovernance(daoAddrs[_index]);
            addrs[0] = daoAddrs[_index];
            addrs[1] = Igovern.stkTokenAddr();
            addrs[2] = Igovern.retTokenAddr();
            addrs[3] = Igovern.rewardAddr();
            addrs[4] = Igovern.searchAddr();
            IPool Ipool = IPool(Igovern.stkTokenAddr());
            addrs[5] = Ipool.faucetModelAddr();
        }
        return addrs;
    }
}