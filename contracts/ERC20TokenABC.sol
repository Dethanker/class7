// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // 对openzeppelin标准的ERC20合约做了修改，在构造函数里面添加了totalSupply的初始化
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20TokenABC is Context, ERC20 {
    // - 支持项目方增发的功能
    // - 支持销毁的功能
    // - 支持交易收取手续费至项目方配置的地址
    // - 支持交易销毁部分代币的功能

    /**
     * @dev Sets the values for {name}, {symbol} and {totalSupply}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) ERC20(name_, symbol_, totalSupply_) {}

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return super.name();
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return super.symbol();
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * See {ERC20-_mint}.
     */
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Transfers `amount` tokens `to` the address with `fee` tokens charged by the `charger`.
     *
     * See {ERC20-_transfer}.
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`+`fee`.
     * - the `fee` amount should > 0.
     */
    function transferWithFee(address to, uint256 amount, uint256 fee, address charger) public returns (bool) {
        require(fee > 0, "Fee amount must be greater than zero");
        address owner = _msgSender();
        _transfer(owner, charger, fee);
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` tokens `to` the address with `burnAmount` tokens burn.
     *
     * See {ERC20-_transfer}.
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - the `burnAmount` should > 0 and LEQ `amount`.
     */
    function transferWithTokenBurn(address to, uint256 amount, uint256 burnAmount) public returns (bool) {
        require(burnAmount > 0, "Burn amount must be greater than zero");
        require(burnAmount <= amount, "Burn amount must be less than or equal to the transfer amount");
        address owner = _msgSender();
        uint256 transfterAmount = amount - burnAmount;
        _burn(owner, burnAmount);
        _transfer(owner, to, transfterAmount);
        return true;
    }
}