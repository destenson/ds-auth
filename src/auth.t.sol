/// auth.sol -- widely-used access control pattern for Ethereum

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./auth.sol";

contract FakeVault is DSAuth {
    function access() public view auth {}
}

contract BooleanAuthority is DSAuthority {
    bool yes;

    function BooleanAuthority(bool _yes) public {
        yes = _yes;
    }

    function canCall(
        address src, address dst, bytes4 sig
    ) public constant returns (bool) {
        src; dst; sig; // silence warnings
        return yes;
    }
}

contract DSAuthTest is DSTest, DSAuthEvents {
    FakeVault vault = new FakeVault();
    BooleanAuthority rejector = new BooleanAuthority(false);

    function test_owner() public {
        expectEventsExact(vault);
        vault.access();
        vault.setOwner(0);
        LogSetOwner(0);
    }

    function testFail_non_owner_1() public {
        vault.setOwner(0);
        vault.access();
    }

    function testFail_non_owner_2() public {
        vault.setOwner(0);
        vault.setOwner(0);
    }

    function test_accepting_authority() public {
        vault.setAuthority(new BooleanAuthority(true));
        vault.setOwner(0);
        vault.access();
    }

    function testFail_rejecting_authority_1() public {
        vault.setAuthority(new BooleanAuthority(false));
        vault.setOwner(0);
        vault.access();
    }

    function testFail_rejecting_authority_2() public {
        vault.setAuthority(new BooleanAuthority(false));
        vault.setOwner(0);
        vault.setOwner(0);
    }
}
