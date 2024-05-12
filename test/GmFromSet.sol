// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GmFromSet} from "../src/GmFromSet.sol";

contract GmFromSetTest is Test {
    GmFromSet public gm;

    function setUp() public {
        gm = new GmFromSet();
    }

    function test_gm() public {}
}
